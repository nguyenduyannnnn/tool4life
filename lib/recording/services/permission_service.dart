import 'package:permission_handler/permission_handler.dart';
import 'package:changmeeting/common/utilities.dart';

/// Service to handle microphone permission in compliance with Apple App Store Guideline 5.1.1
/// 
/// COMPLIANCE RULES:
/// - NEVER request permission on app launch
/// - ONLY request permission after explicit user interaction (tap "Start Recording")
/// - NEVER show custom dialogs before system permission request
/// - NEVER ask user to reconsider after denial
/// - Show passive UI for denied states
/// - Only show "Open Settings" for permanently denied
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Check current microphone permission status
  Future<PermissionStatus> checkPermission() async {
    final status = await Permission.microphone.status;
    Utilities.customPrint('🔍 Checking microphone permission: $status');
    return status;
  }

  /// Request microphone permission (ONLY call after explicit user interaction)
  /// This should ONLY be called when user taps "Start Recording" button
  /// NEVER call this on app launch or without user interaction
  Future<PermissionStatus> requestPermission() async {
    Utilities.customPrint('📱 Requesting microphone permission after user interaction...');
    final status = await Permission.microphone.request();
    Utilities.customPrint('📱 Permission request completed: $status');
    return status;
  }

  /// Check if permission is granted
  Future<bool> isGranted() async {
    final status = await checkPermission();
    return status.isGranted;
  }

  /// Check if permission is denied (first time)
  Future<bool> isDenied() async {
    final status = await checkPermission();
    return status.isDenied;
  }

  /// Check if permission is permanently denied
  Future<bool> isPermanentlyDenied() async {
    final status = await checkPermission();
    return status.isPermanentlyDenied;
  }

  /// Open app settings (only for permanently denied case)
  Future<void> openSettings() async {
    Utilities.customPrint('⚙️ Opening app settings...');
    await openAppSettings();
  }
}