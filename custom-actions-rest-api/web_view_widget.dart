// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewWidget extends StatefulWidget {
  const WebViewWidget({
    super.key,
    this.width,
    this.height,
    required this.uri,
    required this.redirectUri,
  });

  final double? width;
  final double? height;
  final String uri;
  final String redirectUri;

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  URLRequest get urlRequest => URLRequest(url: WebUri(widget.uri!));

  @override
  Widget build(BuildContext context) => InAppWebView(
        initialUrlRequest: urlRequest,
        onPageCommitVisible: (_, url) => processRedirectUrl(url, context),
      );

  void processRedirectUrl(WebUri? uri, BuildContext context) {
    final url = uri.toString();
    if (!isRedirectUrl(url)) return;

    Navigator.of(context).pop(url);
  }

  bool isRedirectUrl(String url) => url.startsWith(widget.redirectUri) == true;
}
