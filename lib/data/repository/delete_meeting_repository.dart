import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class DeleteMeetingRepository
    extends HttpConnection<BaseResponseModel<Map<String, dynamic>>> {
  final String meetingId;

  DeleteMeetingRepository({
    required this.meetingId,
  });

  @override
  String get apiUrl => API.deleteMeeting(meetingId);

  @override
  String? get baseUrl => API.server;

  @override
  Map<String, dynamic>? get bodyParam => null;

  @override
  Map<String, String>? get headerParam => null;

  @override
  List<MultipartFileModel>? get listFile => null;

  @override
  String get tokenKey => SharedPrefsKey.token;

  Future<BaseResponseModel<Map<String, dynamic>>> deleteMeeting() async {
    try {
      Utilities.customPrint(
          "🗑️ DELETE MEETING: Starting delete for meeting ID: $meetingId");

      // Check token availability
      final token = Globals.prefs.getString(tokenKey);
      Utilities.customPrint("🗑️ DEBUG: Token available = ${token.isNotEmpty}");
      Utilities.customPrint("🗑️ DEBUG: Full URL = $baseUrl$apiUrl");

      final result = await delete();

      Utilities.customPrint("🗑️ DEBUG: Delete API response success = ${result.isSuccess}");
      Utilities.customPrint("🗑️ DEBUG: Delete error code = ${result.code}");
      Utilities.customPrint("🗑️ DEBUG: Delete message = ${result.message}");

      if (result.isSuccess) {
        Utilities.customPrint(
            "✅ DELETE MEETING: Successfully deleted meeting $meetingId");
      } else {
        Utilities.customPrint(
            "❌ DELETE MEETING: Failed to delete meeting - ${result.message}");
      }

      return result;
    } catch (e) {
      Utilities.customPrint("❌ DELETE MEETING: Exception - ${e.toString()}");

      return BaseResponseModel<Map<String, dynamic>>(
        code: -1,
        message: "Failed to delete meeting: ${e.toString()}",
        data: null,
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
      Utilities.customPrint("🗑️ DEBUG: Response status = ${response.statusCode}");
      Utilities.customPrint("🗑️ DEBUG: Response headers = ${response.headers}");
      Utilities.customPrint("🗑️ DEBUG: Raw response body length = ${response.body.length}");

      // Handle UTF-8 decoding properly
      final String responseBody;
      if (response.headers['content-type']?.contains('charset=utf-8') == true) {
        responseBody = utf8.decode(response.bodyBytes);
        Utilities.customPrint("🗑️ DEBUG: Used UTF-8 decode");
      } else {
        responseBody = response.body;
        Utilities.customPrint("🗑️ DEBUG: Used default response.body");
      }

      Utilities.customPrint(
          "🗑️ DEBUG: Response body preview = ${responseBody.substring(0, responseBody.length.clamp(0, 200))}...");

      final Map<String, dynamic> jsonData = json.decode(responseBody);
      Utilities.customPrint("🗑️ DEBUG: JSON parsed successfully");

      final baseResponse = BaseResponseModel<Map<String, dynamic>>.fromJson(
        jsonData,
        (data) => data as Map<String, dynamic>? ?? {},
      );

      return baseResponse;
    } catch (e) {
      Utilities.customPrint("🗑️ DEBUG: JSON parsing error = $e");
      return getError('Failed to parse delete response: $e');
    }
  }
}


