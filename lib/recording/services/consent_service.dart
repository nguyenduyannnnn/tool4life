import 'package:shared_preferences/shared_preferences.dart';
import 'package:changmeeting/common/utilities.dart';

/// Service to manage user consent for audio upload
/// Complies with App Store guidelines by asking for explicit consent
/// before uploading any audio data to servers
class ConsentService {
  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  static const String _consentKey = 'audio_upload_consent_granted';

  /// Check if user has already given consent for audio upload
  Future<bool> hasUserConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasConsent = prefs.getBool(_consentKey) ?? false;
      Utilities.customPrint('🔒 Checking upload consent: $hasConsent');
      return hasConsent;
    } catch (e) {
      Utilities.customPrint('❌ Error checking consent: $e');
      return false;
    }
  }

  /// Store user consent for audio upload
  Future<void> grantConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, true);
      Utilities.customPrint('✅ User consent granted for audio upload');
    } catch (e) {
      Utilities.customPrint('❌ Error storing consent: $e');
    }
  }

  /// Revoke user consent (for testing or user preference changes)
  Future<void> revokeConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, false);
      Utilities.customPrint('❌ User consent revoked for audio upload');
    } catch (e) {
      Utilities.customPrint('❌ Error revoking consent: $e');
    }
  }

  /// Clear all consent data (for logout or reset)
  Future<void> clearConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_consentKey);
      Utilities.customPrint('🗑️ User consent data cleared');
    } catch (e) {
      Utilities.customPrint('❌ Error clearing consent: $e');
    }
  }
}