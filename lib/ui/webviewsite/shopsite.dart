import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShopWebView extends StatefulWidget {
  const ShopWebView({super.key});

  State<ShopWebView> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<ShopWebView> {
  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          // 允许媒体自动播放
          webViewController?.runJavaScript(
              "document.querySelectorAll('video, audio').forEach(media => media.autoplay = true);");
          debugPrint('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('Page resource error: $error');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains('x-gpt')) {
            debugPrint("Navigation is blocked: $request");
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(
        Uri.parse(
            'https://www.theleap.co/creator/ynadtiy19/mini-course/mastering-smart-goals/take?token=RoxYHZHFy_8bXPSec0N3NA'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家乡的故事'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // 控制距离底部的高度
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左侧按钮
            FloatingActionButton(
              onPressed: () {
                webViewController?.runJavaScript('''
            var prevButton = document.querySelector('.previous-card-button');
            if (prevButton) prevButton.click();
          ''');
              },
              backgroundColor: Colors.blue.withOpacity(0.7), // 设置半透明
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),

            // 右侧按钮
            FloatingActionButton(
              onPressed: () {
                webViewController?.runJavaScript('''
            var nextButton = document.querySelector('.next-card-button');
            if (nextButton) nextButton.click();
          ''');
              },
              backgroundColor: Colors.red.withOpacity(0.7), // 设置半透明
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // WebView 部件
          WebViewWidget(
            controller: webViewController!,
          ),
        ],
      ),
    );
  }
}
