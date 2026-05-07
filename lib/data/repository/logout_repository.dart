import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class LogoutRepository
    extends HttpConnection<BaseResponseModel<Map<String, dynamic>>> {
  @override
  String get apiUrl => API.logout();

  @override
  String? get baseUrl => API.server;

  @override
  Map<String, dynamic>? get bodyParam => null; // Logout không cần body

  @override
  Map<String, String>? get headerParam => null;

  @override
  List<MultipartFileModel>? get listFile => null;

  @override
  String get tokenKey => SharedPrefsKey.token;

  Future<BaseResponseModel<Map<String, dynamic>>> performLogout() async {
    try {
      Utilities.customPrint("🚪 LOGOUT: Starting logout process...");

      final result = await post();

      // Force logout regardless of API response
      if (result.isSuccess) {
        Utilities.customPrint("✅ LOGOUT: API logout successful");
      } else {
        Utilities.customPrint(
            "⚠️ LOGOUT: API failed but continuing with force logout");
      }

      // Always clear user data
      await Utilities.clearUserData();

      return result;
    } catch (e) {
      Utilities.customPrint(
          "❌ LOGOUT: API error but continuing with force logout - ${e.toString()}");

      // Force logout even if API fails
      await Utilities.clearUserData();

      return BaseResponseModel<Map<String, dynamic>>(
        code: 0, // Return success even if API failed
        message: "Logout completed (force)",
        data: {},
      );
    }
  }

  @override
  BaseResponseModel<Map<String, dynamic>> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<Map<String, dynamic>>(
      code: errorCode ?? -1,
      message: error,
      data: null,
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> handleError(
      BaseResponseModel<Map<String, dynamic>> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonData = json.decode(responseBody);
      final baseResponse = BaseResponseModel<Map<String, dynamic>>.fromJson(
        jsonData,
        (data) => data,
      );

      return baseResponse;
    } catch (e) {
      return getError('Failed to parse response: $e');
    }
  }
}
