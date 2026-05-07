import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/request/refresh_token_request_model.dart';
import 'package:changmeeting/data/models/response/login_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class RefreshTokenRepository
    extends HttpConnection<BaseResponseModel<LoginResponseModel>> {
  final String _accessToken;
  final String _refreshToken;

  RefreshTokenRepository({
    required String accessToken,
    required String refreshToken,
  })  : _accessToken = accessToken,
        _refreshToken = refreshToken;

  @override
  String get apiUrl => API.refreshToken();

  @override
  String? get baseUrl => API.server;

  @override
  Map<String, dynamic>? get bodyParam => RefreshTokenRequestModel(
        refreshToken: _refreshToken,
      ).toJson();

  @override
  Map<String, String>? get headerParam => {
        'Authorization': 'Bearer $_accessToken',
      };

  @override
  List<MultipartFileModel>? get listFile => null;

  @override
  String get tokenKey => SharedPrefsKey.token;

  Future<BaseResponseModel<LoginResponseModel>> performRefresh() async {
    try {
      Utilities.customPrint("🔄 REFRESH: Starting token refresh process...");

      final result = await post();

      if (result.isSuccess) {
        Utilities.customPrint("✅ REFRESH: Token refresh successful");
      } else {
        Utilities.customPrint(
            "❌ REFRESH: Token refresh failed - ${result.message}");
      }

      return result;
    } catch (e) {
      Utilities.customPrint(
          "❌ REFRESH: Exception during refresh - ${e.toString()}");

      return BaseResponseModel<LoginResponseModel>(
        code: -1,
        message: "Refresh token failed: ${e.toString()}",
        data: null,
      );
    }
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

      // Save user data if refresh successful
      if (baseResponse.isSuccess && baseResponse.data != null) {
        final userData = baseResponse.data!;

        // Save complete user data as JSON string
        await Globals.prefs.setString(
          SharedPrefsKey.userData, 
          json.encode(userData.toJson())
        );

        // Save tokens
        if (userData.accessToken != null) {
          await Globals.prefs
              .setString(SharedPrefsKey.token, userData.accessToken!);
        }
        if (userData.refreshToken != null) {
          await Globals.prefs
              .setString(SharedPrefsKey.refreshToken, userData.refreshToken!);
        }

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

        // Update Globals
        Globals.model = userData;
        Globals.isLoggedIn = true;

        Utilities.customPrint("✅ REFRESH: Login data updated and saved");
        Utilities.customPrint("✅ REFRESH: New token saved");
      }

      return baseResponse;
    } catch (e) {
      return getError('Failed to parse refresh response: $e');
    }
  }
}


