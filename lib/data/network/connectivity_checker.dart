import 'dart:io';
import 'package:changmeeting/common/utilities.dart';

class ConnectivityChecker {
  static Future<bool> pingDomain(String url) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Extract domain from URL
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      final domain = uri.host;

      Utilities.customPrint("🌐 PING: $domain -> Starting...");

      // Try to lookup the domain
      final result = await InternetAddress.lookup(domain);
      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utilities.customPrint(
            "🌐 PING: $domain -> SUCCESS (${stopwatch.elapsedMilliseconds}ms)");
        return true;
      } else {
        Utilities.customPrint(
            "🌐 PING: $domain -> FAILED - No address found (${stopwatch.elapsedMilliseconds}ms)");
        return false;
      }
    } catch (e) {
      stopwatch.stop();
      final domain = url.contains('://') ? Uri.parse(url).host : url;
      Utilities.customPrint(
          "🌐 PING: $domain -> FAILED - ${e.toString()} (${stopwatch.elapsedMilliseconds}ms)");
      return false;
    }
  }

  static Future<bool> checkServerConnectivity(String serverUrl) async {
    try {
      final uri = Uri.parse(serverUrl);
      final domain = uri.host;

      return await pingDomain(domain);
    } catch (e) {
      Utilities.customPrint(
          "🌐 SERVER CHECK: FAILED - Invalid URL: $serverUrl");
      return false;
    }
  }
}


