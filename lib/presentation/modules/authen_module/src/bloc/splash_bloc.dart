import 'dart:async';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/constant.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:changmeeting/data/models/base/password_validation_model.dart';
import 'package:changmeeting/data/repository/refresh_token_repository.dart';
import 'package:changmeeting/presentation/modules/authen_module/src/ui/login_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/ui/dashboard_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../common/assets.dart';
import '../../../../../common/globals.dart';
import '../../../../../common/localization/l10n.dart';
import '../../../../../data/models/base/country_model.dart';
import '../../../../base/base_view.dart';
import '../ui/splash_screen.dart';

class SplashBloc extends BaseBloc<SplashScreen> {
  @override
  void onInit() {
    // Initialize country models
    Globals.countryModels = [
      CountryModel(
          countryCode: 84,
          image: Assets.imageFlagVietnam,
          name: LangKey.current.viet_nam),
      CountryModel(
          countryCode: 1,
          image: Assets.imageFlagUsa,
          name: LangKey.current.usa),
    ];
    Globals.streamCountryModel.set(Globals.countryModels.firstWhere((e) =>
        e.countryCode ==
        Globals.prefs.getInt(SharedPrefsKey.country_code,
            value: Globals.countryModels.first.countryCode)));

    // Initialize password validation models
    Globals.passwordValidationModels = [
      PasswordValidationModel(
          title: LangKey.current.validation_password_length,
          regPattern: RegPattern.passwordLength),
      PasswordValidationModel(
          title: LangKey.current.validation_password_lowercase,
          regPattern: RegPattern.lowercase),
      PasswordValidationModel(
          title: LangKey.current.validation_password_uppercase,
          regPattern: RegPattern.uppercase),
      PasswordValidationModel(
          title: LangKey.current.validation_password_number,
          regPattern: RegPattern.number),
      PasswordValidationModel(
          title: LangKey.current.validation_password_special,
          regPattern: RegPattern.special),
    ];
  }

  @override
  void onReady() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final splashStartTime = DateTime.now();

    // Request microphone permission
    // await _requestMicrophonePermission();

    // Check if user data exists and perform auto-login
    await _performAutoLoginCheck();

    // Ensure minimum splash duration for UX
    final elapsedTime = DateTime.now().difference(splashStartTime);
    final minimumSplashDuration = Duration(milliseconds: 500);

    if (elapsedTime < minimumSplashDuration) {
      await Future.delayed(minimumSplashDuration - elapsedTime);
    }
  }

  Future<void> _performAutoLoginCheck() async {
    Utilities.customPrint("🔄 REFRESH: Starting auto-login check");

    if (Utilities.hasValidUserData()) {
      await _attemptTokenRefresh();
    } else {
      Utilities.customPrint("🚪 NAVIGATE: No user data found, going to Login");
      if (mounted) {
        CustomNavigator.pushReplacement(context, LoginScreen());
      }
    }
  }

  Future<void> _attemptTokenRefresh() async {
    try {
      final accessToken = Globals.prefs.getString(SharedPrefsKey.token);
      final refreshToken = Globals.prefs.getString(SharedPrefsKey.refreshToken);

      final refreshRepository = RefreshTokenRepository(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      final result = await refreshRepository.performRefresh();

      if (result.isSuccess) {
        Utilities.customPrint(
            "🚪 NAVIGATE: Auto-login successful, going to Dashboard");
        if (mounted) {
          CustomNavigator.pushReplacement(context, DashboardScreen());
        }
      } else {
        Utilities.customPrint("❌ REFRESH: Token refresh failed, clearing data");
        await Utilities.clearUserData();
        if (mounted) {
          CustomNavigator.pushReplacement(context, LoginScreen());
        }
      }
    } catch (e) {
      Utilities.customPrint(
          "❌ REFRESH: Exception during auto-login - ${e.toString()}");
      await Utilities.clearUserData();
      if (mounted) {
        CustomNavigator.pushReplacement(context, LoginScreen());
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();

      if (status.isGranted) {
        print('Microphone permission granted');
      } else if (status.isDenied) {
        print('Microphone permission denied');
      } else if (status.isPermanentlyDenied) {
        print('Microphone permission permanently denied');
        // Optionally show dialog to open app settings
        _showPermissionDialog();
      }
    } catch (e) {
      print('Error requesting microphone permission: $e');
    }
  }

  void _showPermissionDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Quyền truy cập micro'),
            content: const Text(
              'Ứng dụng cần quyền truy cập micro để ghi âm. '
              'Vui lòng cấp quyền trong cài đặt ứng dụng.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  openAppSettings();
                },
                child: const Text('Mở cài đặt'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void onResumed() {
    // TODO: implement onResumed
  }

  @override
  void onDispose() {
    // Clean up resources if needed
  }
}
