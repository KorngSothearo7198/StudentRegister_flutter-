import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AbaWebPaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const AbaWebPaymentScreen({
    super.key,
    required this.paymentUrl, required Future<Null> Function() onFinish,
  });

  @override
  State<AbaWebPaymentScreen> createState() => _AbaWebPaymentScreenState();
}

class _AbaWebPaymentScreenState extends State<AbaWebPaymentScreen> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABA Payment'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
