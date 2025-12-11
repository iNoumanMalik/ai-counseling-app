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
  late final String viewId;

  @override
  void initState() {
    super.initState();
    viewId = 'webview-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the iframe view factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.url
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true;

        // Listen for load event
        iframe.onLoad.listen((_) {
          widget.onLoaded();
        });

        // Handle load errors
        iframe.onError.listen((event) {
          debugPrint('IFrame load error: $event');
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