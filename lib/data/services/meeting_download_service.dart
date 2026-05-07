import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/services/auth_storage_service.dart';
import 'package:changmeeting/data/network/api/api.dart';

class MeetingDownloadService {
  static Future<DownloadResult> downloadMeetingNotes(String meetingId) async {
    try {
      Utilities.customPrint('📥 Starting download meeting notes for ID: $meetingId');
      
      // Get access token from storage
      final accessToken = await AuthStorageService.getAccessToken();
      if (accessToken == null) {
        return DownloadResult(
          success: false,
          message: 'Không tìm thấy access token. Vui lòng đăng nhập lại.',
        );
      }
      
      // Request storage permission
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        return DownloadResult(
          success: false,
          message: 'Cần cấp quyền truy cập bộ nhớ để tải file.',
        );
      }
      
      // Build URL using API pattern
      final endpoint = API.downloadMeetingNotes(meetingId);
      final url = '${API.server}$endpoint';
      Utilities.customPrint('📥 Download URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json, text/plain, */*',
        },
      );
      
      Utilities.customPrint('📥 Download response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        String errorMessage = 'Lỗi tải file: ${response.statusCode}';
        if (response.statusCode == 401) {
          errorMessage = 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Không tìm thấy file ghi chú cuộc họp.';
        }
        
        return DownloadResult(
          success: false,
          message: errorMessage,
        );
      }
      
      // Get download directory
      final directory = await _getDownloadDirectory();
      if (directory == null) {
        return DownloadResult(
          success: false,
          message: 'Không thể truy cập thư mục tải xuống.',
        );
      }
      
      // Generate filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'meeting_notes_${meetingId}_$timestamp.pdf';
      final filePath = '${directory.path}/$filename';
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      
      Utilities.customPrint('📥 File saved to: $filePath');
      
      return DownloadResult(
        success: true,
        message: 'Tải file thành công',
        filePath: filePath,
        fileName: filename,
      );
      
    } catch (e) {
      Utilities.customPrint('❌ Download error: $e');
      return DownloadResult(
        success: false,
        message: 'Lỗi tải file: ${e.toString()}',
      );
    }
  }
  
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      
      // Try to request manage external storage permission
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }
      
      // Fallback to storage permission for older Android versions
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for app documents directory
      return true;
    }
    
    return false;
  }
  
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try to get Downloads directory
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory;
        }
        
        // Fallback to external storage directory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final downloadDir = Directory('${externalDir.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
        
        // Final fallback to app documents directory
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        // iOS: Use app documents directory
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      Utilities.customPrint('❌ Error getting download directory: $e');
    }
    
    return null;
  }
}

class DownloadResult {
  final bool success;
  final String message;
  final String? filePath;
  final String? fileName;
  
  DownloadResult({
    required this.success,
    required this.message,
    this.filePath,
    this.fileName,
  });
}