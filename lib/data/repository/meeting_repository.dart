import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/response/meetings_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class MeetingRepository
    extends HttpConnection<BaseResponseModel<MeetingsResponseModel>> {
  final int page;
  final int pageSize;
  final DateTime? startDate;
  final DateTime? endDate;

  MeetingRepository({
    required this.page,
    required this.pageSize,
    this.startDate,
    this.endDate,
  });

  @override
  String get apiUrl {
    String url = "${API.getMeetings()}?page=$page&page_size=$pageSize";
    
    if (startDate != null) {
      final startDateStr = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
      url += '&start_date=$startDateStr';
    }
    
    if (endDate != null) {
      final endDateStr = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
      url += '&end_date=$endDateStr';
    }
    
    return url;
  }

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

  Future<BaseResponseModel<MeetingsResponseModel>> getMeetings() async {
    try {
      Utilities.customPrint(
          "📡 MEETING API: Loading meetings page $page, size $pageSize");
      Utilities.customPrint("📡 DEBUG: Full URL = $baseUrl$apiUrl");

      // Check token availability
      final token = Globals.prefs.getString(tokenKey);
      Utilities.customPrint("📡 DEBUG: Token available = ${token.isNotEmpty}");
      Utilities.customPrint("📡 DEBUG: Token length = ${token.length}");
      if (token.isNotEmpty) {
        Utilities.customPrint(
            "📡 DEBUG: Token preview = ${token.substring(0, token.length.clamp(0, 20))}...");
      }

      final result = await get();

      Utilities.customPrint("📡 DEBUG: Raw API response success = ${result.isSuccess}");
      Utilities.customPrint("📡 DEBUG: Raw error code = ${result.code}");
      Utilities.customPrint("📡 DEBUG: Raw message = ${result.message}");
      Utilities.customPrint("📡 DEBUG: Data items count = ${result.data?.items.length ?? 0}");

      if (result.data?.items.isNotEmpty == true) {
        Utilities.customPrint(
            "📡 DEBUG: First meeting title = '${result.data!.items.first.title}'");
        Utilities.customPrint(
            "📡 DEBUG: First meeting type = '${result.data!.items.first.type}'");
      }

      if (result.isSuccess) {
        Utilities.customPrint(
            "✅ MEETING API: Successfully loaded ${result.data?.items.length ?? 0} meetings");
      } else {
        Utilities.customPrint(
            "❌ MEETING API: Failed to load meetings - ${result.message}");
      }

      return result;
    } catch (e) {
      Utilities.customPrint("❌ MEETING API: Exception - ${e.toString()}");

      return BaseResponseModel<MeetingsResponseModel>(
        code: -1,
        message: "Failed to load meetings: ${e.toString()}",
        data: null,
      );
    }
  }

  @override
  BaseResponseModel<MeetingsResponseModel> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<MeetingsResponseModel>(
      code: errorCode ?? -1,
      message: error,
      data: null,
    );
  }

  @override
  Future<BaseResponseModel<MeetingsResponseModel>> handleError(
      BaseResponseModel<MeetingsResponseModel> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<MeetingsResponseModel>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      Utilities.customPrint("📡 DEBUG: Response status = ${response.statusCode}");
      Utilities.customPrint("📡 DEBUG: Response headers = ${response.headers}");
      Utilities.customPrint("📡 DEBUG: Raw response body length = ${response.body.length}");

      // Always use UTF-8 decoding for proper Vietnamese character support
      final String responseBody = utf8.decode(response.bodyBytes);
      Utilities.customPrint("📡 DEBUG: Used UTF-8 decode");

      Utilities.customPrint(
          "📡 DEBUG: Response body preview = ${responseBody.substring(0, responseBody.length.clamp(0, 200))}...");

      final Map<String, dynamic> jsonData = json.decode(responseBody);
      Utilities.customPrint("📡 DEBUG: JSON parsed successfully");

      final baseResponse = BaseResponseModel<MeetingsResponseModel>.fromJson(
        jsonData,
        (data) => MeetingsResponseModel.fromJson(data),
      );

      return baseResponse;
    } catch (e) {
      Utilities.customPrint("📡 DEBUG: JSON parsing error = $e");
      return getError('Failed to parse meetings response: $e');
    }
  }
}
