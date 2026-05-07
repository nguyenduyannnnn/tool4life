import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/globals.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/base/base_response_model.dart';
import 'package:changmeeting/data/network/api/api.dart';
import 'package:changmeeting/data/local/shared_prefs/shared_prefs_key.dart';

class DeleteAccountRepository {
  Future<BaseResponseModel<Map<String, dynamic>>> deleteAccount() async {
    try {
      final token = Globals.prefs.getString(SharedPrefsKey.token);
      final userId = Globals.prefs.getString(SharedPrefsKey.userId);
      
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Retrieved token: ${token.isNotEmpty ? '***${token.substring(token.length - 10)}' : 'EMPTY'}");
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Retrieved userId: $userId");
      
      if (token.isEmpty || userId.isEmpty) {
        Utilities.customPrint("🗑️ DELETE ACCOUNT: Missing credentials - Token empty: ${token.isEmpty}, UserId empty: ${userId.isEmpty}");
        return BaseResponseModel<Map<String, dynamic>>(
          code: -1,
          message: "Token hoặc User ID không hợp lệ",
          data: null,
        );
      }

      final url = Uri.parse('${API.server}${API.deleteUser(userId)}');
      
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Calling API $url");
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Headers - Authorization: Bearer ***${token.substring(token.length - 10)}");

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Utilities.customPrint("🗑️ DELETE ACCOUNT: Response status: ${response.statusCode}");
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Response body: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - account deleted
        return BaseResponseModel<Map<String, dynamic>>(
          code: 0,
          message: "Tài khoản đã được xóa thành công",
          data: {},
        );
      } else {
        // Parse error response
        try {
          final Map<String, dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
          return BaseResponseModel<Map<String, dynamic>>(
            code: response.statusCode,
            message: jsonData['message'] ?? 'Xóa tài khoản thất bại',
            data: null,
          );
        } catch (e) {
          return BaseResponseModel<Map<String, dynamic>>(
            code: response.statusCode,
            message: 'Xóa tài khoản thất bại: ${response.statusCode}',
            data: null,
          );
        }
      }
    } catch (e) {
      Utilities.customPrint("🗑️ DELETE ACCOUNT: Exception - ${e.toString()}");
      return BaseResponseModel<Map<String, dynamic>>(
        code: -1,
        message: "Lỗi kết nối: ${e.toString()}",
        data: null,
      );
    }
  }
}