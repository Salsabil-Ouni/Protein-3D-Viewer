import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'viewer_3d_stub.dart'
    if (dart.library.html) 'viewer_3d_web.dart';

/// In-app 3D protein viewer using 3Dmol.js.
/// webview widget
class Viewer3D extends StatefulWidget {
  final String pdbId;
  const Viewer3D({super.key, required this.pdbId});

  @override
  State<Viewer3D> createState() => _Viewer3DState();
}

class _Viewer3DState extends State<Viewer3D> {
  WebViewController? _controller;
  bool _pageLoaded = false;

  bool get _useWebView =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
    if (_useWebView) _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1a1a2e))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _pageLoaded = true);
          _callJS(widget.pdbId);
        },
      ))
      ..loadFlutterAsset('assets/html/viewer.html');
  }

  void _callJS(String pdbId) {
    _controller?.runJavaScript(
      "flutterLoadProtein('${pdbId.toUpperCase()}');",
    );
  }

  @override
  void didUpdateWidget(Viewer3D old) {
    super.didUpdateWidget(old);
    if (old.pdbId != widget.pdbId && _pageLoaded) {
      _callJS(widget.pdbId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return buildWebViewer(widget.pdbId);

    if (_useWebView && _controller != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          WebViewWidget(
            controller: _controller!,
            gestureRecognizers: {
              Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
            },
          ),
          if (!_pageLoaded)
            const ColoredBox(
              color: Color(0xFF1a1a2e),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white54),
                    SizedBox(height: 12),
                    Text('Loading 3D structure…',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // Desktop fallback.
    return _FallbackViewer(pdbId: widget.pdbId);
  }
}

/// Desktop fallback — thumbnail + link to RCSB external viewer.
class _FallbackViewer extends StatelessWidget {
  final String pdbId;
  const _FallbackViewer({required this.pdbId});

  @override
  Widget build(BuildContext context) {
    final id = pdbId.toLowerCase();
    return Container(
      color: const Color(0xFF1a1a2e),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://cdn.rcsb.org/images/structures/${id}_model-1.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFF1a1a2e),
              child: Icon(Icons.biotech, size: 80, color: Colors.white24),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.view_in_ar, color: Colors.white70, size: 36),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  onPressed: () => launchUrl(
                    Uri.parse(
                        'https://www.rcsb.org/3d-view/${pdbId.toUpperCase()}'),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: Text('View ${pdbId.toUpperCase()} in 3D'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
