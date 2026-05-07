import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/meeting_transcript_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class MeetingTranscriptsRepository
    extends HttpConnection<BaseResponseModel<MeetingTranscriptsApiResponse>> {
  final String meetingId;

  MeetingTranscriptsRepository({
    required this.meetingId,
  });

  @override
  String get apiUrl => API.getMeetingTranscripts(meetingId);

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

  Future<BaseResponseModel<MeetingTranscriptsApiResponse>>
      getMeetingTranscripts() async {
    try {
      Utilities.customPrint(
          "🎙️ MEETING TRANSCRIPTS API: Loading meeting transcripts for meeting ID: $meetingId");

      // Check token availability
      final token = Globals.prefs.getString(tokenKey);
      final fullUrl = "$baseUrl$apiUrl";
      Utilities.customPrint("🎙️ DEBUG: Token available = ${token.isNotEmpty}");
      Utilities.customPrint("🎙️ DEBUG: Full URL = $fullUrl");
      Utilities.customPrint("🎙️ DEBUG: Meeting ID = $meetingId");
      if (token.isNotEmpty) {
        Utilities.customPrint(
            "🎙️ DEBUG: Token first 20 chars = ${token.length > 20 ? token.substring(0, 20) : token}...");
      }

      return await get();
    } catch (e) {
      Utilities.customPrint("🎙️ ERROR in getMeetingTranscripts: $e");
      rethrow;
    }
  }

  @override
  BaseResponseModel<MeetingTranscriptsApiResponse> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<MeetingTranscriptsApiResponse>(
      code: errorCode ?? -1,
      message: error,
      data: null,
    );
  }

  @override
  Future<BaseResponseModel<MeetingTranscriptsApiResponse>> handleError(
      BaseResponseModel<MeetingTranscriptsApiResponse> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<MeetingTranscriptsApiResponse>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    Utilities.customPrint(
        "🎙️ Transcript API Response Status: ${response.statusCode}");
    Utilities.customPrint(
        "🎙️ Transcript API Response Headers: ${response.headers}");

    try {
      // Decode response body with UTF-8 encoding
      final String responseBody = utf8.decode(response.bodyBytes);
      Utilities.customPrint(
          "🎙️ Raw transcript response (first 500 chars): ${responseBody.length > 500 ? responseBody.substring(0, 500) + '...' : responseBody}");

      // Check if response is HTML (error page)
      if (responseBody.trim().startsWith('<!DOCTYPE') ||
          responseBody.trim().startsWith('<html')) {
        Utilities.customPrint(
            "🎙️ DEBUG: Received HTML response instead of JSON - likely endpoint error");
        return getError(
            'API endpoint returned HTML instead of JSON. Please check the endpoint URL.');
      }

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);
      Utilities.customPrint(
          "🎙️ Parsed transcript JSON response keys: ${jsonResponse.keys.toList()}");

      if (response.statusCode == 200) {
        final transcriptsResponse =
            MeetingTranscriptsApiResponse.fromJson(jsonResponse);
        Utilities.customPrint(
            "🎙️ Successfully parsed ${transcriptsResponse.data.length} transcript(s)");

        if (transcriptsResponse.data.isNotEmpty) {
          final firstTranscript = transcriptsResponse.data.first;
          Utilities.customPrint(
              "🎙️ First transcript ID: ${firstTranscript.id}");
          Utilities.customPrint(
              "🎙️ First transcript processing status: ${firstTranscript.processingStatus}");
          Utilities.customPrint(
              "🎙️ First transcript content length: ${firstTranscript.textContent.length}");
        }

        return BaseResponseModel<MeetingTranscriptsApiResponse>(
          code: 0,
          message: "Success",
          data: transcriptsResponse,
        );
      } else {
        Utilities.customPrint(
            "🎙️ ERROR: Non-200 status code: ${response.statusCode}");
        return getError(
            'Failed to load meeting transcripts: ${response.statusCode}');
      }
    } catch (e) {
      Utilities.customPrint("🎙️ ERROR parsing transcript response: $e");
      return getError('Error parsing transcript response: $e');
    }
  }
}
