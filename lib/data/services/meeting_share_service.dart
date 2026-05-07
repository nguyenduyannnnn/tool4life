import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/services/auth_storage_service.dart';
import 'package:changmeeting/data/network/api/api.dart';

class MeetingShareService {
  static Future<ShareResult> shareMeetingNotes(String meetingId, String meetingTitle) async {
    try {
      Utilities.customPrint('📤 Starting share meeting notes for ID: $meetingId');
      
      // Get access token from storage
      final accessToken = await AuthStorageService.getAccessToken();
      if (accessToken == null) {
        return ShareResult(
          success: false,
          message: 'Không tìm thấy access token. Vui lòng đăng nhập lại.',
        );
      }
      
      // Build URL using API pattern
      final endpoint = API.downloadMeetingNotes(meetingId);
      final url = '${API.server}$endpoint';
      Utilities.customPrint('📤 Share download URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json, text/plain, */*',
        },
      );
      
      Utilities.customPrint('📤 Share download response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        String errorMessage = 'Lỗi tải file để chia sẻ: ${response.statusCode}';
        if (response.statusCode == 401) {
          errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Không tìm thấy file ghi chú cuộc họp.';
        }
        
        return ShareResult(
          success: false,
          message: errorMessage,
        );
      }
      
      // Get temporary directory for sharing
      final tempDir = await getTemporaryDirectory();
      
      // Generate filename for sharing
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'meeting_notes_${meetingId}_$timestamp.pdf';
      final filePath = '${tempDir.path}/$filename';
      
      // Save file temporarily
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      Utilities.customPrint('📤 Temporary file created for sharing: $filePath');
      
      // Share the file
      final shareText = 'Ghi chú cuộc họp: $meetingTitle';
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
        subject: 'Meeting Notes - $meetingTitle',
      );
      
      Utilities.customPrint('📤 Share result: ${result.status}');
      
      // Clean up temporary file after a delay
      Future.delayed(const Duration(seconds: 30), () {
        try {
          if (file.existsSync()) {
            file.deleteSync();
            Utilities.customPrint('📤 Temporary file cleaned up');
          }
        } catch (e) {
          Utilities.customPrint('⚠️ Failed to clean up temporary file: $e');
        }
      });
      
      return ShareResult(
        success: true,
        message: 'Chia sẻ thành công',
        shareStatus: result.status,
      );
      
    } catch (e) {
      Utilities.customPrint('❌ Share error: $e');
      return ShareResult(
        success: false,
        message: 'Lỗi chia sẻ file: ${e.toString()}',
      );
    }
  }
}

class ShareResult {
  final bool success;
  final String message;
  final ShareResultStatus? shareStatus;
  
  ShareResult({
    required this.success,
    required this.message,
    this.shareStatus,
  });
}