import 'package:changmeeting/common/utilities.dart';

/// Deprecated - This service is no longer used
/// Use AndroidRecordingNotificationService instead
class RecordingNotificationService {
  static final RecordingNotificationService _instance = RecordingNotificationService._internal();
  factory RecordingNotificationService() => _instance;
  RecordingNotificationService._internal();

  bool _isInitialized = false;

  /// Initialize notification service - DISABLED
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    Utilities.customPrint('⚠️ RecordingNotificationService is deprecated and disabled');
  }

  /// Show recording notification - DISABLED
  Future<void> showRecordingNotification({required String duration}) async {
    // Do nothing - this service is disabled
    Utilities.customPrint('⚠️ showRecordingNotification called on deprecated service - ignoring');
  }

  /// Update recording notification - DISABLED
  Future<void> updateRecordingNotification({required String duration}) async {
    // Do nothing - this service is disabled
    Utilities.customPrint('⚠️ updateRecordingNotification called on deprecated service - ignoring');
  }

  /// Hide recording notification - DISABLED
  Future<void> hideRecordingNotification() async {
    // Do nothing - this service is disabled
    Utilities.customPrint('⚠️ hideRecordingNotification called on deprecated service - ignoring');
  }

  /// Request notification permissions - DISABLED
  Future<bool> requestNotificationPermissions() async {
    // Always return true to avoid blocking
    return true;
  }
}