import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  static const String routeName = "/webView";
  static const String arg_title = "title";
  static const String arg_url = "url";
  final String title;
  final String url;

  WebViewPage(this.title, this.url);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  Completer<WebViewController> _controller;

  @override
  void initState() {
    super.initState();
    _controller = Completer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }
}
