import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;

class PlatformWebContent extends StatefulWidget {
  final String url;
  final VoidCallback onLoaded;

  const PlatformWebContent({
    super.key,
    required this.url,
    required this.onLoaded,
  });

  @override
  State<PlatformWebContent> createState() => _PlatformWebContentState();
}

class _PlatformWebContentState extends State<PlatformWebContent> {
  final String viewId = 'webview-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    
    // Register the iframe
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%';

        // Listen for load event
        iframe.onLoad.listen((_) {
          widget.onLoaded();
        });

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}