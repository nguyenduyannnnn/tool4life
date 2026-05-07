import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:changmeeting/common/utilities.dart';

class AzureEndpointTest {
  static Future<void> testEndpoint() async {
    const String testUrl = 'https://meeting-agent-api.fpt.net/api/v1/auth/azure/direct-login';
    
    try {
      Utilities.customPrint('🧪 ===== TESTING AZURE ENDPOINT =====');
      Utilities.customPrint('🧪 URL: $testUrl');
      
      // Test with a dummy token
      final response = await http.post(
        Uri.parse(testUrl),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'access_token': 'test_token_123',
        }),
      ).timeout(const Duration(seconds: 10));

      Utilities.customPrint('🧪 Response Status: ${response.statusCode}');
      Utilities.customPrint('🧪 Response Headers: ${response.headers}');
      Utilities.customPrint('🧪 Response Body Length: ${response.body.length}');
      Utilities.customPrint('🧪 Response Body: "${response.body}"');
      
      if (response.body.isEmpty) {
        Utilities.customPrint('❌ ENDPOINT TEST: Server returned empty response');
      } else if (response.statusCode == 404) {
        Utilities.customPrint('❌ ENDPOINT TEST: Endpoint not found (404)');
      } else if (response.statusCode >= 500) {
        Utilities.customPrint('❌ ENDPOINT TEST: Server error (${response.statusCode})');
      } else {
        Utilities.customPrint('✅ ENDPOINT TEST: Server responded (${response.statusCode})');
      }
      
    } catch (e) {
      Utilities.customPrint('❌ ENDPOINT TEST: Exception - $e');
      
      if (e.toString().contains('TimeoutException')) {
        Utilities.customPrint('❌ ENDPOINT TEST: Request timed out - server may be unreachable');
      } else if (e.toString().contains('SocketException')) {
        Utilities.customPrint('❌ ENDPOINT TEST: Network error - check internet connection');
      }
    }
    
    Utilities.customPrint('🧪 ===== ENDPOINT TEST COMPLETE =====');
  }
}