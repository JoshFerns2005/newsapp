import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsWeb extends StatefulWidget {
  final String url;
  const NewsWeb({required this.url, Key? key}) : super(key: key);

  @override
  State<NewsWeb> createState() => _NewsWebState();
}

class _NewsWebState extends State<NewsWeb> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: WebViewWidget(controller: controller),
    );
  }
}
