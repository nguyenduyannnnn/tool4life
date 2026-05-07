import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/simple_meeting_note_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class SimpleMeetingNotesRepository
    extends HttpConnection<BaseResponseModel<SimpleMeetingNotesResponse>> {
  final String transcriptId;

  SimpleMeetingNotesRepository({required this.transcriptId});

  @override
  String get apiUrl => API.getNotesByTranscriptId(transcriptId);

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

  Future<BaseResponseModel<SimpleMeetingNotesResponse>> getNotesByTranscriptId() async {
    return await get();
  }

  @override
  BaseResponseModel<SimpleMeetingNotesResponse> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<SimpleMeetingNotesResponse>(
      code: errorCode ?? -1,
      message: error ?? 'Lỗi tải ghi chú cuộc họp',
      data: null,
    );
  }

  BaseResponseModel<SimpleMeetingNotesResponse> parseResponse(String response) {
    try {
      final data = json.decode(response);
      final notesResponse = SimpleMeetingNotesResponse.fromJson(data);

      if (notesResponse.errorCode == API.successCode) {
        return BaseResponseModel<SimpleMeetingNotesResponse>(
          code: notesResponse.errorCode,
          message: notesResponse.message,
          data: notesResponse,
        );
      } else {
        return BaseResponseModel<SimpleMeetingNotesResponse>(
          code: notesResponse.errorCode,
          message: notesResponse.message,
          data: null,
        );
      }
    } catch (e) {
      Utilities.customPrint('❌ Error parsing simple notes response: $e');
      return getError('Lỗi xử lý dữ liệu');
    }
  }

  @override
  Future<BaseResponseModel<SimpleMeetingNotesResponse>> handleError(
      BaseResponseModel<SimpleMeetingNotesResponse> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<SimpleMeetingNotesResponse>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      final jsonData = utf8.decode(response.bodyBytes);
      final data = json.decode(jsonData);
      final notesResponse = SimpleMeetingNotesResponse.fromJson(data);

      if (notesResponse.errorCode == API.successCode) {
        return BaseResponseModel<SimpleMeetingNotesResponse>(
          code: notesResponse.errorCode,
          message: notesResponse.message,
          data: notesResponse,
        );
      } else {
        return BaseResponseModel<SimpleMeetingNotesResponse>(
          code: notesResponse.errorCode,
          message: notesResponse.message,
          data: null,
        );
      }
    } catch (e) {
      Utilities.customPrint('❌ Error parsing simple notes response: $e');
      return getError('Lỗi xử lý dữ liệu');
    }
  }
}
