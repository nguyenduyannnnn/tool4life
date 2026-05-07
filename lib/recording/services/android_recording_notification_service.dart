import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:changmeeting/common/utilities.dart';

/// Service để quản lý MediaStyle notification trên Android
class AndroidRecordingNotificationService {
  static const MethodChannel _methodChannel = MethodChannel('meobeo/recording_notification');
  static const EventChannel _eventChannel = EventChannel('meobeo/recording_notification_events');
  
  static AndroidRecordingNotificationService? _instance;
  static AndroidRecordingNotificationService get instance {
    _instance ??= AndroidRecordingNotificationService._();
    return _instance!;
  }
  
  AndroidRecordingNotificationService._();
  
  StreamSubscription<dynamic>? _eventSubscription;
  StreamController<Map<String, dynamic>>? _notificationEventController;
  
  /// Stream để lắng nghe events từ notification
  Stream<Map<String, dynamic>> get notificationEvents {
    _notificationEventController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _notificationEventController!.stream;
  }
  
  /// Initialize service và setup event listener
  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    
    try {
      // Setup event listener
      _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map<String, dynamic>) {
            _notificationEventController?.add(event);
            _handleNotificationEvent(event);
          }
        },
        onError: (error) {
          Utilities.customPrint('❌ Notification event error: $error');
        },
      );
      
      Utilities.customPrint('✅ AndroidRecordingNotificationService initialized');
    } catch (e) {
      Utilities.customPrint('❌ Failed to initialize AndroidRecordingNotificationService: $e');
    }
  }
  
  /// Bắt đầu hiển thị notification
  Future<bool> startNotification() async {
    if (!Platform.isAndroid) return false;
    
    try {
      await _methodChannel.invokeMethod('startNotification');
      Utilities.customPrint('📢 Recording notification started');
      return true;
    } catch (e) {
      Utilities.customPrint('❌ Failed to start notification: $e');
      return false;
    }
  }
  
  /// Cập nhật duration trên notification
  Future<void> updateDuration(int durationSeconds) async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('updateDuration', {
        'duration': durationSeconds,
      });
    } catch (e) {
      Utilities.customPrint('❌ Failed to update notification duration: $e');
    }
  }
  
  /// Dừng notification
  Future<void> stopNotification() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _methodChannel.invokeMethod('stopNotification');
      Utilities.customPrint('📢 Recording notification stopped');
    } catch (e) {
      Utilities.customPrint('❌ Failed to stop notification: $e');
    }
  }
  
  /// Handle events từ notification
  void _handleNotificationEvent(Map<String, dynamic> event) {
    final action = event['action'] as String?;
    
    switch (action) {
      case 'stopRequested':
        Utilities.customPrint('📢 Stop recording requested from notification');
        break;
      case 'durationUpdate':
        final duration = event['duration'] as int?;
        if (duration != null) {
          Utilities.customPrint('📢 Duration updated from notification: ${_formatDuration(duration)}');
        }
        break;
      default:
        Utilities.customPrint('📢 Unknown notification event: $action');
    }
  }
  
  /// Format duration cho display
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  /// Dispose resources
  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _notificationEventController?.close();
    _notificationEventController = null;
  }
}