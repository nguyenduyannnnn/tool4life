import 'package:flutter/material.dart';
import 'package:changmeeting/common/constant.dart';
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:changmeeting/data/repository/login_repository.dart';
import 'package:changmeeting/data/repository/azure_login_repository.dart';
import 'package:changmeeting/data/services/simple_oauth_service.dart';
import 'package:changmeeting/data/services/debug_oauth_service.dart';
import 'package:changmeeting/data/services/azure_oauth_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginBloc {
  final FocusNode focusEmail = FocusNode();
  final TextEditingController controllerEmail = TextEditingController();

  final FocusNode focusPassword = FocusNode();
  final TextEditingController controllerPassword = TextEditingController();

  final streamPassword = BehaviorSubject<bool>.seeded(true);
  final streamIsLoading = BehaviorSubject<bool>.seeded(false);
  final streamError = BehaviorSubject<String>.seeded('');
  final streamRememberLogin = BehaviorSubject<bool>.seeded(false);

  final LoginRepository _loginRepository = LoginRepository();

  LoginBloc() {
    _initializeRememberedCredentials();
    testRememberLogin(); // Debug test
  }

  void dispose() {
    streamPassword.close();
    streamIsLoading.close();
    streamError.close();
    streamRememberLogin.close();
    focusEmail.dispose();
    focusPassword.dispose();
    controllerEmail.dispose();
    controllerPassword.dispose();
  }

  // Test method to check if remember login is working
  void testRememberLogin() {
    final rememberLogin = Globals.prefs.getBool(SharedPrefsKey.rememberLogin);
    final rememberedEmail = Globals.prefs.getString(SharedPrefsKey.rememberedEmail);
    final rememberedPassword = Globals.prefs.getString(SharedPrefsKey.rememberedPassword);
    
    Utilities.customPrint('🔐 Test Remember Login:');
    Utilities.customPrint('  - Remember Login: $rememberLogin');
    Utilities.customPrint('  - Remembered Email: $rememberedEmail');
    Utilities.customPrint('  - Remembered Password: ${rememberedPassword.isNotEmpty ? "***" : "empty"}');
  }

  // Initialize remembered credentials
  void _initializeRememberedCredentials() {
    // Load remembered login preference
    final rememberLogin = Globals.prefs.getBool(SharedPrefsKey.rememberLogin);
    streamRememberLogin.add(rememberLogin);

    if (rememberLogin) {
      final rememberedEmail =
          Globals.prefs.getString(SharedPrefsKey.rememberedEmail);
      final rememberedPassword =
          Globals.prefs.getString(SharedPrefsKey.rememberedPassword);

      if (rememberedEmail.isNotEmpty) {
        controllerEmail.text = rememberedEmail;
      }
      if (rememberedPassword.isNotEmpty) {
        controllerPassword.text = rememberedPassword;
      }
      
      Utilities.customPrint('🔐 Loaded remembered credentials - Email: $rememberedEmail');
    }

    // Hard code credentials for development (can be removed in production)
    // controllerEmail.text = 'nguyenduyandeveloper@gmail.com';
    // controllerPassword.text = 'Abc@12345';
    // streamRememberLogin.add(true);
  }

  // Toggle remember login
  void toggleRememberLogin(bool value) {
    streamRememberLogin.add(value);
    Globals.prefs.setBool(SharedPrefsKey.rememberLogin, value);
    
    Utilities.customPrint('🔐 Remember login toggled: $value');

    if (!value) {
      // Clear remembered credentials if remember login is disabled
      Globals.prefs.setString(SharedPrefsKey.rememberedEmail, '');
      Globals.prefs.setString(SharedPrefsKey.rememberedPassword, '');
      Utilities.customPrint('🔐 Cleared remembered credentials');
    }
  }

  // Email validation
  bool _isValidEmail(String email) {
    return Utilities.validate(RegPattern.email, email);
  }

  // Save credentials if remember login is enabled
  void _saveCredentials() {
    if (streamRememberLogin.value) {
      final email = controllerEmail.text.trim();
      final password = controllerPassword.text.trim();
      
      Globals.prefs.setString(SharedPrefsKey.rememberedEmail, email);
      Globals.prefs.setString(SharedPrefsKey.rememberedPassword, password);
      
      Utilities.customPrint('🔐 Saved credentials - Email: $email');
    } else {
      Utilities.customPrint('🔐 Remember login disabled, not saving credentials');
    }
  }

  Future<void> onLogin(BuildContext context) async {
    // Clear previous error
    streamError.add('');

    // Validate input
    final email = controllerEmail.text.trim();
    final password = controllerPassword.text.trim();

    if (email.isEmpty) {
      streamError.add('Vui lòng nhập email');
      return;
    }

    if (!_isValidEmail(email)) {
      streamError.add('Email không hợp lệ');
      return;
    }

    if (password.isEmpty) {
      streamError.add('Vui lòng nhập mật khẩu');
      return;
    }

    if (password.length < 6) {
      streamError.add('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    try {
      streamIsLoading.add(true);

      // Call API login
      final result = await _loginRepository.login(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        // Save credentials if remember login is enabled
        _saveCredentials();

        // Navigate to Dashboard
        if (context.mounted) {
          Utilities.login(context);
        }
      } else {
        // Show error from API
        streamError.add(result.message ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      streamError.add('Lỗi kết nối: ${e.toString()}');
    } finally {
      streamIsLoading.add(false);
    }
  }

  // Google Sign-In (Enhanced debug version)
  Future<void> onGoogleSignIn(BuildContext context) async {
    try {
      streamIsLoading.add(true);
      streamError.add('');

      // First check config
      Utilities.customPrint('🔐 Checking Google config...');
      final configCheck = await DebugOAuthService.checkGoogleConfig();
      
      if (!configCheck['success']) {
        final issues = (configCheck['issues'] as List<String>).join('\n');
        streamError.add('Config Error:\n$issues');
        return;
      }

      Utilities.customPrint('🔐 Config OK, starting Google Sign-In...');
      final result = await SimpleOAuthService.signInWithGoogle();

      Utilities.customPrint('🔐 Google Sign-In result: $result');

      if (result['success'] == true) {
        Utilities.customPrint('🔐 Google login successful: ${result['email']}');
        
        // Navigate to dashboard on success
        if (context.mounted) {
          Utilities.login(context);
        }
      } else {
        final errorMessage = result['message'] ?? 'Đăng nhập Google thất bại';
        final errorDetails = result['error'] ?? '';
        final rawError = result['rawError'] ?? '';
        
        Utilities.customPrint('❌ Google Sign-In failed: $errorMessage');
        Utilities.customPrint('❌ Error details: $errorDetails');
        Utilities.customPrint('❌ Raw error: $rawError');
        
        // Show detailed error for debugging
        String displayError = errorMessage;
        if (errorDetails.isNotEmpty) {
          displayError += '\n\nChi tiết: $errorDetails';
        }
        if (rawError.isNotEmpty && rawError != errorDetails) {
          displayError += '\n\nRaw: $rawError';
        }
        
        streamError.add(displayError);
      }
    } catch (e) {
      Utilities.customPrint('❌ Google Sign-In exception: $e');
      streamError.add('Exception: ${e.toString()}');
    } finally {
      streamIsLoading.add(false);
    }
  }

  // Azure Sign-In (Real implementation)
  Future<void> onAzureSignIn(BuildContext context) async {
    try {
      streamIsLoading.add(true);
      streamError.add('');

      // First check config
      Utilities.customPrint('🔐 Checking Azure config...');
      final configCheck = await AzureOAuthService.testAzureConfig();
      
      if (!configCheck['success']) {
        final issues = (configCheck['issues'] as List<String>).join('\n');
        streamError.add('Azure Config Error:\n$issues');
        return;
      }

      Utilities.customPrint('🔐 Azure config OK, starting sign-in...');
      final result = await AzureOAuthService.signInWithAzure(context: context);
      if (result.success) {
        if (result.user != null) {
          Utilities.customPrint('🔐 Azure OAuth successful: ${result.user!.email}');
          Utilities.customPrint('🔐 Azure Access Token: ${result.accessToken?.substring(0, 30)}...');
          
          // Call backend API with Azure access token
          if (result.accessToken != null) {
            Utilities.customPrint('🔐 Calling backend API with Azure token...');
            
            final azureLoginRepo = AzureLoginRepository();
            final apiResult = await azureLoginRepo.loginWithAzureToken(
              accessToken: result.accessToken!,
            );
            
            if (apiResult.isSuccess) {
              Utilities.customPrint('✅ Backend API login successful');
              
              // Navigate to dashboard
              if (context.mounted) {
                Utilities.login(context);
              }
            } else {
              streamError.add(apiResult.message ?? 'Lỗi đăng nhập với server');
            }
          } else {
            streamError.add('Không nhận được access token từ Azure');
          }
        } else {
          streamError.add('Không nhận được thông tin người dùng từ Azure');
        }
      } else {
        streamError.add(result.message ?? 'Lỗi đăng nhập Azure');
      }
    } catch (e) {
      Utilities.customPrint('❌ Azure Sign-In exception: $e');
      streamError.add('Exception: ${e.toString()}');
    } finally {
      streamIsLoading.add(false);
    }
  }

  onForgetPassword(BuildContext context) {
    // Show popup notification
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF1890FF),
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Chức năng "Quên mật khẩu" đang trong quá trình phát triển. Vui lòng liên hệ quản trị viên để được hỗ trợ.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1890FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đã hiểu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onSignUp(BuildContext context) async {
    try {
      const signUpUrl = 'https://mom.changmeeting.ai/vi/auth';
      final uri = Uri.parse(signUpUrl);
      
      Utilities.customPrint('🌐 Opening sign up URL: $signUpUrl');
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        // Fallback to external browser if in-app webview fails
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      Utilities.customPrint('❌ Error opening sign up URL: $e');
      
      // Show error dialog if URL launch fails
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lỗi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Không thể mở trang đăng ký. Vui lòng thử lại sau.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1890FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
