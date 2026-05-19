// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';

int _viewerCounter = 0;

/// Returns the interactive WebGL viewer embedded in an <iframe> for Flutter web.
Widget buildWebViewer(String pdbId) => _WebIframeViewer(pdbId: pdbId);

class _WebIframeViewer extends StatefulWidget {
  final String pdbId;
  const _WebIframeViewer({required this.pdbId});

  @override
  State<_WebIframeViewer> createState() => _WebIframeViewerState();
}

class _WebIframeViewerState extends State<_WebIframeViewer> {
  late final String _viewId;
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _viewId = 'protein3d-viewer-${_viewerCounter++}';

    final iframe = html.IFrameElement()
      ..src = 'assets/html/viewer.html?pdb=${widget.pdbId.toUpperCase()}'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;

    _iframe = iframe;

    ui_web.platformViewRegistry.registerViewFactory(_viewId, (_) => iframe);
  }

  /// Tells the already-loaded viewer.html to switch proteins without reloading.
  void _postPdbId(String pdbId) {
    _iframe?.contentWindow?.postMessage('pdb:${pdbId.toUpperCase()}', '*');
  }

  @override
  void didUpdateWidget(_WebIframeViewer old) {
    super.didUpdateWidget(old);
    if (old.pdbId != widget.pdbId) _postPdbId(widget.pdbId);
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
