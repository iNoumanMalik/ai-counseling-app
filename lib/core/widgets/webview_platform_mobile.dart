import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformWebContent extends StatelessWidget {
  final String url;
  final VoidCallback onLoaded;

  const PlatformWebContent({super.key, required this.url, required this.onLoaded});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (u) => onLoaded(),
      ))
      ..loadRequest(Uri.parse(url));
    return WebViewWidget(controller: controller);
  }
}
