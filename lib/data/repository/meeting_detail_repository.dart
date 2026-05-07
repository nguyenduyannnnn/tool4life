import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/meeting_detail_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class MeetingDetailRepository
    extends HttpConnection<BaseResponseModel<MeetingDetailModel>> {
  final String meetingId;

  MeetingDetailRepository({
    required this.meetingId,
  });

  @override
  String get apiUrl => API.getMeetingDetail(meetingId);

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

  Future<BaseResponseModel<MeetingDetailModel>> getMeetingDetail() async {
    try {
      Utilities.customPrint(
          "📄 MEETING DETAIL API: Loading meeting detail for ID: $meetingId");

      // Check token availability
      final token = Globals.prefs.getString(tokenKey);
      Utilities.customPrint("📄 DEBUG: Token available = ${token.isNotEmpty}");
      Utilities.customPrint("📄 DEBUG: Full URL = $baseUrl$apiUrl");
      if (token.isNotEmpty) {
        Utilities.customPrint(
            "📄 DEBUG: Token preview = ${token.substring(0, token.length.clamp(0, 20))}...");
      }

      final result = await get();

      Utilities.customPrint(
          "📄 DEBUG: Meeting detail API response success = ${result.isSuccess}");
      Utilities.customPrint("📄 DEBUG: Meeting detail error code = ${result.code}");
      Utilities.customPrint("📄 DEBUG: Meeting detail message = ${result.message}");

      if (result.data != null) {
        Utilities.customPrint("📄 DEBUG: Meeting title = '${result.data!.title}'");
        Utilities.customPrint("📄 DEBUG: Meeting status = '${result.data!.status}'");
        Utilities.customPrint("📄 DEBUG: Organizer = '${result.data!.organizerName ?? 'N/A'}'");
      }

      if (result.isSuccess) {
        Utilities.customPrint(
            "✅ MEETING DETAIL API: Successfully loaded meeting detail for $meetingId");
      } else {
        Utilities.customPrint(
            "❌ MEETING DETAIL API: Failed to load meeting detail - ${result.message}");
      }

      return result;
    } catch (e) {
      Utilities.customPrint(
          "❌ MEETING DETAIL API: Exception - ${e.toString()}");

      return BaseResponseModel<MeetingDetailModel>(
        code: -1,
        message: "Failed to load meeting detail: ${e.toString()}",
        data: null,
      );
    }
  }

  @override
  BaseResponseModel<MeetingDetailModel> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<MeetingDetailModel>(
      code: errorCode ?? -1,
      message: error,
      data: null,
    );
  }

  @override
  Future<BaseResponseModel<MeetingDetailModel>> handleError(
      BaseResponseModel<MeetingDetailModel> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<MeetingDetailModel>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      Utilities.customPrint("📄 DEBUG: Response status = ${response.statusCode}");
      Utilities.customPrint("📄 DEBUG: Response headers = ${response.headers}");
      Utilities.customPrint("📄 DEBUG: Raw response body length = ${response.body.length}");

      // Always use UTF-8 decoding for proper Vietnamese character support
      final String responseBody = utf8.decode(response.bodyBytes);
      Utilities.customPrint("📄 DEBUG: Used UTF-8 decode");

      Utilities.customPrint(
          "📄 DEBUG: Response body preview = ${responseBody.substring(0, responseBody.length.clamp(0, 300))}...");

      final Map<String, dynamic> jsonData = json.decode(responseBody);
      Utilities.customPrint("📄 DEBUG: JSON parsed successfully");

      final baseResponse = BaseResponseModel<MeetingDetailModel>.fromJson(
        jsonData,
        (data) => MeetingDetailModel.fromJson(data),
      );

      return baseResponse;
    } catch (e) {
      Utilities.customPrint("📄 DEBUG: JSON parsing error = $e");
      return getError('Failed to parse meeting detail response: $e');
    }
  }
}


