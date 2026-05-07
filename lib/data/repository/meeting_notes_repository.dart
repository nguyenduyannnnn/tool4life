import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/meeting_note_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class MeetingNotesRepository extends HttpConnection<
    BaseResponseModel<List<MeetingNoteByTranscriptResponse>>> {
  final String transcriptId;

  MeetingNotesRepository({
    required this.transcriptId,
  });

  @override
  String get apiUrl => API.getMeetingNotesByTranscript(transcriptId);

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

  Future<BaseResponseModel<List<MeetingNoteByTranscriptResponse>>>
      getMeetingNotesByTranscript() async {
    try {
      Utilities.customPrint(
          "📋 MEETING NOTES API: Loading meeting notes for transcript ID: $transcriptId");

      // Check token availability
      final token = Globals.prefs.getString(tokenKey);
      final fullUrl = "$baseUrl$apiUrl";
      Utilities.customPrint("📋 DEBUG: Token available = ${token.isNotEmpty}");
      Utilities.customPrint("📋 DEBUG: Full URL = $fullUrl");
      Utilities.customPrint("📋 DEBUG: Transcript ID = $transcriptId");
      Utilities.customPrint("📋 DEBUG: Using query parameter include_items=true");
      if (token.isNotEmpty) {
        Utilities.customPrint(
            "📋 DEBUG: Token preview = ${token.substring(0, token.length.clamp(0, 20))}...");
      }

      final result = await get();

      Utilities.customPrint(
          "📋 DEBUG: Meeting notes API response success = ${result.isSuccess}");
      Utilities.customPrint("📋 DEBUG: Meeting notes error code = ${result.code}");
      Utilities.customPrint("📋 DEBUG: Meeting notes message = ${result.message}");

      if (result.data != null) {
        Utilities.customPrint("📋 DEBUG: Notes count = ${result.data!.length}");
        if (result.data!.isNotEmpty) {
          final latestNote =
              MeetingNoteByTranscriptResponse.getLatestNote(result.data!);
          Utilities.customPrint("📋 DEBUG: Latest note version = ${latestNote?.version}");
          Utilities.customPrint(
              "📋 DEBUG: Latest note content length = ${latestNote?.content.text.length ?? 0}");
          Utilities.customPrint(
              "📋 DEBUG: Latest note content preview = ${latestNote != null ? latestNote.content.text.substring(0, latestNote.content.text.length.clamp(0, 100)) : ''}...");
        }
      }

      if (result.isSuccess) {
        Utilities.customPrint(
            "✅ MEETING NOTES API: Successfully loaded ${result.data?.length ?? 0} meeting notes for transcript $transcriptId");
      } else {
        Utilities.customPrint(
            "❌ MEETING NOTES API: Failed to load meeting notes - ${result.message}");
      }

      return result;
    } catch (e) {
      Utilities.customPrint("❌ MEETING NOTES API: Exception - ${e.toString()}");

      return BaseResponseModel<List<MeetingNoteByTranscriptResponse>>(
        code: -1,
        message: "Failed to load meeting notes: ${e.toString()}",
        data: null,
      );
    }
  }

  @override
  BaseResponseModel<List<MeetingNoteByTranscriptResponse>> getError(
      String? error,
      {int? errorCode}) {
    return BaseResponseModel<List<MeetingNoteByTranscriptResponse>>(
      code: errorCode ?? -1,
      message: error,
      data: null,
    );
  }

  @override
  Future<BaseResponseModel<List<MeetingNoteByTranscriptResponse>>> handleError(
      BaseResponseModel<List<MeetingNoteByTranscriptResponse>> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<List<MeetingNoteByTranscriptResponse>>>
      handleResponse(http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      Utilities.customPrint("📋 DEBUG: Response status = ${response.statusCode}");
      Utilities.customPrint("📋 DEBUG: Response headers = ${response.headers}");
      Utilities.customPrint("📋 DEBUG: Raw response body length = ${response.body.length}");

      // Always use UTF-8 decoding for proper Vietnamese character support
      final String responseBody = utf8.decode(response.bodyBytes);
      Utilities.customPrint("📋 DEBUG: Used UTF-8 decode");

      Utilities.customPrint(
          "📋 DEBUG: Response body preview = ${responseBody.substring(0, responseBody.length.clamp(0, 300))}...");

      // Check if response is HTML (error page)
      if (responseBody.trim().startsWith('<!DOCTYPE') ||
          responseBody.trim().startsWith('<html')) {
        Utilities.customPrint(
            "📋 DEBUG: Received HTML response instead of JSON - likely endpoint error");
        return getError(
            'API endpoint returned HTML instead of JSON. Please check the endpoint URL.');
      }

      final dynamic jsonData = json.decode(responseBody);
      Utilities.customPrint("📋 DEBUG: JSON parsed successfully");

      // Handle different response formats
      BaseResponseModel<List<MeetingNoteByTranscriptResponse>> baseResponse;

      if (jsonData is List) {
        // Direct array response
        final List<MeetingNoteByTranscriptResponse> notes = jsonData
            .map((item) => MeetingNoteByTranscriptResponse.fromJson(item))
            .toList();

        baseResponse = BaseResponseModel<List<MeetingNoteByTranscriptResponse>>(
          code: 0,
          message: "Success",
          data: notes,
        );
      } else if (jsonData is Map<String, dynamic>) {
        // Wrapped response
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          final List<MeetingNoteByTranscriptResponse> notes =
              (jsonData['data'] as List)
                  .map((item) => MeetingNoteByTranscriptResponse.fromJson(item))
                  .toList();

          baseResponse =
              BaseResponseModel<List<MeetingNoteByTranscriptResponse>>(
            code: jsonData['code'] ?? 0,
            message: jsonData['message'] ?? "Success",
            data: notes,
          );
        } else {
          // Single item response, wrap in array
          final note = MeetingNoteByTranscriptResponse.fromJson(jsonData);
          baseResponse =
              BaseResponseModel<List<MeetingNoteByTranscriptResponse>>(
            code: 0,
            message: "Success",
            data: [note],
          );
        }
      } else {
        return getError('Invalid response format');
      }

      // Sort notes by version (latest first)
      if (baseResponse.data != null) {
        baseResponse = BaseResponseModel<List<MeetingNoteByTranscriptResponse>>(
          code: baseResponse.code,
          message: baseResponse.message,
          data:
              MeetingNoteByTranscriptResponse.sortByVersion(baseResponse.data!),
        );
      }

      return baseResponse;
    } catch (e) {
      Utilities.customPrint("📋 DEBUG: JSON parsing error = $e");
      return getError('Failed to parse meeting notes response: $e');
    }
  }
}
