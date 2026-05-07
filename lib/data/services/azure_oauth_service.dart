import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/config/oauth_config.dart';
import 'package:changmeeting/presentation/modules/authen_module/src/ui/azure_webview_screen.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class AzureOAuthService {
  static String? _codeVerifier;
  static String? _state;

  // Generate PKCE code verifier
  static String _generateCodeVerifier() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(128, (i) => chars[random.nextInt(chars.length)]).join();
  }

  // Generate PKCE code challenge
  static String _generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // Generate random state
  static String _generateState() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(32, (i) => chars[random.nextInt(chars.length)]).join();
  }

  // Start Azure OAuth flow
  static Future<AzureSignInResult> signInWithAzure({BuildContext? context}) async {
    try {
      Utilities.customPrint('🔐 ===== AZURE SIGN-IN START =====');
      
      // Validate config
      if (OAuthConfig.azureTenantId == 'YOUR_AZURE_TENANT_ID' || 
          OAuthConfig.azureClientId == 'YOUR_AZURE_CLIENT_ID') {
        return AzureSignInResult(
          success: false,
          message: 'Azure config chưa được cấu hình',
        );
      }

      // Generate PKCE parameters
      _codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(_codeVerifier!);
      _state = _generateState();

      Utilities.customPrint('🔐 Azure Tenant ID: ${OAuthConfig.azureTenantId}');
      Utilities.customPrint('🔐 Azure Client ID: ${OAuthConfig.azureClientId}');
      Utilities.customPrint('🔐 Azure Redirect URI: ${OAuthConfig.azureRedirectUri}');

      // Build authorization URL
      final authUrl = Uri.https('login.microsoftonline.com', '/${OAuthConfig.azureTenantId}/oauth2/v2.0/authorize', {
        'client_id': OAuthConfig.azureClientId,
        'response_type': 'code',
        'redirect_uri': OAuthConfig.azureRedirectUri,
        'scope': OAuthConfig.azureScopes,
        'state': _state,
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'prompt': 'select_account',
      });

      Utilities.customPrint('🔐 Opening Azure auth URL...');
      Utilities.customPrint('🔐 URL: $authUrl');

      String? callbackUrl;

      if (Platform.isAndroid) {
        // Android: dùng WebView trong app để tránh Custom Tab không tự đóng
        if (context == null) {
          return AzureSignInResult(
            success: false,
            message: 'Cần BuildContext để mở WebView trên Android',
          );
        }
        Utilities.customPrint('🔐 Android: opening in-app WebView...');
        callbackUrl = await AzureWebViewScreen.open(
          context,
          authUrl: authUrl.toString(),
          callbackUrlScheme: OAuthConfig.azureRedirectUri,
        );
      } else {
        // iOS / các platform khác: giữ nguyên flow flutter_web_auth_2
        Utilities.customPrint('🔐 iOS: using flutter_web_auth_2...');
        callbackUrl = await FlutterWebAuth2.authenticate(
          url: authUrl.toString(),
          callbackUrlScheme: Uri.parse(OAuthConfig.azureRedirectUri).scheme,
        );
      }

      if (callbackUrl == null) {
        return AzureSignInResult(
          success: false,
          message: 'Đăng nhập bị hủy',
        );
      }

      Utilities.customPrint('🔐 Received callback: $callbackUrl');
      return await handleCallback(callbackUrl);

    } catch (e) {
      Utilities.customPrint('❌ Azure Sign-In error: $e');
      return AzureSignInResult(
        success: false,
        message: 'Lỗi đăng nhập Azure: ${e.toString()}',
      );
    }
  }

  // Handle callback from Azure (for manual testing)
  static Future<AzureSignInResult> handleCallback(String callbackUrl) async {
    try {
      Utilities.customPrint('🔐 Processing Azure callback: $callbackUrl');
      
      final uri = Uri.parse(callbackUrl);
      final code = uri.queryParameters['code'];
      final returnedState = uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        final errorDescription = uri.queryParameters['error_description'] ?? error;
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

      if (returnedState != _state) {
        return AzureSignInResult(
          success: false,
          message: 'State parameter không khớp',
        );
      }

      // Exchange code for tokens
      final tokenResult = await _exchangeCodeForTokens(code);
      
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

      Utilities.customPrint('✅ Azure Sign-In successful: ${userInfo.email}');

      return AzureSignInResult(
        success: true,
        user: userInfo,
        accessToken: tokenResult.accessToken,
        idToken: tokenResult.idToken,
        message: 'Đăng nhập Azure thành công',
      );

    } catch (e) {
      Utilities.customPrint('❌ Azure callback error: $e');
      return AzureSignInResult(
        success: false,
        message: 'Lỗi xử lý callback Azure: ${e.toString()}',
      );
    }
  }

  // Exchange authorization code for tokens
  // Dùng IPv4 explicit để tránh lỗi errno=101 (ENETUNREACHABLE) trên 4G Việt Nam
  // Một số nhà mạng cấp IPv6 nhưng không route được ra internet,
  // Dart mặc định thử IPv6 trước → fail ngay lập tức.
  static Future<TokenResult> _exchangeCodeForTokens(String code) async {
    try {
      final tokenUrl = Uri.https('login.microsoftonline.com',
          '/${OAuthConfig.azureTenantId}/oauth2/v2.0/token');

      final body = {
        'client_id': OAuthConfig.azureClientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': OAuthConfig.azureRedirectUri,
        'code_verifier': _codeVerifier!,
      };
      const headers = {'Content-Type': 'application/x-www-form-urlencoded'};

      http.Response response;

      try {
        // Lần 1: thử bình thường (hệ thống tự chọn IPv4/IPv6)
        response = await http
            .post(tokenUrl, headers: headers, body: body)
            .timeout(const Duration(seconds: 15));
      } on SocketException catch (e) {
        // errno=101 ENETUNREACHABLE hoặc errno=111 ECONNREFUSED thường do IPv6
        Utilities.customPrint(
            '⚠️ Token exchange: socket error (${e.osError?.errorCode}), retrying with IPv4...');

        // Lần 2: resolve DNS lấy IPv4 rồi kết nối thẳng
        final addresses = await InternetAddress.lookup(
          'login.microsoftonline.com',
          type: InternetAddressType.IPv4,
        );

        if (addresses.isEmpty) {
          return TokenResult(
            success: false,
            message: 'Không thể phân giải DNS cho login.microsoftonline.com',
          );
        }

        final ipv4 = addresses.first.address;
        Utilities.customPrint('🔐 Retrying token exchange via IPv4: $ipv4');

        // Tạo HttpClient với IPv4 address trực tiếp
        final ioClient = HttpClient()
          ..connectionTimeout = const Duration(seconds: 15);
        final client = IOClient(ioClient);

        try {
          // Dùng IP trực tiếp, giữ Host header đúng để TLS SNI hoạt động
          final ipUrl = Uri.https(
              ipv4, '/${OAuthConfig.azureTenantId}/oauth2/v2.0/token');
          response = await client.post(
            ipUrl,
            headers: {
              ...headers,
              'Host': 'login.microsoftonline.com',
            },
            body: body,
          ).timeout(const Duration(seconds: 15));
        } finally {
          client.close();
        }
      }

      Utilities.customPrint(
          '🔐 Token exchange response: ${response.statusCode}');

      if (response.statusCode != 200) {
        Utilities.customPrint('❌ Token exchange failed: ${response.body}');
        return TokenResult(
          success: false,
          message: 'Token exchange failed: ${response.statusCode}',
        );
      }

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
  static Future<AzureUser?> _getAzureUserInfo(String accessToken) async {
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
      
      return AzureUser(
        id: data['id'],
        email: data['mail'] ?? data['userPrincipalName'],
        name: data['displayName'] ?? '',
        jobTitle: data['jobTitle'],
        department: data['department'],
        provider: 'azure',
      );

    } catch (e) {
      Utilities.customPrint('❌ Error getting Azure user info: $e');
      return null;
    }
  }

  // Test Azure configuration
  static Future<Map<String, dynamic>> testAzureConfig() async {
    try {
      Utilities.customPrint('🔍 ===== AZURE CONFIG TEST =====');
      
      final config = {
        'tenantId': OAuthConfig.azureTenantId,
        'clientId': OAuthConfig.azureClientId,
        'redirectUri': OAuthConfig.azureRedirectUri,
        'scopes': OAuthConfig.azureScopes,
      };
      
      Utilities.customPrint('🔍 Tenant ID: ${config['tenantId']}');
      Utilities.customPrint('🔍 Client ID: ${config['clientId']}');
      Utilities.customPrint('🔍 Redirect URI: ${config['redirectUri']}');
      Utilities.customPrint('🔍 Scopes: ${config['scopes']}');
      
      final issues = <String>[];
      
      if (config['tenantId'] == 'YOUR_AZURE_TENANT_ID') {
        issues.add('Tenant ID chưa được cấu hình');
      }
      
      if (config['clientId'] == 'YOUR_AZURE_CLIENT_ID') {
        issues.add('Client ID chưa được cấu hình');
      }
      
      if (!(config['redirectUri'] as String).startsWith('msauth.annd11.mobile.changmeeting://')) {
        issues.add('Redirect URI không đúng format');
      }
      
      Utilities.customPrint('🔍 Issues: ${issues.isEmpty ? 'None' : issues.join(', ')}');
      Utilities.customPrint('🔍 ===== AZURE CONFIG TEST END =====');
      
      return {
        'success': issues.isEmpty,
        'config': config,
        'issues': issues,
        'message': issues.isEmpty ? 'Azure config OK' : 'Có vấn đề với Azure config',
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi test Azure config: ${e.toString()}',
      };
    }
  }
}

// Data classes
class AzureUser {
  final String id;
  final String email;
  final String name;
  final String? jobTitle;
  final String? department;
  final String provider;

  AzureUser({
    required this.id,
    required this.email,
    required this.name,
    this.jobTitle,
    this.department,
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'jobTitle': jobTitle,
      'department': department,
      'provider': provider,
    };
  }
}

class AzureSignInResult {
  final bool success;
  final String? message;
  final AzureUser? user;
  final String? accessToken;
  final String? idToken;
  final bool requiresManualCallback;

  AzureSignInResult({
    required this.success,
    this.message,
    this.user,
    this.accessToken,
    this.idToken,
    this.requiresManualCallback = false,
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