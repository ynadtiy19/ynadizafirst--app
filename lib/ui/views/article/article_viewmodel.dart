import 'dart:convert';
import 'dart:math';

import 'package:brotli/brotli.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hung/app/app.locator.dart';
import 'package:hung/app/app.router.dart';
import 'package:json_cache/json_cache.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../services/image_repository_service.dart';

class MediaInfo {
  final String uniqueSlug;
  final String title;
  final String subtitle;
  final String name;
  final String avatarUrl;
  final String postImg;
  final String readingTime;
  final String createdAt;
  final bool isEligibleForRevenue;

  MediaInfo({
    required this.uniqueSlug,
    required this.title,
    required this.subtitle,
    required this.name,
    required this.avatarUrl,
    required this.postImg,
    required this.readingTime,
    required this.createdAt,
    required this.isEligibleForRevenue,
  });

  // 将 MediaInfo 转换为 Map
  Map<String, dynamic> toJson() {
    return {
      'uniqueSlug': uniqueSlug,
      'title': title,
      'subtitle': subtitle,
      'name': name,
      'avatarUrl': avatarUrl,
      'postImg': postImg,
      'readingTime': readingTime,
      'createdAt': createdAt,
      'isEligibleForRevenue': isEligibleForRevenue,
    };
  }
}

class ArticleViewModel extends ReactiveViewModel {
  late List<dynamic> _categories = [
    'All',
    'Wellness',
    'Mental Health',
    'Productivity',
    'Technology',
    'Health',
    'Business',
    'Personal Development',
    'Culture',
    'Politics',
    'Science',
    'Lifestyle',
    'Education',
    'Design',
  ];
  List<dynamic> get categories => _categories;

  late final List<dynamic> _encategories = [
    'All',
    'Wellness',
    'Mental Health',
    'Productivity',
    'Technology',
    'Health',
    'Business',
    'Personal Development',
    'Culture',
    'Politics',
    'Science',
    'Lifestyle',
    'Education',
    'Design',
  ];
  List<dynamic> get encategories => _encategories;

