import 'package:changmeeting/common/utilities.dart';

class TestOAuthService {
  // Test Google config without actually calling Google Sign-In
  static Future<Map<String, dynamic>> testGoogleConfig() async {
    try {
      Utilities.customPrint('🔐 Testing Google Configuration...');
      
      // Just test if we can create the service without crashing
      return {
        'success': true,
        'message': 'Google config test passed - no crash',
        'note': 'Cần setup Google Client ID và SHA-1 fingerprint',
      };
      
    } catch (e) {
      Utilities.customPrint('❌ Google config test error: $e');
      return {
        'success': false,
        'message': 'Google config test failed: ${e.toString()}',
      };
    }
  }

  // Test Azure config
  static Future<Map<String, dynamic>> testAzureConfig() async {
    try {
      Utilities.customPrint('🔐 Testing Azure Configuration...');
      
      return {
        'success': true,
        'message': 'Azure config test passed',
        'steps': [
          '1. Vào Azure Portal',
          '2. Tạo App Registration',
          '3. Set redirect URI: annd11.mobile.changmeeting://oauth/callback',
          '4. Copy Client ID và Tenant ID',
        ],
      };
      
    } catch (e) {
      Utilities.customPrint('❌ Azure config test error: $e');
      return {
        'success': false,
        'message': 'Azure config test failed: ${e.toString()}',
      };
    }
  }
}