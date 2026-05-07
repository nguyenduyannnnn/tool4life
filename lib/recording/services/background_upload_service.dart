import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/recording/services/upload_service.dart';
import 'package:changmeeting/recording/services/file_manager_service.dart';

/// Background Upload Service để upload file ngầm không bị gián đoạn
class BackgroundUploadService {
  static const MethodChannel _methodChannel = MethodChannel('meobeo/background_upload');
  static const EventChannel _eventChannel = EventChannel('meobeo/background_upload_events');
  
  static BackgroundUploadService? _instance;
  static BackgroundUploadService get instance {
    _instance ??= BackgroundUploadService._();
    return _instance!;
  }
  
  BackgroundUploadService._();
  
  final UploadService _uploadService = UploadService();
  final FileManagerService _fileManagerService = FileManagerService();
  
  StreamSubscription<dynamic>? _eventSubscription;
  StreamController<Map<String, dynamic>>? _uploadEventController;
  
  // Queue để quản lý upload
  final List<RecordingModel> _uploadQueue = [];
  bool _isUploading = false;
  
  /// Stream để lắng nghe events từ background upload
  Stream<Map<String, dynamic>> get uploadEvents {
    _uploadEventController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _uploadEventController!.stream;
  }
  
  /// Initialize service
  Future<void> initialize() async {
    try {
      if (Platform.isAndroid) {
        // Setup event listener for Android
        _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
          (dynamic event) {
            if (event is Map<String, dynamic>) {
              _uploadEventController?.add(event);
              _handleUploadEvent(event);
            }
          },
          onError: (error) {
            Utilities.customPrint('❌ Background upload event error: $error');
          },
        );
      }
      
      Utilities.customPrint('✅ BackgroundUploadService initialized');
    } catch (e) {
      Utilities.customPrint('❌ Failed to initialize BackgroundUploadService: $e');
    }
  }
  
  /// Thêm file vào queue upload ngầm
  Future<void> addToUploadQueue(RecordingModel recording) async {
    try {
      // Kiểm tra file có tồn tại không
      final file = File(recording.filePath);
      if (!await file.exists()) {
        Utilities.customPrint('❌ File not found for upload: ${recording.filePath}');
        return;
      }
      
      // Thêm vào queue
      _uploadQueue.add(recording);
      Utilities.customPrint('📤 Added to upload queue: ${recording.fileName}');
      
      // Bắt đầu upload nếu chưa có upload nào đang chạy
      if (!_isUploading) {
        await _processUploadQueue();
      }
      
    } catch (e) {
      Utilities.customPrint('❌ Error adding to upload queue: $e');
    }
  }
  
  /// Xử lý queue upload
  Future<void> _processUploadQueue() async {
    if (_uploadQueue.isEmpty || _isUploading) return;
    
    _isUploading = true;
    
    try {
      // Bắt đầu foreground service cho upload
      await _startUploadForegroundService();
      
      while (_uploadQueue.isNotEmpty) {
        final recording = _uploadQueue.removeAt(0);
        
        Utilities.customPrint('📤 Processing upload: ${recording.fileName}');
        
        // Update notification với file đang upload
        await _updateUploadNotification(recording.fileName, 0);
        
      // Upload file with consent check (no context for background upload)
      final success = await _uploadWithProgress(recording);
        
        if (success) {
          Utilities.customPrint('✅ Upload completed: ${recording.fileName}');
        } else {
          Utilities.customPrint('❌ Upload failed: ${recording.fileName}');
          // Có thể thêm retry logic ở đây
        }
        
        // Delay nhỏ giữa các upload
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
    } finally {
      _isUploading = false;
      // Dừng foreground service khi hoàn thành
      await _stopUploadForegroundService();
    }
  }
  
  /// Upload với progress tracking
  Future<bool> _uploadWithProgress(RecordingModel recording) async {
    try {
      // Use legacy method for background uploads (consent should be checked before queuing)
      return await _uploadService.uploadRecordingLegacy(recording);
      
    } catch (e) {
      Utilities.customPrint('❌ Upload error: $e');
      return false;
    }
  }
  
  /// Bắt đầu foreground service cho upload
  Future<void> _startUploadForegroundService() async {
    try {
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('startUploadService');
        Utilities.customPrint('📤 Upload foreground service started (Android)');
      } else if (Platform.isIOS) {
        // iOS sử dụng background task thay vì foreground service
        Utilities.customPrint('📤 iOS background upload started');
      }
    } catch (e) {
      Utilities.customPrint('❌ Failed to start upload service: $e');
    }
  }
  
  /// Cập nhật notification upload
  Future<void> _updateUploadNotification(String fileName, double progress) async {
    try {
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('updateUploadProgress', {
          'fileName': fileName,
          'progress': progress,
        });
      } else if (Platform.isIOS) {
        // iOS có thể sử dụng local notification hoặc app badge
        Utilities.customPrint('📤 iOS upload progress: $fileName - ${(progress * 100).toInt()}%');
      }
    } catch (e) {
      Utilities.customPrint('❌ Failed to update upload notification: $e');
    }
  }
  
  /// Dừng foreground service
  Future<void> _stopUploadForegroundService() async {
    try {
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('stopUploadService');
        Utilities.customPrint('📤 Upload foreground service stopped (Android)');
      } else if (Platform.isIOS) {
        Utilities.customPrint('📤 iOS background upload completed');
      }
    } catch (e) {
      Utilities.customPrint('❌ Failed to stop upload service: $e');
    }
  }
  
  /// Handle events từ native
  void _handleUploadEvent(Map<String, dynamic> event) {
    final action = event['action'] as String?;
    
    switch (action) {
      case 'uploadCancelled':
        Utilities.customPrint('📤 Upload cancelled by user');
        _cancelAllUploads();
        break;
      default:
        Utilities.customPrint('📤 Unknown upload event: $action');
    }
  }
  
  /// Hủy tất cả upload
  void _cancelAllUploads() {
    _uploadQueue.clear();
    _isUploading = false;
    _stopUploadForegroundService();
  }
  
  /// Kiểm tra có upload nào đang chạy không
  bool get hasActiveUploads => _isUploading || _uploadQueue.isNotEmpty;
  
  /// Lấy số lượng file đang chờ upload
  int get queueLength => _uploadQueue.length;
  
  /// Dispose resources
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _uploadEventController?.close();
    _uploadEventController = null;
    _cancelAllUploads();
  }
}