  Future<bool> fetchPromoteData(bool usureTotranslate) async {
    final url = Uri.parse('https://chat.writingmate.ai/api/chat/public');
    _isfetching = true;
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
              },
              "zhprompts": {
                "type": "array",
                "items": {"type": "string"}
              }
            },
            "required": ["prompts", "zhprompts"],
            "additionalProperties": false
          }
        }
      },
      "chatSettings": {
        "model": "gpt-4o-mini",
        "temperature": 0.8,
        "contextLength": 16385,
        "includeProfileContext": false,
        "includeWorkspaceInstructions": false,
        "embeddingsProvider": "openai"
      },
      "messages": [
        {
          "role": "system",
          "content":
              '''你是一个标签生成引擎，需要基于以下五个常见领域：Life, Travel, Technology, Sales, 和 Personal Development，分别生成每类 10 个英文搜索标签及其对应中文翻译，标签内容无需使用具体的名词或事物，仅通过隐含表达引导出人们在生活中普遍关心、探索、体验、成长、转变等行为意图所对应的关键词。例如：对生活的热爱、对远方的向往、对技术变化的好奇、对交易的策略、对自我成长的渴望等。The first array should contain English tags, and the second should be the corresponding Chinese tags,

    标签要简洁、具启发性、具搜索价值，可以包含 1~4 个词，涵盖短词与长词的多样性，不带 # 符号。输出格式如下：

    English Tags:
    - [English tags for Life]
    - [English tags for Travel]
    - [English tags for Technology]
    - [English tags for Sales]
    - [English tags for Personal Development]

    Chinese Tags:
    - [Chinese tags for Life]
    - [Chinese tags for Travel]
    - [Chinese tags for Technology]
    - [Chinese tags for Sales]
    - [Chinese tags for Personal Development]'''
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
          // if (jsonResponse['zhprompts'] != null)
          //   print(jsonResponse['zhprompts']);
          if (kDebugMode) {
            print(jsonResponse);
          }
          // // 访问 prompts 列表
          if (usureTotranslate) {
            _categories =
                List<String>.from(jsonResponse['zhprompts']); //此刻保留中文文本
            if (kDebugMode) {
              print(_categories);
            }
            // 清空 _encategories 并赋予新值
            _encategories.clear();
            _encategories
                .addAll(List<String>.from(jsonResponse['prompts'])); //此刻保留英文文本
            if (kDebugMode) {
              print(_encategories);
            }
          } else {
            _categories = List<dynamic>.from(jsonResponse['prompts']);
          }
          notifyListeners();
          return true;
        } else {
          return false;
        }
      } else {
        if (kDebugMode) {
          print('Failed to send request: ${response.statusCode}');
        }
        return false;
      }
      // _isfetching = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      return false;
    }
  }

  final JsonCacheMem jsonCacheMem = JsonCacheMem();
  JsonCacheMem get jsonCacheKey => jsonCacheMem;

  bool _isfetching = false;
  bool get isfetching => _isfetching;

  void changeisFetching() {
    if (_isfetching) {
      _isfetching = false;
    } else {
      _isfetching = true;
    }
    notifyListeners();
  }

  late Map<String, dynamic>? _twoPagesfetchDataFirst = {};
  Map<String, dynamic>? get twoPagesfetchDataFirst => _twoPagesfetchDataFirst;

  late Map<String, dynamic>? _twoPagesfetchDataSecond = {};
  Map<String, dynamic>? get twoPagesfetchDataSecond => _twoPagesfetchDataSecond;

  Future<void> readtimefetchData() async {
    const url = 'https://api.npoint.io/25b53d10a9d413020e72';

    try {
      // 发送 HTTP GET 请求获取 JSON 数据
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 强制解码为 UTF-8，处理任何潜在的编码问题
        final decodedBytes =
            utf8.decode(response.bodyBytes, allowMalformed: true);
        final Map<String, dynamic> mediaInfoMap =
            Map<String, dynamic>.from(jsonDecode(decodedBytes));
        if (kDebugMode) {
          print(mediaInfoMap);
        }

        _twoPagesfetchDataFirst = mediaInfoMap;
        if (kDebugMode) {
          print('获取数据成功');
        }
      } else {
        if (kDebugMode) {
          print('响应失败 ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
    notifyListeners();
  }

  // 获取数据并转换
  Future<void> freeMediumfetchData() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.npoint.io/d278cc199e7e7dae2189'));

      if (response.statusCode == 200) {
        // 假设返回的数据是 List<Map<String, String>>
        List<Map<String, dynamic>> rawData =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // 转换为 Map<String, Map<String, dynamic>>，使用 fullLink 作为唯一标识符
        Map<String, Map<String, dynamic>> convertedData = {};

        for (var item in rawData) {
          // 使用 fullLink 作为唯一标识符
          String fullLink = item['fullLink'] ??
              'unknown'; // 如果没有 'fullLink' 字段，则使用 'unknown' 作为默认值
          convertedData[fullLink] =
              item.map((key, value) => MapEntry(key, value));
        }

        // 存储数据
        await jsonCacheMem.refresh('freeMediumfetchData', convertedData);

        _twoPagesfetchDataSecond =
            await jsonCacheMem.value('freeMediumfetchData');
        notifyListeners();
        if (kDebugMode) {
          print('推荐消息加载成功');
        }
      } else {
        if (kDebugMode) {
          print('加载数据失败: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('加载数据失败: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> fetchData(
      [String query = 'apple with nature']) async {
    // _isfetching = true;

    final String apiUrl =
        'https://readmedium.com/api/search-posts?query=$query&pageIndex=2';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      Map<String, Map<String, dynamic>> mediaInfoMap = {};
      List<dynamic> previewInfos = data['previewInfos'] as List<dynamic>;
      for (var data in previewInfos) {
        final uniqueSlug = data['uniqueSlug'].toString();
        final title = data['title'].toString();
        final subtitle = data['subtitle'].toString();
        final name = data['authorInfo']['name'].toString();

        // 获取并修改 avatarUrl
        String avatarUrl = data['authorInfo']['avatarUrl'].toString();
        avatarUrl = avatarUrl
            .replaceFirst('miro.medium.com', 'cdn-images-1.readmedium.com')
            .replaceFirst(
              'v2/resize:fill:88:88',
              'v2/resize:fill:2048:1152',
            ); // 2K 分辨率

        // 获取并修改 postImg
        String postImg = data['postImg'].toString();
        postImg = postImg
            .replaceFirst('miro.medium.com', 'cdn-images-1.readmedium.com')
            .replaceFirst('v2/resize:fit:224', 'v2/resize:fit:2048'); // 2K 分辨率

        final readingTime = data['readingTime'].toString();
        final createdAt = data['createdAt'].toString();
        final isEligibleForRevenueString =
            data['isEligibleForRevenue'].toString();

        // 将字符串转换为布尔值
        final isEligibleForRevenue =
            isEligibleForRevenueString.toLowerCase() == 'true';

        // 创建 MediaInfo 实例
        MediaInfo mediaInfo = MediaInfo(
          uniqueSlug: uniqueSlug,
          title: title,
          subtitle: subtitle,
          name: name,
          avatarUrl: avatarUrl, // 使用修改后的 avatarUrl
          postImg: postImg, // 使用修改后的 postImg
          readingTime: readingTime,
          createdAt: createdAt,
          isEligibleForRevenue: isEligibleForRevenue,
        );

        // 将 MediaInfo 实例添加到 Map 中
        mediaInfoMap[uniqueSlug] = mediaInfo.toJson();
      }

      // 存储数据
      await jsonCacheMem.refresh('fetchedData', mediaInfoMap);

      _twoPagesfetchDataFirst = await jsonCacheMem.value('fetchedData');

      // 获取缓存信息并打印
      // _twoPagesfetchData = await jsonCacheMem.value('fetchedData');
      // final cachedJson = jsonEncode(cachedInfo);
      // print(cachedJson);

      // _isfetching = false; // Reset fetching state
      notifyListeners();

      return mediaInfoMap;
    } else {
      // _isfetching = false; // Reset fetching state in case of error
      notifyListeners();
      throw Exception('Failed to load data');
    }
  }

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  // void refreshStorylyView() {
  //   //刷新这个小部件
  //   storylyViewController.refresh();
  //   notifyListeners();
  // }

  void TravelCardsPageChange(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  final _navigationService = locator<NavigationService>();
  final TextEditingController _textEditingController = TextEditingController();
  TextEditingController get textEditingController => _textEditingController;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  final ImageRepository = locator<ImageRepositoryService>();

  final FocusNode _ArticalfocusNode = FocusNode();
  FocusNode get ArticalfocusNode => _ArticalfocusNode;

  @override
  ArticleViewModel() {
    if (kDebugMode) {
      print('初始化 ArticleViewModel');
    }
    _ArticalfocusNode.unfocus();
    fetchData();
    freeMediumfetchData();
    ImageRepository.loadAvatarImagePath();
    notifyListeners();
  }

  @override
  List<ListenableServiceMixin> get listenableServices => [
        ImageRepository,
      ];

  @override
  void dispose() {
    // 销毁FocusNode，防止内存泄漏
    _ArticalfocusNode.dispose();
    super.dispose();
  }

  String? get avatarImagePathValue => ImageRepository.avatarImagePathValue;

  // static const storylyToken =
  //     "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjc2MCwiYXBwX2lkIjo0MDUsImluc19pZCI6NDA0fQ.1AkqOy_lsiownTBNhVOUKc91uc9fDcAxfQZtpm3nj40";
  //
  // static const storylyUserId =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NfaWQiOjEyMTM2LCJhcHBfaWQiOjE4NzU4LCJpbnNfaWQiOjIxMDgzfQ.Z1-47m5pTa3NiLNKpVcGJUw1N9ANOfxOS_QsKKIK1AA";
  // String get UstorylyToken => storylyToken;
  // String get UstorylyUserId => storylyUserId;
  // late StorylyViewController storylyViewController;
  //
  // void onStorylyViewCreated(StorylyViewController storylyViewController) {
  //   this.storylyViewController = storylyViewController;
  // }

  static int _twoPageschangeindex = 0;
  int get twoPageschangeindex => _twoPageschangeindex;

  Future<void> changePageByCupertionIndex(int index) async {
    _twoPageschangeindex = index; //用来切换按钮
    notifyListeners();
  }

  Color _color0 = const Color.fromARGB(255, 216, 219, 231);
  Color _color1 = const Color.fromARGB(255, 254, 239, 231);
  Color _color2 = const Color.fromARGB(255, 206, 234, 224);
  Color _color3 = const Color.fromARGB(255, 228, 228, 255);
  Color _color4 = const Color.fromARGB(255, 252, 236, 250);

  Color get uuucolor0 => _color0;

  Color get uuucolor1 => _color1;

  Color get uuucolor2 => _color2;

  Color get uuucolor3 => _color3;

  Color get uuucolor4 => _color4;

  void changeColor() {
    _color0 = getRandomColor();
    _color1 = getRandomColor();
    _color2 = getRandomColor();
    _color3 = getRandomColor();
    _color4 = getRandomColor();
    notifyListeners();
  }

  Color getRandomColor() {
    final List<Color> predefinedColors = [
      const Color.fromARGB(255, 216, 219, 231), // Light blue-gray
      const Color.fromARGB(255, 254, 239, 231), // Pale orange
      const Color.fromARGB(255, 206, 234, 224), // Mint green
      const Color.fromARGB(255, 228, 228, 255), // Very pale blue
      const Color.fromARGB(255, 252, 236, 250), // Mustard yellow
    ];

    final Random random = Random();
    int index = random.nextInt(predefinedColors.length); // 随机选择一个索引
    return predefinedColors[index]; // 返回随机选择的颜色
  }

  void onCategorySelected(String category, int index) {
    // print(index);
    _selectedCategory = category;
    _textEditingController.text = _encategories[index]; //翻译API延迟了
    print('选择得中文文本: $category');
    print('原始英文文本是' + _textEditingController.text);
    notifyListeners();
  }

  PushIntoMenu(String value) {
    switch (value) {
      case 'repeatNow':
        break;
      case 'editWorkout':
        _navigationService.navigateTo(Routes.profileView);
        break;
      case 'ShareNow':
        _navigationService.navigateTo(Routes.profileView);
        break;
      case 'getHelp':
        _navigationService.navigateTo(Routes.profileView);
        break;

      default:
        break;
    }
  }

  // void onPressed() {}

  // Future<void> onPressed() async {
  //   log('Checking');

  //   String url = _controller.text.trim();
  //   if (url.isEmpty) {
  //     log('URL is empty');
  //     return;
  //   }

  //   var directLink = DirectLink();
  //   var model =
  //       await directLink.check(url, timeout: const Duration(seconds: 10));

  //   if (model == null) {
  //     return log('model is null');
  //   }

  //   log('title: ${model.title}');
  //   log('thumbnail: ${model.thumbnail}');
  //   log('duration: ${model.duration}');
  //   for (var e in model.links!) {
  //     log('type: ${e.type}');
  //     log('quality: ${e.quality}');
  //     log('link: ${e.link}');

  //     if (e.link != null) {
  //       var appDocDir = await getTemporaryDirectory();
  //       var savePath = '${appDocDir.path}/${model.title}.${e.type}';
  //       await downloadMedia(e.link!, savePath, e.type);
  //     }
  //   }
  // }
}
