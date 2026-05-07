import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/recording_model.dart';

class FileManagerService {
  static const String _recordingsKey = 'meobeo_recordings';
  static const String _meobeoFolderName = 'Meobeo';

  // Singleton instance
  static final FileManagerService _instance = FileManagerService._internal();
  factory FileManagerService() => _instance;
  FileManagerService._internal();

  // Stream to notify when recordings list changes
  final StreamController<List<RecordingModel>> _recordingsController =
      StreamController<List<RecordingModel>>.broadcast();

  Stream<List<RecordingModel>> get recordingsStream =>
      _recordingsController.stream;

  // Request storage permissions
  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      // Check Android version and request appropriate permissions
      try {
        // Import device_info_plus to check Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final int sdkInt = androidInfo.version.sdkInt;
        
        print('📱 Android SDK: $sdkInt');
        
        if (sdkInt >= 33) {
          // Android 13+ (API 33+) - Use granular media permissions
          print('📱 Using Android 13+ granular media permissions');
          
          // Request READ_MEDIA_AUDIO permission for audio files
          if (await Permission.audio.isDenied) {
            final audioResult = await Permission.audio.request();
            if (!audioResult.isGranted) {
              print('⚠️ Audio media permission denied');
              return false;
            }
          }
          
          // For Android 14+ (API 34+), also check for partial media access
          if (sdkInt >= 34) {
            print('📱 Android 14+ detected - checking partial media access');
            // Note: READ_MEDIA_VISUAL_USER_SELECTED is handled automatically by the system
          }
          
        } else if (sdkInt >= 30) {
          // Android 11-12 (API 30-32) - Use scoped storage only
          print('📱 Using Android 11-12 scoped storage permissions');
          
          if (await Permission.storage.isDenied) {
            final storageResult = await Permission.storage.request();
            if (!storageResult.isGranted) {
              print('⚠️ Storage permission denied');
              return false;
            }
          }
          
          // Note: MANAGE_EXTERNAL_STORAGE removed for Google Play Store compliance
          print('📱 Using scoped storage only - MANAGE_EXTERNAL_STORAGE not requested');
          
        } else {
          // Android 10 and below (API 29 and below) - Legacy storage
          print('📱 Using legacy storage permissions');
          
          if (await Permission.storage.isDenied) {
            final storageResult = await Permission.storage.request();
            if (!storageResult.isGranted) {
              print('⚠️ Storage permission denied');
              return false;
            }
          }
        }

        return true;
      } catch (e) {
        print('⚠️ Error requesting permissions: $e');
        return false;
      }
    }
    return true; // iOS doesn't need explicit storage permissions for app documents
  }

  // Get Meobeo directory in external storage (Android) or Documents (iOS)
  Future<Directory> getMeobeoDirectory() async {
    Directory? baseDir;
    
    if (Platform.isAndroid) {
      // Request permissions first
      final hasPermission = await _requestStoragePermissions();
      
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final int sdkInt = androidInfo.version.sdkInt;
        
        if (sdkInt >= 30) {
          // Android 11+ (API 30+) - Use scoped storage approach only
          print('📱 Using scoped storage for Android 11+');
          
          // Always use app-specific directory for Google Play Store compliance
          print('📱 Using app-specific directory for scoped storage');
          baseDir = await getExternalStorageDirectory();
          if (baseDir != null) {
            baseDir = Directory('${baseDir.path}/$_meobeoFolderName');
          }
        } else {
          // Android 10 and below - Traditional external storage
          if (hasPermission) {
            baseDir = await getExternalStorageDirectory();
            if (baseDir != null) {
              final List<String> pathSegments = baseDir.path.split('/');
              final int androidIndex = pathSegments.indexOf('Android');
              if (androidIndex > 0) {
                final String rootPath = pathSegments.sublist(0, androidIndex).join('/');
                baseDir = Directory('$rootPath/$_meobeoFolderName');
              }
            }
          }
        }
        
        // Fallback to app documents directory if external storage fails
        if (baseDir == null || !hasPermission) {
          print('⚠️ Using app documents directory as fallback');
          baseDir = await getApplicationDocumentsDirectory();
          baseDir = Directory('${baseDir.path}/$_meobeoFolderName');
        }
        
      } catch (e) {
        print('⚠️ Cannot access external storage: $e');
        // Fallback to app documents directory
        baseDir = await getApplicationDocumentsDirectory();
        baseDir = Directory('${baseDir.path}/$_meobeoFolderName');
      }
    } else {
      // iOS: Use Documents directory
      baseDir = await getApplicationDocumentsDirectory();
      baseDir = Directory('${baseDir.path}/$_meobeoFolderName');
    }

    if (baseDir != null && !await baseDir.exists()) {
      await baseDir.create(recursive: true);
      print('📁 Created Meobeo directory: ${baseDir.path}');
    }

    return baseDir ?? await getApplicationDocumentsDirectory();
  }

  // Get recordings directory (inside Meobeo folder)
  Future<Directory> getRecordingsDirectory() async {
    final Directory meobeoDir = await getMeobeoDirectory();
    final Directory recordingsDir = Directory('${meobeoDir.path}/recordings');

    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    return recordingsDir;
  }

  // Initialize and scan for existing recordings in Meobeo folder
  Future<void> initializeAndScanRecordings() async {
    try {
      // Get existing recordings from SharedPreferences
      final existingRecordings = await getAllRecordings();
      final existingPaths = existingRecordings.map((r) => r.filePath).toSet();

      // Scan Meobeo recordings directory for audio files
      final recordingsDir = await getRecordingsDirectory();
      final List<FileSystemEntity> files = await recordingsDir.list().toList();
      
      final List<RecordingModel> newRecordings = [];

      for (final file in files) {
        if (file is File && _isAudioFile(file.path)) {
          // Check if this file is already in our records
          if (!existingPaths.contains(file.path)) {
            // Create new recording model for discovered file
            final recording = await _createRecordingFromFile(file);
            if (recording != null) {
              newRecordings.add(recording);
            }
          }
        }
      }

      // Save new discovered recordings
      for (final recording in newRecordings) {
        await saveRecordingMetadata(recording);
      }

      // Clean up metadata for files that no longer exist
      await _cleanupMissingFiles();

      if (newRecordings.isNotEmpty) {
        print('📁 Discovered ${newRecordings.length} existing audio files in Meobeo folder');
      }

    } catch (e) {
      print('❌ Error scanning Meobeo folder: $e');
    }
  }

  // Check if file is an audio file
  bool _isAudioFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['m4a', 'mp3', 'wav', 'aac', 'ogg'].contains(extension);
  }

  // Create RecordingModel from existing file
  Future<RecordingModel?> _createRecordingFromFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();
      final fileStat = await file.stat();
      
      return RecordingModel(
        id: generateRecordingId(),
        fileName: fileName,
        filePath: file.path,
        duration: 0, // Will be updated when played
        createdAt: fileStat.modified,
        fileSize: fileSize,
        isUploaded: false, // Assume not uploaded for discovered files
      );
    } catch (e) {
      print('❌ Error creating recording from file ${file.path}: $e');
      return null;
    }
  }

  // Clean up metadata for files that no longer exist
  Future<void> _cleanupMissingFiles() async {
    try {
      final recordings = await getAllRecordings();
      final List<String> validRecordings = [];
      
      for (final recording in recordings) {
        final file = File(recording.filePath);
        if (await file.exists()) {
          validRecordings.add(jsonEncode(recording.toJson()));
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recordingsKey, validRecordings);
      
    } catch (e) {
      print('❌ Error cleaning up missing files: $e');
    }
  }
  Future<void> saveRecordingMetadata(RecordingModel recording) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recordingsJson =
        prefs.getStringList(_recordingsKey) ?? [];

    // Check if recording already exists
    final existingIndex = recordingsJson.indexWhere((json) {
      final data = jsonDecode(json);
      return data['id'] == recording.id;
    });

    if (existingIndex != -1) {
      recordingsJson[existingIndex] = jsonEncode(recording.toJson());
    } else {
      recordingsJson.add(jsonEncode(recording.toJson()));
    }

    await prefs.setStringList(_recordingsKey, recordingsJson);

    // Notify listeners about the change
    _notifyRecordingsChanged();
  }

  // Get all recordings metadata
  Future<List<RecordingModel>> getAllRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> recordingsJson =
        prefs.getStringList(_recordingsKey) ?? [];

    return recordingsJson.map((json) {
      final data = jsonDecode(json);
      return RecordingModel.fromJson(data);
    }).toList()
      ..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
  }

  // Get recording by ID
  Future<RecordingModel?> getRecordingById(String id) async {
    final recordings = await getAllRecordings();
    try {
      return recordings.firstWhere((recording) => recording.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete recording
  Future<bool> deleteRecording(String id) async {
    try {
      // Get recording info
      final recording = await getRecordingById(id);
      if (recording == null) return false;

      // Delete file
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from metadata
      final prefs = await SharedPreferences.getInstance();
      final List<String> recordingsJson =
          prefs.getStringList(_recordingsKey) ?? [];

      recordingsJson.removeWhere((json) {
        final data = jsonDecode(json);
        return data['id'] == id;
      });

      await prefs.setStringList(_recordingsKey, recordingsJson);

      // Notify listeners about the change
      _notifyRecordingsChanged();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Move file to recordings directory
  Future<String> moveFileToRecordingsDirectory(
      String sourcePath, String fileName) async {
    final recordingsDir = await getRecordingsDirectory();
    final destinationPath = '${recordingsDir.path}/$fileName';

    final sourceFile = File(sourcePath);

    if (await sourceFile.exists()) {
      await sourceFile.copy(destinationPath);
      await sourceFile.delete(); // Remove original file
    }

    return destinationPath;
  }

  // Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Get total storage used by recordings
  Future<int> getTotalStorageUsed() async {
    try {
      final recordings = await getAllRecordings();
      int totalSize = 0;

      for (final recording in recordings) {
        totalSize += recording.fileSize;
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // Clear all recordings
  Future<void> clearAllRecordings() async {
    try {
      final recordings = await getAllRecordings();

      // Delete all files
      for (final recording in recordings) {
        final file = File(recording.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recordingsKey);

      // Notify listeners about the change
      _notifyRecordingsChanged();
    } catch (e) {
      // Handle error silently
    }
  }

  // Notify listeners when recordings list changes
  Future<void> _notifyRecordingsChanged() async {
    if (!_recordingsController.isClosed) {
      final recordings = await getAllRecordings();
      _recordingsController.add(recordings);
    }
  }

  // Generate unique ID
  String generateRecordingId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Generate filename with timestamp
  String generateFileName() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'recording_${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}.m4a';
  }
}
