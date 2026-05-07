import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/request/azure_login_request_model.dart';
import 'package:changmeeting/data/models/response/login_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class AzureLoginRepository
    extends HttpConnection<BaseResponseModel<LoginResponseModel>> {
  @override
  String get apiUrl => API.azureDirectLogin();

  @override
  String? get baseUrl => "https://meeting-agent-api.fpt.net/";

  @override
  Map<String, dynamic>? get bodyParam => _azureLoginRequest?.toJson();

  @override
  Map<String, String>? get headerParam => null;

  @override
  List<MultipartFileModel>? get listFile => null;

  @override
  String get tokenKey => SharedPrefsKey.token;

  AzureLoginRequestModel? _azureLoginRequest;

  Future<BaseResponseModel<LoginResponseModel>> loginWithAzureToken({
    required String accessToken,
  }) async {
    _azureLoginRequest = AzureLoginRequestModel(
      accessToken: accessToken,
    );

    Utilities.customPrint('🔐 ===== AZURE SSO API CALL =====');
    Utilities.customPrint('🔐 Full URL: ${baseUrl}${apiUrl}');
    Utilities.customPrint('🔐 Access Token: ${accessToken.substring(0, 20)}...');
    Utilities.customPrint('🔐 Request Body: ${json.encode(bodyParam)}');

    try {
      final result = await post();
      Utilities.customPrint('🔐 ===== AZURE SSO API RESULT =====');
      return result;
    } catch (e) {
      Utilities.customPrint('❌ AZURE SSO: Exception during API call - $e');
      return getError('API call failed: $e');
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
      Utilities.customPrint('🔐 Response Status: ${response.statusCode}');
      Utilities.customPrint('🔐 Response Headers: ${response.headers}');
      Utilities.customPrint('🔐 Response Body Length: ${responseBody.length}');
      Utilities.customPrint('🔐 Response Body: "$responseBody"');

      // Check if response body is empty
      if (responseBody.isEmpty) {
        Utilities.customPrint('❌ AZURE SSO: Empty response body');
        return getError('Server returned empty response');
      }

      // Check if response is not JSON
      if (!responseBody.trim().startsWith('{') && !responseBody.trim().startsWith('[')) {
        Utilities.customPrint('❌ AZURE SSO: Response is not JSON format');
        Utilities.customPrint('❌ AZURE SSO: Raw response: $responseBody');
        return getError('Server returned non-JSON response: $responseBody');
      }

      final Map<String, dynamic> jsonData = json.decode(responseBody);
      final baseResponse = BaseResponseModel<LoginResponseModel>.fromJson(
        jsonData,
        (data) => LoginResponseModel.fromJson(data),
      );

      // Save user data if login successful
      if (baseResponse.isSuccess && baseResponse.data != null) {
        final userData = baseResponse.data!;

        Utilities.customPrint("✅ AZURE SSO: Login successful for user ${userData.email}");

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

        Utilities.customPrint("✅ AZURE SSO: User data saved successfully");
        Utilities.customPrint("✅ AZURE SSO: Token: ${userData.accessToken?.substring(0, 20)}...");
      }

      return baseResponse;
    } catch (e) {
      Utilities.customPrint('❌ AZURE SSO: Parse error - $e');
      Utilities.customPrint('❌ AZURE SSO: Response status: ${response.statusCode}');
      Utilities.customPrint('❌ AZURE SSO: Response body: "${utf8.decode(response.bodyBytes)}"');
      return getError('Failed to parse response: $e');
    }
  }
}