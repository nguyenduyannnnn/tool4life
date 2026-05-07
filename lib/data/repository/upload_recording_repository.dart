import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class UploadRecordingRepository {
  Future<BaseResponseModel<Map<String, dynamic>>> uploadAudio({
    required File audioFile,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final token = Globals.prefs.getString(SharedPrefsKey.token);
      final url = Uri.parse('${API.server}${API.uploadAudioRecording()}');

      // Verify file exists and is readable
      if (!await audioFile.exists()) {
        throw Exception('File does not exist: ${audioFile.path}');
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Read file as bytes
      final fileBytes = await audioFile.readAsBytes();
      final fileLength = fileBytes.length;

      Utilities.customPrint("📤 UPLOAD: File size: $fileLength bytes");

      // Add file as multipart
      final multipartFile = http.MultipartFile.fromBytes(
        'audio_file', // Field name from API - changed from 'file' to 'audio_file'
        fileBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);

      // Send request
      Utilities.customPrint("📤 UPLOAD: Sending request...");
      final streamedResponse = await request.send();

      // Collect response bytes and track progress
      final responseBytes = <int>[];
      
      await for (var chunk in streamedResponse.stream) {
        responseBytes.addAll(chunk);
        
        // Estimate progress (upload is done, this is download response)
        // We'll report 100% since upload is complete when we get here
        onProgress?.call(1.0);
      }

      final responseBody = utf8.decode(responseBytes);

      Utilities.customPrint("📤 UPLOAD: Response status: ${streamedResponse.statusCode}");
      Utilities.customPrint("📤 UPLOAD: Response body: $responseBody");

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(responseBody);
        
        return BaseResponseModel<Map<String, dynamic>>(
          code: jsonData['error_code'] ?? jsonData['code'] ?? 0,
          message: jsonData['message'] ?? 'Upload thành công',
          data: jsonData['data'] ?? jsonData,
        );
      } else {
        return BaseResponseModel<Map<String, dynamic>>(
          code: streamedResponse.statusCode,
          message: 'Upload failed: ${streamedResponse.statusCode} - $responseBody',
          data: null,
        );
      }
    } catch (e) {
      Utilities.customPrint("📤 UPLOAD: Exception - ${e.toString()}");
      return BaseResponseModel<Map<String, dynamic>>(
        code: -1,
        message: "Upload failed: ${e.toString()}",
        data: null,
      );
    }
  }
}
