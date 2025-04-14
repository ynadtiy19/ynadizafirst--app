import 'dart:convert';

import 'package:brotli/brotli.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SimpleScrollView extends StatefulWidget {
  final Function(String) updateImages;

  const SimpleScrollView({
    super.key,
    required this.updateImages,
  });

  @override
  State<SimpleScrollView> createState() => _SimpleScrollViewState();
}

class _SimpleScrollViewState extends State<SimpleScrollView> {
  late final FixedExtentScrollController _scrollController;

  void _handleTap(String imagePath) {
    widget.updateImages(imagePath); // 使用外部传入的函数
  }

  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent / 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OverflowBox(
          alignment: Alignment.center,
          maxHeight: MediaQuery.sizeOf(context).width * 0.6,
          child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView(
              physics: const FixedExtentScrollPhysics(),
              controller: _scrollController,
              itemExtent: 92,
              renderChildrenOutsideViewport: true,
              offAxisFraction: 0.2,
              clipBehavior: Clip.none,
              onSelectedItemChanged: (_) => HapticFeedback.lightImpact(),
              children: List.generate(
                9,
                (index) => RotatedBox(
                  quarterTurns: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(16),
                      elevation: 3,
                      child: InkWell(
                        onTap: _isScrolling
                            ? null
                            : () async {
                                setState(() {
                                  _isScrolling = true;
                                });
                                final assetPath =
                                    'images/uu${(index % 12) + 1}.jpg';
                                print(index);
                                try {
                                  // 1. 加载 asset 图像为 bytes
                                  final ByteData imageData =
                                      await rootBundle.load(assetPath);
                                  final Uint8List bytes =
                                      imageData.buffer.asUint8List();

                                  // 2. 转换为 base64 字符串
                                  final String base64Image =
                                      base64Encode(bytes);
                                  final String imageUrl =
                                      'data:image/jpeg;base64,$base64Image';

                                  // 3. 构建请求 JSON
                                  final Map<String, dynamic> requestBody = {
                                    "response_format": {
                                      "type": "json_schema",
                                      "json_schema": {
                                        "name": "image_prompt",
                                        "strict": true,
                                        "schema": {
                                          "type": "object",
                                          "properties": {
                                            "prompt": {"type": "string"}
                                          },
                                          "required": ["prompt"],
                                          "additionalProperties": false
                                        }
                                      }
                                    },
                                    "chatSettings": {
                                      "model": "gpt-4o",
                                      "temperature": 0.7,
                                      "contextLength": 16385,
                                      "includeProfileContext": false,
                                      "includeWorkspaceInstructions": false,
                                      "embeddingsProvider": "openai"
                                    },
                                    "messages": [
                                      {
                                        "role": "user",
                                        "content": [
                                          {
                                            "type": "image_url",
                                            "image_url": {"url": imageUrl}
                                          },
                                          {
                                            "type": "text",
                                            "text":
                                                "Analyze this image and provide a detailed creative prompt not longer than 400 symbols (may be less if the image is easy to describe)."
                                          }
                                        ]
                                      }
                                    ],
                                    "customModelId": ""
                                  };
                                  // 4. 发送 POST 请求
                                  final response = await http.post(
                                    Uri.parse(
                                        'https://chat.writingmate.ai/api/chat/public'),
                                    headers: {
                                      'Host': 'chat.writingmate.ai',
                                      'Content-Type': 'application/json',
                                      'User-Agent':
                                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0',
                                      'Referer':
                                          'https://labs.writingmate.ai/api/chat/public',
                                      'Accept': '*/*',
                                      'Accept-Encoding':
                                          'gzip, deflate, br, zstd',
                                      'Accept-Language': 'zh-CN,zh;q=0.9',
                                      'Cache-Control': 'no-cache',
                                      'Origin':
                                          'https://labs.writingmate.ai/api/chat/public',
                                      'Pragma': 'no-cache',
                                      'Sec-Fetch-Dest': 'empty',
                                      'Sec-Fetch-Mode': 'cors',
                                      'Sec-Fetch-Site': 'same-origin',
                                      'Sec-Fetch-Storage-Access': 'active',
                                      'Priority': 'u=1, i',
                                      'Sec-Ch-Ua':
                                          '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
                                      'Sec-Ch-Ua-Mobile': '?0',
                                      'Sec-Ch-Ua-Platform': '"Windows"'
                                    },
                                    body: jsonEncode(requestBody),
                                  );
                                  if (response.statusCode == 200) {
                                    // 检查响应头以确定内容是否是 Brotli 编码
                                    if (response.headers['content-encoding'] ==
                                        'br') {
                                      // 解码 Brotli 编码的字节
                                      final compressedBytes =
                                          response.bodyBytes;

                                      // 使用 Brotli 包解压缩
                                      final decodedBytes =
                                          brotli.decode(compressedBytes);
                                      final decodedString =
                                          utf8.decode(decodedBytes);
                                      // 解析 JSON
                                      final jsonResponse =
                                          jsonDecode(decodedString);
                                      final prompt =
                                          jsonResponse['prompt'] as String;
                                      print(prompt);
                                      _handleTap(prompt);
                                      setState(() {
                                        _isScrolling = false;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  setState(() {
                                    _isScrolling = false;
                                  });
                                  print('Error processing image: $e');
                                }
                              },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'images/uu${(index % 12) + 1}.jpg', //图像从第一张开始
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _onImageTap(int index) {
    print(index);
  }
}
