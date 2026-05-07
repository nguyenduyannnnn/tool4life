import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/request/login_request_model.dart';
import 'package:changmeeting/data/models/response/login_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class LoginRepository
    extends HttpConnection<BaseResponseModel<LoginResponseModel>> {
  @override
  String get apiUrl => API.login();

  @override
  String? get baseUrl => API.server;

  @override
  Map<String, dynamic>? get bodyParam => _loginRequest?.toJson();

  @override
  Map<String, String>? get headerParam => null;

  @override
  List<MultipartFileModel>? get listFile => null;

  @override
  String get tokenKey => SharedPrefsKey.token;

  LoginRequestModel? _loginRequest;

  Future<BaseResponseModel<LoginResponseModel>> login({
    required String email,
    required String password,
  }) async {
    _loginRequest = LoginRequestModel(
      email: email,
      password: password,
    );

    return await post();
  }

  @override
  BaseResponseModel<LoginResponseModel> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<LoginResponseModel>(
      code: errorCode ?? -1,
      message: error,
      data: null,
    );
  }

  @override
  Future<BaseResponseModel<LoginResponseModel>> handleError(
      BaseResponseModel<LoginResponseModel> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<LoginResponseModel>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonData = json.decode(responseBody);
      final baseResponse = BaseResponseModel<LoginResponseModel>.fromJson(
        jsonData,
        (data) => LoginResponseModel.fromJson(data),
      );

      // Save user data if login successful
      if (baseResponse.isSuccess && baseResponse.data != null) {
        final userData = baseResponse.data!;

        Utilities.customPrint("✅ LOGIN: Login successful for user ${userData.email}");

        // Save complete user data as JSON string
        await Globals.prefs.setString(
          SharedPrefsKey.userData, 
          json.encode(userData.toJson())
        );

        // Save user ID
        if (userData.id != null) {
          await Globals.prefs.setString(SharedPrefsKey.userId, userData.id!);
        }

        // Save user email
        if (userData.email != null) {
          await Globals.prefs.setString(SharedPrefsKey.userEmail, userData.email!);
        }

        // Save user name
        if (userData.name != null) {
          await Globals.prefs.setString(SharedPrefsKey.userName, userData.name!);
        }

        // Save user role
        if (userData.role != null) {
          await Globals.prefs.setString(SharedPrefsKey.userRole, userData.role!);
        }

        // Save tokens if available
        if (userData.accessToken != null) {
          await Globals.prefs.setString(SharedPrefsKey.token, userData.accessToken!);
        }
        if (userData.refreshToken != null) {
          await Globals.prefs.setString(SharedPrefsKey.refreshToken, userData.refreshToken!);
        }

        // Save user locale
        if (userData.locale != null) {
          await Globals.prefs.setString(SharedPrefsKey.userLocale, userData.locale!);
        }

        // Save profile picture
        if (userData.profilePicture != null) {
          await Globals.prefs.setString(SharedPrefsKey.profilePicture, userData.profilePicture!);
        }

        // Update Globals
        Globals.model = userData;
        Globals.isLoggedIn = true;

        Utilities.customPrint("✅ LOGIN: User data saved successfully");
        Utilities.customPrint("✅ LOGIN: Token: ${userData.accessToken?.substring(0, 20)}...");
        Utilities.customPrint("✅ LOGIN: Refresh Token: ${userData.refreshToken?.substring(0, 20)}...");
      }

      return baseResponse;
    } catch (e) {
      return getError('Failed to parse response: $e');
    }
  }
}
