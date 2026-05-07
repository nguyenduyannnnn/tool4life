import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/repository/upload_recording_repository.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/recording/services/file_manager_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/recording/widgets/consent_dialog.dart';

class UploadService {
  // Singleton instance
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final UploadRecordingRepository _uploadRepository = UploadRecordingRepository();
  final FileManagerService _fileManagerService = FileManagerService();
  final ConsentService _consentService = ConsentService();

  // Stream to notify UI about upload progress
  final StreamController<RecordingModel> _uploadProgressController =
      StreamController<RecordingModel>.broadcast();

  Stream<RecordingModel> get uploadProgressStream =>
      _uploadProgressController.stream;

  /// Upload recording with consent check
  /// Shows consent dialog on first upload if user hasn't agreed yet
  Future<bool> uploadRecording(RecordingModel recording, {BuildContext? context}) async {
    try {
      // Check if user has given consent for upload
      final hasConsent = await _consentService.hasUserConsent();
      Utilities.customPrint('🔒 Upload consent check: hasConsent=$hasConsent, context=${context != null}');
      
      if (!hasConsent && context != null) {
        // Show consent dialog for first upload
        Utilities.customPrint('🔒 No consent found, showing consent dialog');
        final userAgreed = await _showConsentDialog(context);
        
        if (!userAgreed) {
          Utilities.customPrint('❌ User declined upload consent');
          return false;
        }
        
        // Store consent
        await _consentService.grantConsent();
        Utilities.customPrint('✅ User granted upload consent');
      } else if (!hasConsent) {
        // No context provided and no consent - cannot upload
        Utilities.customPrint('❌ No consent and no context to show dialog');
        return false;
      } else {
        Utilities.customPrint('✅ User already has consent, proceeding with upload');
      }

      return await _performUpload(recording);
    } catch (e) {
      Utilities.customPrint("❌ UPLOAD SERVICE: Exception - ${e.toString()}");
      return false;
    }
  }

  /// Show consent dialog and return user's decision
  Future<bool> _showConsentDialog(BuildContext context) async {
    Utilities.customPrint('🔒 SHOWING CONSENT DIALOG');
    final completer = Completer<bool>();
    
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        onAgree: () {
          Utilities.customPrint('✅ User AGREED to consent');
          Navigator.of(context).pop();
          completer.complete(true);
        },
        onCancel: () {
          Utilities.customPrint('❌ User CANCELLED consent');
          Navigator.of(context).pop();
          completer.complete(false);
        },
      ),
    );
    
    return completer.future;
  }

  /// Perform the actual upload after consent is confirmed
  Future<bool> _performUpload(RecordingModel recording) async {
    try {
      Utilities.customPrint("📤 UPLOAD SERVICE: Starting upload for ${recording.fileName}");

      // Update status to uploading
      final updatingRecording = recording.copyWith(
        isUploading: true,
        uploadProgress: 0.0,
        clearUploadError: true,
      );
      await _fileManagerService.saveRecordingMetadata(updatingRecording);
      if (!_uploadProgressController.isClosed) {
        _uploadProgressController.add(updatingRecording);
      }

      // Get file
      final file = File(recording.filePath);
      if (!await file.exists()) {
        throw Exception('File not found: ${recording.filePath}');
      }

      // Upload with progress tracking
      final result = await _uploadRepository.uploadAudio(
        audioFile: file,
        fileName: recording.fileName,
        onProgress: (progress) {
          if (!_uploadProgressController.isClosed) {
            final progressRecording = updatingRecording.copyWith(
              uploadProgress: progress,
            );
            _uploadProgressController.add(progressRecording);
          }
        },
      );

      if (result.isSuccess) {
        // Upload successful
        final uploadedRecording = recording.copyWith(
          isUploading: false,
          isUploaded: true,
          uploadProgress: 1.0,
          clearUploadError: true,
        );
        await _fileManagerService.saveRecordingMetadata(uploadedRecording);
        if (!_uploadProgressController.isClosed) {
          _uploadProgressController.add(uploadedRecording);
        }

        Utilities.customPrint("✅ UPLOAD SERVICE: Upload successful");
        return true;
      } else {
        // Upload failed
        final failedRecording = recording.copyWith(
          isUploading: false,
          isUploaded: false,
          uploadProgress: 0.0,
          uploadError: result.message ?? 'Upload failed',
        );
        await _fileManagerService.saveRecordingMetadata(failedRecording);
        if (!_uploadProgressController.isClosed) {
          _uploadProgressController.add(failedRecording);
        }

        Utilities.customPrint("❌ UPLOAD SERVICE: Upload failed - ${result.message}");
        return false;
      }
    } catch (e) {
      Utilities.customPrint("❌ UPLOAD SERVICE: Exception - ${e.toString()}");

      // Update status to failed
      final failedRecording = recording.copyWith(
        isUploading: false,
        isUploaded: false,
        uploadProgress: 0.0,
        uploadError: e.toString(),
      );
      await _fileManagerService.saveRecordingMetadata(failedRecording);
      if (!_uploadProgressController.isClosed) {
        _uploadProgressController.add(failedRecording);
      }

      return false;
    }
  }

  /// Legacy method for backward compatibility (used by background service)
  /// Use uploadRecording with context parameter for new implementations
  Future<bool> uploadRecordingLegacy(RecordingModel recording) async {
    return await _performUpload(recording);
  }

  // Don't dispose the singleton - it should live for the app lifetime
  // void dispose() {
  //   _uploadProgressController.close();
  // }
}
