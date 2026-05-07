import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/services/azure_oauth_service.dart';

class AzureTestHelper {
  // Test Azure callback with manual URL
  static Future<Map<String, dynamic>> testCallback(String callbackUrl) async {
    try {
      Utilities.customPrint('🧪 Testing Azure callback: $callbackUrl');
      
      final result = await AzureOAuthService.handleCallback(callbackUrl);
      
      return {
        'success': result.success,
        'message': result.message,
        'user': result.user?.toJson(),
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Test callback error: ${e.toString()}',
      };
    }
  }
  
  // Generate sample callback URL for testing
  static String generateSampleCallback() {
    return 'msauth.annd11.mobile.changmeeting://auth?code=sample_code_123&state=sample_state';
  }
  
  // Validate callback URL format
  static bool isValidCallbackUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'annd11.mobile.changmeeting' && 
             uri.host == 'oauth' && 
             uri.path == '/callback' &&
             uri.queryParameters.containsKey('code');
    } catch (e) {
      return false;
    }
  }
}