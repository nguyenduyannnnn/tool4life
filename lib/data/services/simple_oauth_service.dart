import 'package:google_sign_in/google_sign_in.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/config/oauth_config.dart';

class SimpleOAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: OAuthConfig.googleClientId,
    scopes: OAuthConfig.googleScopes,
  );

  // Enhanced Google Sign-In with detailed debugging
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      Utilities.customPrint('🔐 ===== GOOGLE SIGN-IN DEBUG START =====');
      Utilities.customPrint('🔐 Google Client ID: ${OAuthConfig.googleClientId}');
      Utilities.customPrint('🔐 Google Scopes: ${OAuthConfig.googleScopes}');
      
      // Check if already signed in
      final currentUser = _googleSignIn.currentUser;
      Utilities.customPrint('🔐 Current user: ${currentUser?.email ?? 'None'}');
      
      // Sign out first to ensure clean state
      Utilities.customPrint('🔐 Signing out previous user...');
      await _googleSignIn.signOut();
      
      Utilities.customPrint('🔐 Starting Google Sign-In process...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        Utilities.customPrint('❌ Google Sign-In cancelled by user');
        return {
          'success': false,
          'message': 'Đăng nhập bị hủy bởi người dùng',
        };
      }

      Utilities.customPrint('✅ Google Sign-In successful!');
      Utilities.customPrint('📧 Email: ${account.email}');
      Utilities.customPrint('👤 Name: ${account.displayName}');
      Utilities.customPrint('🆔 ID: ${account.id}');
      Utilities.customPrint('🖼️ Photo: ${account.photoUrl}');
      
      // Try to get authentication tokens
      try {
        final auth = await account.authentication;
        Utilities.customPrint('🔑 Access Token: ${auth.accessToken != null ? 'Available' : 'Null'}');
        Utilities.customPrint('🔑 ID Token: ${auth.idToken != null ? 'Available' : 'Null'}');
      } catch (e) {
        Utilities.customPrint('⚠️ Could not get auth tokens: $e');
      }
      
      Utilities.customPrint('🔐 ===== GOOGLE SIGN-IN DEBUG END =====');
      
      return {
        'success': true,
        'email': account.email,
        'name': account.displayName ?? '',
        'id': account.id,
        'photoUrl': account.photoUrl,
      };
      
    } catch (e) {
      Utilities.customPrint('❌ ===== GOOGLE SIGN-IN ERROR =====');
      Utilities.customPrint('❌ Error Type: ${e.runtimeType}');
      Utilities.customPrint('❌ Error Message: $e');
      Utilities.customPrint('❌ Error String: ${e.toString()}');
      
      // Detailed error analysis
      String errorMessage = 'Lỗi đăng nhập Google';
      String errorDetails = e.toString();
      
      if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage = 'Lỗi cấu hình Google OAuth';
        errorDetails = 'SHA-1 fingerprint hoặc package name không đúng';
      } else if (e.toString().contains('NETWORK_ERROR')) {
        errorMessage = 'Lỗi kết nối mạng';
        errorDetails = 'Kiểm tra kết nối internet';
      } else if (e.toString().contains('SIGN_IN_CANCELLED')) {
        errorMessage = 'Đăng nhập bị hủy';
        errorDetails = 'Người dùng đã hủy quá trình đăng nhập';
      } else if (e.toString().contains('SIGN_IN_FAILED')) {
        errorMessage = 'Đăng nhập thất bại';
        errorDetails = 'Có lỗi xảy ra trong quá trình đăng nhập';
      } else if (e.toString().contains('ApiException')) {
        errorMessage = 'Lỗi Google API';
        errorDetails = 'Kiểm tra cấu hình Google Console';
      }
      
      Utilities.customPrint('❌ Processed Error: $errorMessage');
      Utilities.customPrint('❌ Error Details: $errorDetails');
      Utilities.customPrint('❌ ===== GOOGLE SIGN-IN ERROR END =====');
      
      return {
        'success': false,
        'message': errorMessage,
        'error': errorDetails,
        'rawError': e.toString(),
      };
    }
  }

  // Simple Azure test (just show config info)
  static Future<Map<String, dynamic>> testAzureConfig() async {
    try {
      Utilities.customPrint('🔐 Testing Azure Configuration...');
      
      // Check if Azure config is set
      if (OAuthConfig.azureTenantId == 'YOUR_AZURE_TENANT_ID' || 
          OAuthConfig.azureClientId == 'YOUR_AZURE_CLIENT_ID') {
        return {
          'success': false,
          'message': 'Azure config chưa được cấu hình',
        };
      }
      
      final configInfo = {
        'tenant_id': OAuthConfig.azureTenantId,
        'client_id': OAuthConfig.azureClientId,
        'redirect_uri': OAuthConfig.azureRedirectUri,
        'scopes': OAuthConfig.azureScopes,
      };
      
      Utilities.customPrint('🔐 Azure Config: $configInfo');
      
      return {
        'success': true,
        'message': 'Azure config OK',
        'config': configInfo,
      };
      
    } catch (e) {
      Utilities.customPrint('❌ Azure config test error: $e');
      return {
        'success': false,
        'message': 'Lỗi test Azure config: ${e.toString()}',
      };
    }
  }
}