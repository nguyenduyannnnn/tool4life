import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/models/meeting_file_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/network/http/http_connection.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class MeetingFilesRepository
    extends HttpConnection<BaseResponseModel<MeetingFilesResponse>> {
  final String meetingId;

  MeetingFilesRepository({required this.meetingId});

  @override
  String get apiUrl => API.getMeetingFiles(meetingId);

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

  Future<BaseResponseModel<MeetingFilesResponse>> getMeetingFiles() async {
    return await get();
  }

  @override
  BaseResponseModel<MeetingFilesResponse> getError(String? error,
      {int? errorCode}) {
    return BaseResponseModel<MeetingFilesResponse>(
      code: errorCode ?? -1,
      message: error ?? 'Lỗi tải danh sách tập tin',
      data: null,
    );
  }

  BaseResponseModel<MeetingFilesResponse> parseResponse(String response) {
    try {
      final data = json.decode(response);
      final filesResponse = MeetingFilesResponse.fromJson(data);

      if (filesResponse.errorCode == API.successCode) {
        return BaseResponseModel<MeetingFilesResponse>(
          code: filesResponse.errorCode,
          message: filesResponse.message,
          data: filesResponse,
        );
      } else {
        return BaseResponseModel<MeetingFilesResponse>(
          code: filesResponse.errorCode,
          message: filesResponse.message,
          data: null,
        );
      }
    } catch (e) {
      Utilities.customPrint('❌ Error parsing meeting files response: $e');
      return getError('Lỗi xử lý dữ liệu');
    }
  }

  @override
  Future<BaseResponseModel<MeetingFilesResponse>> handleError(
      BaseResponseModel<MeetingFilesResponse> model) async {
    return model;
  }

  @override
  Future<BaseResponseModel<MeetingFilesResponse>> handleResponse(
      http.Response? response) async {
    if (response == null) {
      return getError('Response is null');
    }

    try {
      final jsonData = utf8.decode(response.bodyBytes);
      final data = json.decode(jsonData);
      final filesResponse = MeetingFilesResponse.fromJson(data);

      if (filesResponse.errorCode == API.successCode) {
        return BaseResponseModel<MeetingFilesResponse>(
          code: filesResponse.errorCode,
          message: filesResponse.message,
          data: filesResponse,
        );
      } else {
        return BaseResponseModel<MeetingFilesResponse>(
          code: filesResponse.errorCode,
          message: filesResponse.message,
          data: null,
        );
      }
    } catch (e) {
      Utilities.customPrint('❌ Error parsing meeting files response: $e');
      return getError('Lỗi xử lý dữ liệu');
    }
  }
}
