import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:changmeeting/recording/services/recording_service.dart';
import 'package:changmeeting/recording/services/file_manager_service.dart';
import 'package:changmeeting/recording/services/android_recording_notification_service.dart';
import 'package:changmeeting/recording/services/background_upload_service.dart';
import 'package:changmeeting/recording/services/permission_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/common/utilities.dart';

/// Service to manage foreground recording with notification and overlay
class RecordingForegroundService {
  static final RecordingForegroundService _instance =
      RecordingForegroundService._internal();
  factory RecordingForegroundService() => _instance;
  RecordingForegroundService._internal();

  final RecordingService _recordingService = RecordingService();
  final FileManagerService _fileManagerService = FileManagerService();
  final AndroidRecordingNotificationService _notificationService = AndroidRecordingNotificationService.instance;
  final BackgroundUploadService _backgroundUploadService = BackgroundUploadService.instance;
  final PermissionService _permissionService = PermissionService();
  final ConsentService _consentService = ConsentService();

  bool _isRecording = false;
  int _duration = 0;
  StreamSubscription<int>? _durationSubscription;
  StreamSubscription<bool>? _recordingSubscription;
  StreamSubscription? _overlayMessageSubscription;
  StreamSubscription<Map<String, dynamic>>? _notificationEventSubscription;

  bool get isRecording => _isRecording;
  int get duration => _duration;

  /// Initialize the service and setup streams
  void initialize() {
    _setupStreams();
    _setupOverlayListener();
    _setupNotificationService();
    _setupBackgroundUploadService();
  }

  void _setupOverlayListener() {
    // Only setup listener once for the singleton and only on Android
    if (_overlayMessageSubscription != null || !Platform.isAndroid) return;

    try {
      _overlayMessageSubscription =
          FlutterOverlayWindow.overlayListener.listen((event) {
        if (event is Map && event['action'] == 'stopRecording') {
          Utilities.customPrint('📱 Stop recording requested from overlay');
          stopRecording();
        }
      });
    } catch (e) {
      Utilities.customPrint('⚠️ Could not setup overlay listener: $e');
    }
  }

  void _setupStreams() {
    _durationSubscription?.cancel();
    _recordingSubscription?.cancel();

    _durationSubscription = _recordingService.durationStream.listen((duration) {
      _duration = duration;
      _updateOverlay();
      _updateNotification(duration);
    });

    _recordingSubscription =
        _recordingService.isRecordingStream.listen((isRecording) {
      _isRecording = isRecording;
      if (isRecording) {
        _startNotification();
      } else {
        _stopNotification();
      }
    });
  }

  /// Start recording without overlay (for testing)
  Future<bool> startRecordingSimple(BuildContext context) async {
    try {
      // Check microphone permission using PermissionService
      final isGranted = await _permissionService.isGranted();
      Utilities.customPrint('🎤 Microphone permission: $isGranted');
      
      if (!isGranted) {
        Utilities.customPrint('❌ Microphone permission denied');
        return false;
      }

      // Start recording without overlay
      await _recordingService.startRecording();
      
      Utilities.customPrint('✅ Recording started (simple mode)');
      return true;
    } catch (e) {
      Utilities.customPrint('❌ Failed to start recording: $e');
      return false;
    }
  }

  /// Start recording with foreground service
  Future<bool> startRecording(BuildContext context) async {
    try {
      // Check microphone permission using PermissionService
      final isGranted = await _permissionService.isGranted();
      Utilities.customPrint('🎤 Microphone permission: $isGranted');
      
      if (!isGranted) {
        Utilities.customPrint('❌ Microphone permission denied');
        return false;
      }
      
      // Only check overlay on Android - iOS doesn't support system overlay
      bool hasOverlayPermission = false;
      if (Platform.isAndroid) {
        try {
          hasOverlayPermission = await FlutterOverlayWindow.isPermissionGranted();
          if (!hasOverlayPermission) {
            Utilities.customPrint('⚠️ Overlay permission not granted');
          }
        } catch (e) {
          Utilities.customPrint('⚠️ Overlay plugin error (continuing without overlay): $e');
          hasOverlayPermission = false;
        }
      }

      // Start recording
      await _recordingService.startRecording();

      Utilities.customPrint('✅ Recording started with foreground service');
      return true;
    } catch (e) {
      Utilities.customPrint('❌ Failed to start recording: $e');
      return false;
    }
  }

