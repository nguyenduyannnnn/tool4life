import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class AuthStorageService {
  // Get access token from existing storage
  static Future<String?> getAccessToken() async {
    try {
      // Use the same token key as login repository
      final token = Globals.prefs.getString(SharedPrefsKey.token);
      Utilities.customPrint('🔐 Access token retrieved: ${token.isNotEmpty ? 'Found' : 'Not found'}');
      return token.isNotEmpty ? token : null;
    } catch (e) {
      Utilities.customPrint('❌ Error getting access token: $e');
      return null;
    }
  }
  
  // Save access token (for compatibility)
  static Future<void> saveAccessToken(String token) async {
    try {
      await Globals.prefs.setString(SharedPrefsKey.token, token);
      Utilities.customPrint('🔐 Access token saved');
    } catch (e) {
      Utilities.customPrint('❌ Error saving access token: $e');
    }
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return Globals.prefs.getString(SharedPrefsKey.refreshToken);
    } catch (e) {
      Utilities.customPrint('❌ Error getting refresh token: $e');
      return null;
    }
  }
  
  // Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    try {
      await Globals.prefs.setString(SharedPrefsKey.refreshToken, token);
      Utilities.customPrint('🔐 Refresh token saved');
    } catch (e) {
      Utilities.customPrint('❌ Error saving refresh token: $e');
    }
  }
  
  // Get user info
  static Future<String?> getUserInfo() async {
    try {
      return Globals.prefs.getString(SharedPrefsKey.userData);
    } catch (e) {
      Utilities.customPrint('❌ Error getting user info: $e');
      return null;
    }
  }
  
  // Save user info
  static Future<void> saveUserInfo(String userInfo) async {
    try {
      await Globals.prefs.setString(SharedPrefsKey.userData, userInfo);
      Utilities.customPrint('🔐 User info saved');
    } catch (e) {
      Utilities.customPrint('❌ Error saving user info: $e');
    }
  }
  
  // Clear all auth data
  static Future<void> clearAuthData() async {
    try {
      await Globals.prefs.setString(SharedPrefsKey.token, '');
      await Globals.prefs.setString(SharedPrefsKey.refreshToken, '');
      await Globals.prefs.setString(SharedPrefsKey.userData, '');
      Utilities.customPrint('🔐 Auth data cleared');
    } catch (e) {
      Utilities.customPrint('❌ Error clearing auth data: $e');
    }
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}