import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:changmeeting/common/constant.dart';
import 'package:changmeeting/common/utils/custom_navigator.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:changmeeting/presentation/modules/authen_module/src/ui/login_screen.dart';
import 'package:changmeeting/presentation/modules/dashboard/src/ui/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import 'globals.dart';
import 'theme.dart';

class Utilities {
  static changeStatusBarColor(Color color, bool isDark) {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: color,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            statusBarIconBrightness:
                isDark ? Brightness.dark : Brightness.light));
      } else {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: color,
            statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark));
      }
    }
  }

  static restartApp(BuildContext context) {
    // Globals.myApp.currentState?.onRefresh();
  }

  static closeApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  static hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static fieldFocus(BuildContext context, FocusNode? focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  static toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primary,
        textColor: AppColors.white);
  }

  static copyText(BuildContext context, String text,
      {String message = "Copied to Clipboard"}) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      toast(message);
    });
  }

  static launch(String? url) {
    if ((url ?? "").isEmpty) {
      return;
    }
    urlLauncher.launchUrl(
      Uri.parse(url!),
      mode: urlLauncher.LaunchMode.externalApplication,
    );
  }

  static callPhone(String? phone) {
    launch("tel:" + (phone ?? "").trim());
  }

  static sendSMS(String? phone) {
    launch("sms:" + (phone ?? "").trim());
  }

  static googleMap(String? lat, String? lng) async {
    launch(
        "https://www.google.com/maps/search/${lat ?? "0.0"},${lng ?? "0.0"}");
  }

  static String jsonToString(dynamic event) {
    return json.encode(event);
  }

  static dynamic stringToJson(String? event) {
    if (event == null) return null;
    return json.decode(event);
  }

  static String formatDate(DateTime? event, {DateFormat? format}) {
    if (event == null) {
      return "";
    }

    return (format ?? AppFormat.date).format(event);
  }

  static DateTime? parseDate(String? event, {DateFormat? parse}) {
    if ((event ?? "").isEmpty) {
      return null;
    }

    return (parse ?? AppFormat.dateResponse).parse(event!);
  }

  static String parseAndFormatDate(String? event,
      {DateFormat? format, DateFormat? parse}) {
    if ((event ?? "").isEmpty) {
      return "";
    }

    return formatDate(parseDate(event));
  }

  static String formatMoney(double? event, {NumberFormat? format}) {
    if (event == null) {
      return "";
    }

    return (format ?? AppFormat.money).format(event);
  }

  static double parseMoney(String? event,
      {NumberFormat? parse, double defaultValue = 0.0}) {
    if ((event ?? "").isEmpty) {
      return defaultValue;
    }

    return (parse ?? AppFormat.money).parse(event!) as double? ?? defaultValue;
  }

  static Color parseColor(String? event,
      {Color defaultColor = AppColors.black}) {
    if ((event ?? "").isEmpty) {
      return defaultColor;
    }
    String value = event!.replaceAll("#", "");
    if (value.length == 6) {
      value = "FF" + value;
    }
    try {
      return Color(int.tryParse(value, radix: 16)!);
    } catch (_) {
      return defaultColor;
    }
  }

  static customPrint(dynamic event) {
    if (Globals.config.displayPrint!) {
      log(event.toString());
    }
  }

  static String getCountryPhone(String phone) {
    return "+${Globals.streamCountryModel.value.countryCode} ${phone.startsWith("0") ? phone.substring(1) : phone}";
  }

  static bool validate(RegPattern pattern, String event) {
    return RegExp(pattern.value).hasMatch(event);
  }

  static bool hasValidUserData() {
    final userData = Globals.prefs.getString(SharedPrefsKey.userData);
    final accessToken = Globals.prefs.getString(SharedPrefsKey.token);
    final refreshToken = Globals.prefs.getString(SharedPrefsKey.refreshToken);

    final hasData = userData.isNotEmpty &&
        accessToken.isNotEmpty &&
        refreshToken.isNotEmpty;
    customPrint("🔍 CHECK: User data validation - $hasData");

    return hasData;
  }

  static login(BuildContext context) {
    Globals.isLoggedIn = true;
    CustomNavigator.popToRootAndPushReplacement(context, DashboardScreen());
  }

  static Future<void> clearUserData() async {
    customPrint("🗑️ CLEARING: User data and tokens...");

    // Clear tokens
    await Globals.prefs.removeKey(SharedPrefsKey.token);
    await Globals.prefs.removeKey(SharedPrefsKey.refreshToken);

    // Clear user data
    await Globals.prefs.removeKey(SharedPrefsKey.userData);
    await Globals.prefs.removeKey(SharedPrefsKey.userId);
    await Globals.prefs.removeKey(SharedPrefsKey.userEmail);
    await Globals.prefs.removeKey(SharedPrefsKey.userName);
    await Globals.prefs.removeKey(SharedPrefsKey.userRole);
    await Globals.prefs.removeKey(SharedPrefsKey.userLocale);
    await Globals.prefs.removeKey(SharedPrefsKey.fishBalance);
    await Globals.prefs.removeKey(SharedPrefsKey.staffId);

    // Clear global state
    Globals.model = null;
    Globals.isLoggedIn = false;
    Globals.bloc = null;

    customPrint("✅ CLEARED: All user data removed");
  }

  static Future<void> logout(BuildContext context) async {
    await clearUserData();
    customPrint("🚪 NAVIGATE: LoginScreen");
    CustomNavigator.popToRootAndPushReplacement(context, LoginScreen());
  }
}
