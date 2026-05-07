import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/config/oauth_config.dart';

class DebugOAuthService {
  static Future<Map<String, dynamic>> checkGoogleConfig() async {
    Utilities.customPrint('🔍 ===== GOOGLE CONFIG DEBUG =====');
    
    final config = {
      'clientId': OAuthConfig.googleClientId,
      'scopes': OAuthConfig.googleScopes,
      'packageName': 'annd11.mobile.changmeeting', // From build.gradle
    };
    
    Utilities.customPrint('🔍 Google Client ID: ${config['clientId']}');
    Utilities.customPrint('🔍 Google Scopes: ${config['scopes']}');
    Utilities.customPrint('🔍 Package Name: ${config['packageName']}');
    
    // Validate config
    final issues = <String>[];
    
    if (config['clientId'] == 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com') {
      issues.add('Client ID chưa được cấu hình');
    }
    
    if (!(config['clientId'] as String).endsWith('.apps.googleusercontent.com')) {
      issues.add('Client ID format không đúng (phải kết thúc bằng .apps.googleusercontent.com)');
    }
    
    if ((config['scopes'] as List).isEmpty) {
      issues.add('Scopes trống');
    }
    
    Utilities.customPrint('🔍 Issues found: ${issues.isEmpty ? 'None' : issues.join(', ')}');
    Utilities.customPrint('🔍 ===== GOOGLE CONFIG DEBUG END =====');
    
    return {
      'success': issues.isEmpty,
      'config': config,
      'issues': issues,
      'message': issues.isEmpty ? 'Config OK' : 'Có vấn đề với config',
    };
  }
  
  static Map<String, String> getExpectedGoogleConsoleConfig() {
    return {
      'Application type': 'Android',
      'Package name': 'annd11.mobile.changmeeting',
      'SHA-1 certificate fingerprint': 'Cần lấy từ: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android',
      'Client ID': 'Phải có format: xxx.apps.googleusercontent.com',
    };
  }
}