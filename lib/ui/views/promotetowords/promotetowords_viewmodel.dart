import 'dart:convert';

import 'package:brotli/brotli.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';

import '../../utils/BackgroundAnimation.dart';
import '../../utils/hero-icons-outline_icons.dart';

class PromotetowordsViewModel extends BaseViewModel {
  static String _selectedCategory = 'DALL-E';
  static String get selectedCategory => _selectedCategory;

  static String _uselectedCategory = 'Copy ThereSelf';
  static String get uselectedCategory => _uselectedCategory;

  static String _uuselectedCategory = '翻译提示';
  static String get uuselectedCategory => _uuselectedCategory;

  static final TextEditingController _query = TextEditingController();
  static TextEditingController get query => _query;

  static late List<dynamic> prompts = [];
  List<dynamic> get uprompts => prompts;

  bool isfetching = false;
  get isFetching => isfetching;

  static bool usureTotranslate = false;
  static get sureToTranslate => usureTotranslate;
  // 每个 Chip 的标签
  final List<String> _chipLabels = [
    "DALL-E",
    "Stable-Diffusion",
    "Midjourney",
    "Flux.1"
  ];
  List<String> get chipLabels => _chipLabels;

  final Map<int, Widget> _SegmentLabels = {
    0: const Text('1:1'),
    1: const Text('4:3'),
    2: const Text('16:9'),
    3: const Text('9:16'),
  };

  final Map<int, String> _RatioMapping = {
    0: '1:1',
    1: '4:3',
    2: '16:9',
    3: '9:16',
  };

  Map<int, Widget> get leftUsegmentLabels => _SegmentLabels;

  late int _leftGroupValue = 0;
  int get leftGroupValue => _leftGroupValue;

  String leftselectedLabel = '1:1'; // 存储选择的标签
  String get leftselectedLabels => leftselectedLabel;

  void onLeftGroupValueChange(int value) {
    _leftGroupValue = value;
    leftselectedLabel = _RatioMapping[value]!; // 更新选择的标签
    print('左边比例选择 $leftselectedLabel');
    notifyListeners();
  }

  final Map<int, Widget> _uSegmentLabels = {
    0: const Text('4条'),
    1: const Text('5条'),
    2: const Text('6条'),
    3: const Text('7条'),
  };

  final Map<int, String> _labelMapping = {
    0: 'four',
    1: 'five',
    2: 'six',
    3: 'seven',
  };

  Map<int, Widget> get rightUsegmentLabels => _uSegmentLabels;

  late int _rightGroupValue = 0;
  int get rightGroupValue => _rightGroupValue;

  String rightselectedLabel = 'six'; // 存储选择的标签
  String get rightselectedLabels => rightselectedLabel;

  void onRightGroupValueChange(int value) {
    _rightGroupValue = value;
    rightselectedLabel = _labelMapping[value]!; // 更新选择的标签
    print('右边数量选择: $rightselectedLabel');
    notifyListeners();
  }

  void onCategorySelected(String category) {
    _selectedCategory = category;
    print('模型选择: $category');
    notifyListeners();
  }

  Future<void> UuonCategorySelected(String category) async {
    if (_uuselectedCategory == category) {
      // 如果当前选定的类别已被点击，取消选定
      _uuselectedCategory = '';
      usureTotranslate = false;
      print('取消翻译: $usureTotranslate');
    } else {
      _uuselectedCategory = category;
      usureTotranslate = true;
      print('选择翻译: $usureTotranslate');
    }
    notifyListeners();
  }

  Future<void> UonCategorySelected(String category) async {
    if (_uselectedCategory == category) {
      // 如果当前选定的类别已被点击，取消选定

      _uselectedCategory = '';
      _query.clear(); // 清空查询
      print('取消复制: $category');
    } else {
      // 选定新的类别
      _uselectedCategory = category;
      print('选择复制: $category');

      // 从剪切板获取文本
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      String? textFromClipboard = clipboardData?.text;
      _query.text = textFromClipboard ?? '';
    }
    notifyListeners();
  }

