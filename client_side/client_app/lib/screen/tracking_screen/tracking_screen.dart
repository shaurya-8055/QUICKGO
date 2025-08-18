import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../utility/app_color.dart';

class TrackingScreen extends StatelessWidget {
  final String? url;

  const TrackingScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // On web, open in a new tab/window
      final uri = Uri.parse(url ?? 'https://www.google.com/');
      // Fire and forget; Web won't embed easily
      launchUrl(uri, mode: LaunchMode.externalApplication);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Track Order'),
        ),
        body: const Center(
          child: Text('Opening tracking in a new tab...'),
        ),
      );
    }

    WebViewController webViewController = WebViewController();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url ?? 'https://www.google.com/'));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange),
        ),
      ),
      body: WebViewWidget(
        controller: webViewController,
      ),
    );
  }
}
