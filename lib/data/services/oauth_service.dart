import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/config/oauth_config.dart';

class OAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: OAuthConfig.googleClientId,
    scopes: OAuthConfig.googleScopes,
  );

  // Google Sign-In
  static Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      Utilities.customPrint('🔐 Starting Google Sign-In...');
      
      // Check if already signed in
      final currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        Utilities.customPrint('🔐 User already signed in: ${currentUser.email}');
        await _googleSignIn.signOut(); // Sign out first to allow account selection
      }
      
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        Utilities.customPrint('🔐 Google Sign-In cancelled by user');
        return GoogleSignInResult(
          success: false,
          message: 'Đăng nhập Google bị hủy',
        );
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      
      if (auth.accessToken == null) {
        Utilities.customPrint('❌ Failed to get Google access token');
        return GoogleSignInResult(
          success: false,
          message: 'Không thể lấy access token từ Google',
        );
      }
      
      Utilities.customPrint('🔐 Google Sign-In successful: ${account.email}');
      
      return GoogleSignInResult(
        success: true,
        user: OAuthUser(
          id: account.id,
          email: account.email,
          name: account.displayName ?? '',
          photoUrl: account.photoUrl,
          provider: 'google',
        ),
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      
    } catch (e) {
      Utilities.customPrint('❌ Google Sign-In error: $e');
      
      // Handle specific Google Sign-In errors
      String errorMessage = 'Lỗi đăng nhập Google';
      if (e.toString().contains('network_error')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      } else if (e.toString().contains('sign_in_canceled')) {
        errorMessage = 'Đăng nhập bị hủy';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.';
      }
      
      return GoogleSignInResult(
        success: false,
        message: errorMessage,
      );
    }
  }

  // Azure AD Sign-In
  static Future<AzureSignInResult> signInWithAzure() async {
    try {
      Utilities.customPrint('🔐 Starting Azure AD Sign-In...');
      
      // Validate config first
      if (OAuthConfig.azureTenantId == 'YOUR_AZURE_TENANT_ID' || 
          OAuthConfig.azureClientId == 'YOUR_AZURE_CLIENT_ID') {
        return AzureSignInResult(
          success: false,
          message: 'Azure OAuth chưa được cấu hình. Vui lòng cập nhật OAuthConfig.',
        );
      }
      
      // Generate PKCE parameters
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      final state = _generateRandomString(32);
      
      Utilities.customPrint('🔐 Azure config - Tenant: ${OAuthConfig.azureTenantId}');
      Utilities.customPrint('🔐 Azure config - Client: ${OAuthConfig.azureClientId}');
      Utilities.customPrint('🔐 Azure config - Redirect: ${OAuthConfig.azureRedirectUri}');
      
      // Build authorization URL
      final authUrl = Uri.https('login.microsoftonline.com', '/${OAuthConfig.azureTenantId}/oauth2/v2.0/authorize', {
        'client_id': OAuthConfig.azureClientId,
        'response_type': 'code',
        'redirect_uri': OAuthConfig.azureRedirectUri,
        'scope': OAuthConfig.azureScopes,
        'state': state,
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'prompt': 'select_account',
      });

      Utilities.customPrint('🔐 Azure auth URL: $authUrl');

      // Launch web auth
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: Uri.parse(OAuthConfig.azureRedirectUri).scheme,
      );

      Utilities.customPrint('🔐 Azure callback result: $result');

      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final returnedState = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        final errorDescription = uri.queryParameters['error_description'] ?? error;
        Utilities.customPrint('❌ Azure OAuth error: $error - $errorDescription');
        return AzureSignInResult(
          success: false,
          message: 'Azure OAuth error: $errorDescription',
        );
      }

      if (code == null) {
        return AzureSignInResult(
          success: false,
          message: 'Không nhận được authorization code từ Azure',
        );
      }

      if (returnedState != state) {
        return AzureSignInResult(
          success: false,
          message: 'State parameter không khớp',
        );
      }

      // Exchange code for tokens
      final tokenResult = await _exchangeCodeForTokens(code, codeVerifier);
      
      if (!tokenResult.success) {
        return AzureSignInResult(
          success: false,
          message: tokenResult.message,
        );
      }

      // Get user info
      final userInfo = await _getAzureUserInfo(tokenResult.accessToken!);
      
      if (userInfo == null) {
        return AzureSignInResult(
          success: false,
          message: 'Không thể lấy thông tin người dùng từ Azure',
        );
      }

      Utilities.customPrint('🔐 Azure Sign-In successful: ${userInfo.email}');

      return AzureSignInResult(
        success: true,
        user: userInfo,
        accessToken: tokenResult.accessToken,
        idToken: tokenResult.idToken,
      );

    } catch (e) {
      Utilities.customPrint('❌ Azure Sign-In error: $e');
      return AzureSignInResult(
        success: false,
        message: 'Lỗi đăng nhập Azure: ${e.toString()}',
      );
    }
  }

  // Exchange authorization code for tokens
  static Future<TokenResult> _exchangeCodeForTokens(String code, String codeVerifier) async {
    try {
      final tokenUrl = Uri.https('login.microsoftonline.com', '/${OAuthConfig.azureTenantId}/oauth2/v2.0/token');
      
      final response = await http.post(
        tokenUrl,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': OAuthConfig.azureClientId,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': OAuthConfig.azureRedirectUri,
          'code_verifier': codeVerifier,
        },
      );

      final data = jsonDecode(response.body);
      
      if (data['error'] != null) {
        return TokenResult(
          success: false,
          message: 'Token exchange error: ${data['error_description']}',
        );
      }

      return TokenResult(
        success: true,
        accessToken: data['access_token'],
        idToken: data['id_token'],
      );

    } catch (e) {
      return TokenResult(
        success: false,
        message: 'Token exchange failed: ${e.toString()}',
      );
    }
  }

  // Get user info from Microsoft Graph
  static Future<OAuthUser?> _getAzureUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        Utilities.customPrint('❌ Error getting Azure user info: ${response.statusCode} ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      
      return OAuthUser(
        id: data['id'],
        email: data['mail'] ?? data['userPrincipalName'],
        name: data['displayName'] ?? '',
        photoUrl: null, // Could fetch from /me/photo/\$value if needed
        provider: 'azure',
      );

    } catch (e) {
      Utilities.customPrint('❌ Error getting Azure user info: $e');
      return null;
    }
  }

  // Sign out from Google
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      Utilities.customPrint('🔐 Google sign out successful');
    } catch (e) {
      Utilities.customPrint('❌ Google sign out error: $e');
    }
  }

  // Check if user is signed in with Google
  static Future<bool> isSignedInGoogle() async {
    return await _googleSignIn.isSignedIn();
  }

  // Get current Google user
  static GoogleSignInAccount? getCurrentGoogleUser() {
    return _googleSignIn.currentUser;
  }

  // Generate code verifier for PKCE
  static String _generateCodeVerifier() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (i) => chars[random.nextInt(chars.length)]).join();
  }

  // Generate code challenge for PKCE
  static String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // Generate random string
  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (i) => chars[random.nextInt(chars.length)]).join();
  }
}

// Data classes
class OAuthUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String provider;

  OAuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'provider': provider,
    };
  }

  factory OAuthUser.fromJson(Map<String, dynamic> json) {
    return OAuthUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      provider: json['provider'],
    );
  }
}

class GoogleSignInResult {
  final bool success;
  final String? message;
  final OAuthUser? user;
  final String? accessToken;
  final String? idToken;

  GoogleSignInResult({
    required this.success,
    this.message,
    this.user,
    this.accessToken,
    this.idToken,
  });
}

class AzureSignInResult {
  final bool success;
  final String? message;
  final OAuthUser? user;
  final String? accessToken;
  final String? idToken;

  AzureSignInResult({
    required this.success,
    this.message,
    this.user,
    this.accessToken,
    this.idToken,
  });
}

class TokenResult {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? idToken;

  TokenResult({
    required this.success,
    this.message,
    this.accessToken,
    this.idToken,
  });
}