  Future<void> fetchPromoteData(
      String text, String model, String number, String Ratio) async {
    isfetching = true;
    // 设置请求 URL
    final url = Uri.parse('https://chat.writingmate.ai/api/chat/public');
    prompts = [];

    // 构建请求头
    final headers = {
      'accept': '*/*',
      'accept-encoding': 'gzip, deflate, br, zstd',
      'accept-language': 'zh-CN,zh;q=0.9',
      'cache-control': 'no-cache',
      'content-type': 'application/json',
      'origin': 'https://labs.writingmate.ai',
      'pragma': 'no-cache',
      'referer': 'https://labs.writingmate.ai/share/WLPW?__show_banner=false',
      'sec-ch-ua':
          '"Chromium";v="130", "Microsoft Edge";v="130", "Not?A_Brand";v="99"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      'sec-fetch-dest': 'empty',
      'sec-fetch-mode': 'cors',
      'sec-fetch-site': 'same-origin',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36 Edg/130.0.0.0',
    };

    // 构建请求体
    final body = jsonEncode({
      "response_format": {
        "type": "json_schema",
        "json_schema": {
          "name": "prompt_response",
          "strict": true,
          "schema": {
            "type": "object",
            "properties": {
              "prompts": {
                "type": "array",
                "items": {"type": "string"}
              }
            },
            "required": ["prompts"],
            "additionalProperties": false
          }
        }
      },
      "chatSettings": {
        "model": "gpt-4o-mini",
        "temperature": 0.5,
        "contextLength": 16385,
        "includeProfileContext": false,
        "includeWorkspaceInstructions": false,
        "embeddingsProvider": "openai"
      },
      "messages": [
        {
          "role": "system",
          "content":
              "As an artist of words, your mission is to craft vivid and enchanting prompts that ignite the imagination of image generation AI models. Emphasize clarity and simplicity to ensure that everyone can envision the beauty and essence of each prompt."
        },
        {
          "role": "user",
          "content":
              "Create $number captivating image prompts tailored for $model. Each prompt should:\n            1. Begin with an engaging verb like \"Imagine\", \"Illustrate\", \"Capture\", etc.\n            2. Range between 30 and 50 words, weaving a tapestry of visual storytelling.\n            3. Clearly express the image ratio as \"square ($Ratio)\" at the forefront of each prompt.\n            4. Highlight the style: photorealistic, to evoke realism and depth.\n            5. Include the enchanting theme: $text, symbolizing serenity and flow.\n            6. Utilize clear, straightforward language to ensure understanding.\n            7. Emphasize key elements and details that resonate with beauty and thoughtfulness.\n            8. Adhere to best practices for Midjourney prompts, crafting images that inspire awe."
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // 检查响应头以确定内容是否是 Brotli 编码
        if (response.headers['content-encoding'] == 'br') {
          // 解码 Brotli 编码的字节
          final compressedBytes = response.bodyBytes;

          // 使用 Brotli 包解压缩
          final decodedBytes = brotli.decode(compressedBytes);
          final decodedString = utf8.decode(decodedBytes);
          // 解析 JSON
          final jsonResponse = jsonDecode(decodedString);
          print(jsonResponse);
          // // 访问 prompts 列表
          if (usureTotranslate) {
            List<Future<void>> translationFutures = [];
            for (String prompt in jsonResponse['prompts']) {
              translationFutures.add(translateText(prompt));
            }
            await Future.wait(translationFutures);
          } else {
            prompts = jsonResponse['prompts'];
          }
          // print(prompts);
        } else {
          print('Response body: ${response.body}');
        }
      } else {
        print('Failed to send request: ${response.statusCode}');
      }
      isfetching = false;
    } catch (e) {
      print('Error: $e');
    }
    notifyListeners();
  }

  Future<void> routeTotextPage(String text, BuildContext context) async {
    await HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: <Widget>[
              BackgroundAnimation(
                image: const Image(
                  image: AssetImage("images/gift_icon.png"),
                ),
                child: AlertDialog(
                  scrollable: true,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 15),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(
                                    Hero_icons_outline.check_badge,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "文字已复制到剪切板",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            "The text has been copied to the clipboard."),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(milliseconds: 2000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              behavior:
                                  SnackBarBehavior.floating, // 使 SnackBar 浮动显示
                            ),
                          );
                        },
                        child: Text(
                          text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 100, // This accounts for the status bar height
                left: 25,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Hero_icons_outline.arrow_small_left,
                      size: 30, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> translateText(String text) async {
    // final response = await http.get(Uri.parse(
    //     'https://findmyip.net/api/translate.php?text=$text&target_lang=$targetLang'));
    final uresponse = await http.get(Uri.parse(
        'https://mydiumtify.globeapp.dev/googlemit?text=$text&to_lang=zh-CN&from_lang=auto'));
    if (uresponse.statusCode == 200) {
      // final data = json.decode(uresponse.body);
      final udata = jsonDecode(utf8.decode(uresponse.bodyBytes));
      String translatedText = udata['data'];
      prompts.add(translatedText); // 添加翻译后的文本

      rebuildUi(); //重中之重，即使数组字符串集合改变，也反映不到UI上去
    } else {
      print('Failed to send request: ${uresponse.statusCode}');
    }
  }
}
