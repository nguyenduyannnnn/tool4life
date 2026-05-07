import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:changmeeting/common/utilities.dart';
import 'file_manager_service.dart';

class MigrationService {
  static final MigrationService _instance = MigrationService._internal();
  factory MigrationService() => _instance;
  MigrationService._internal();

  final FileManagerService _fileManagerService = FileManagerService();

  /// Migrate recordings from old app documents directory to new Meobeo folder
  Future<void> migrateRecordingsToMeobeoFolder() async {
    try {
      Utilities.customPrint('🔄 Starting migration to Meobeo folder...');

      // Get old recordings directory (app documents)
      final appDir = await getApplicationDocumentsDirectory();
      final oldRecordingsDir = Directory('${appDir.path}/recordings');

      // Check if old directory exists
      if (!await oldRecordingsDir.exists()) {
        Utilities.customPrint('📁 No old recordings directory found, skipping migration');
        return;
      }

      // Get new Meobeo recordings directory
      final newRecordingsDir = await _fileManagerService.getRecordingsDirectory();

      // Get all files in old directory
      final List<FileSystemEntity> oldFiles = await oldRecordingsDir.list().toList();
      int migratedCount = 0;

      for (final entity in oldFiles) {
        if (entity is File && _isAudioFile(entity.path)) {
          try {
            final fileName = entity.path.split('/').last;
            final newFilePath = '${newRecordingsDir.path}/$fileName';
            
            // Check if file already exists in new location
            final newFile = File(newFilePath);
            if (!await newFile.exists()) {
              // Copy file to new location
              await entity.copy(newFilePath);
              migratedCount++;
              Utilities.customPrint('📁 Migrated: $fileName');
            }
          } catch (e) {
            Utilities.customPrint('❌ Error migrating file ${entity.path}: $e');
          }
        }
      }

      if (migratedCount > 0) {
        Utilities.customPrint('✅ Migration completed: $migratedCount files moved to Meobeo folder');
        
        // Optionally delete old directory after successful migration
        try {
          await oldRecordingsDir.delete(recursive: true);
          Utilities.customPrint('🗑️ Old recordings directory cleaned up');
        } catch (e) {
          Utilities.customPrint('⚠️ Could not delete old directory: $e');
        }
      } else {
        Utilities.customPrint('📁 No files to migrate');
      }

    } catch (e) {
      Utilities.customPrint('❌ Migration error: $e');
    }
  }

  /// Check if file is an audio file
  bool _isAudioFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['m4a', 'mp3', 'wav', 'aac', 'ogg'].contains(extension);
  }
}