  /// Stop recording and save file
  Future<String?> stopRecording() async {
    try {
      // Stop recording
      final filePath = await _recordingService.stopRecording();

      // Close overlay safely (Android only)
      if (Platform.isAndroid) {
        try {
          if (await FlutterOverlayWindow.isActive()) {
            await FlutterOverlayWindow.closeOverlay();
          }
        } catch (e) {
          Utilities.customPrint('⚠️ Error closing overlay: $e');
        }
      }

      if (filePath != null) {
        // Save recording metadata
        await _saveRecording(filePath);
        Utilities.customPrint('✅ Recording saved: $filePath');
        return filePath;
      }

      return null;
    } catch (e) {
      Utilities.customPrint('❌ Failed to stop recording: $e');
      return null;
    }
  }

  Future<void> _saveRecording(String filePath) async {
    try {
      // Generate filename and move file
      final fileName = _fileManagerService.generateFileName();
      final finalPath = await _fileManagerService.moveFileToRecordingsDirectory(
          filePath, fileName);

      // Get file size
      final fileSize = await _fileManagerService.getFileSize(finalPath);

      // Create recording model
      final recording = RecordingModel(
        id: _fileManagerService.generateRecordingId(),
        fileName: fileName,
        filePath: finalPath,
        duration: _duration,
        createdAt: DateTime.now(),
        fileSize: fileSize,
      );

      // Save metadata
      await _fileManagerService.saveRecordingMetadata(recording);

      // Wait a bit to ensure file is fully written
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user has given consent (should be granted via stop dialog)
      final hasConsent = await _consentService.hasUserConsent();
      
      if (hasConsent) {
        Utilities.customPrint('📤 User has consent, adding to upload queue: ${recording.fileName}');
        // Add to background upload queue (consent already granted)
        await _backgroundUploadService.addToUploadQueue(recording);
      } else {
        Utilities.customPrint('🔒 No upload consent - recording saved locally only');
        // Recording is saved locally but not uploaded
      }
    } catch (e) {
      throw Exception('Failed to save recording: $e');
    }
  }

  /// Update overlay with current duration
  void _updateOverlay() {
    // Send message to overlay to update duration
    if (Platform.isAndroid) {
      try {
        final minutes = _duration ~/ 60;
        final seconds = _duration % 60;
        final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        
        FlutterOverlayWindow.shareData({
          'action': 'updateDuration',
          'duration': timeText,
        });
      } catch (e) {
        // Overlay might not be active or plugin not working
        Utilities.customPrint('⚠️ Could not update overlay: $e');
      }
    }
  }

  /// Setup notification service
  void _setupNotificationService() {
    _notificationService.initialize();
    
    // Listen to notification events
    _notificationEventSubscription = _notificationService.notificationEvents.listen((event) {
      final action = event['action'] as String?;
      
      if (action == 'stopRequested') {
        // User tapped stop button on notification
        Utilities.customPrint('📢 Stop recording requested from notification');
        stopRecording();
      }
    });
  }

  /// Setup background upload service
  void _setupBackgroundUploadService() {
    _backgroundUploadService.initialize();
  }

  /// Start notification
  void _startNotification() {
    if (Platform.isAndroid) {
      _notificationService.startNotification();
      Utilities.customPrint('📢 Recording notification started');
    }
  }

  /// Update notification with duration
  void _updateNotification(int duration) {
    if (Platform.isAndroid) {
      _notificationService.updateDuration(duration);
    }
  }

  /// Stop notification
  void _stopNotification() {
    if (Platform.isAndroid) {
      _notificationService.stopNotification();
      Utilities.customPrint('📢 Recording notification stopped');
    }
  }

  /// Request overlay permission
  static Future<bool> requestOverlayPermission() async {
    if (Platform.isAndroid) {
      final hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      if (!hasPermission) {
        final result = await FlutterOverlayWindow.requestPermission();
        return result ?? false;
      }
      return true;
    }
    return false; // iOS doesn't support overlay
  }

  void dispose() {
    _durationSubscription?.cancel();
    _recordingSubscription?.cancel();
    _overlayMessageSubscription?.cancel();
    _notificationEventSubscription?.cancel();
    _notificationService.dispose();
    _backgroundUploadService.dispose();
  }
}
