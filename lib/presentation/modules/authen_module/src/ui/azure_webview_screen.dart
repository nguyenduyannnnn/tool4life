import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Màn hình WebView dùng riêng cho Android để xử lý Azure SSO login.
/// Khi Azure redirect về callbackUrlScheme, màn hình tự đóng và trả về URL.
class AzureWebViewScreen extends StatefulWidget {
  final String authUrl;
  final String callbackUrlScheme;

  const AzureWebViewScreen({
    super.key,
    required this.authUrl,
    required this.callbackUrlScheme,
  });

  /// Push màn hình và trả về callback URL khi login xong.
  /// Trả về null nếu user bấm back.
  static Future<String?> open(
    BuildContext context, {
    required String authUrl,
    required String callbackUrlScheme,
  }) {
    return Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(
        builder: (_) => AzureWebViewScreen(
          authUrl: authUrl,
          callbackUrlScheme: callbackUrlScheme,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<AzureWebViewScreen> createState() => _AzureWebViewScreenState();
}

class _AzureWebViewScreenState extends State<AzureWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasReturned = false; // tránh pop 2 lần

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // Bỏ qua lỗi khi redirect về custom scheme —
            // WebView báo lỗi vì không load được URL dạng msauth://...
            // nhưng đây là hành vi bình thường.
          },
          onNavigationRequest: (request) {
            final url = request.url;
            // Detect callback URL theo scheme
            if (url.startsWith(widget.callbackUrlScheme)) {
              _returnResult(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _returnResult(String url) {
    if (_hasReturned) return;
    _hasReturned = true;
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0078D4),
        foregroundColor: Colors.white,
        title: const Text(
          'Đăng nhập Microsoft',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Đóng',
          onPressed: () {
            if (!_hasReturned) {
              _hasReturned = true;
              Navigator.of(context, rootNavigator: true).pop(null);
            }
          },
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0078D4),
              ),
            ),
        ],
      ),
    );
  }
}
