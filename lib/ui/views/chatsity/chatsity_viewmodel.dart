import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:brotli/brotli.dart';
import 'package:colorgram/colorgram.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as h2;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kplayer/kplayer.dart';
import 'package:listview_screenshot/listview_screenshot.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../services/atchatclient_service.dart';
import '../../../services/chat_message.dart';
import '../../../services/image_repository_service.dart';
import '../../utils/BackgroundAnimation.dart';
import '../../utils/hero-icons-outline_icons.dart';

class ChatsityViewModel extends ReactiveViewModel {
  late final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  final ImageRepository = locator<ImageRepositoryService>();
  void setBottomNavVisible() => ImageRepository.setBottomNavVisible();
  final chatclientPlugin = locator<AtchatclientService>();

  List<ListenableServiceMixin> get listenableServices =>
      [ImageRepository, chatclientPlugin];

  bool get isBottomNavVisibleValue => ImageRepository.isBottomNavVisibleValue;

  final TextEditingController _textController = TextEditingController();
  TextEditingController get textController => _textController;

  final GlobalKey _shotKey = GlobalKey();
  GlobalKey get shotKey => _shotKey;

  late final Box<ChatMessage> _chatBox = Hive.box<ChatMessage>('chatjson');
  Box<ChatMessage> get chatBox => _chatBox;

  List<String> imagePaths = []; // 保存所有图像文件路径
  get imagePathsList => imagePaths;

  void changechatwithHistory() async {
    if (_chatwithHistory == false) {
      _chatwithHistory = true;
    } else {
      _chatwithHistory = false;
    }
    notifyListeners();
  }

  @override
  ChatsityViewModel(BuildContext context) {
    print('初始化 ChatsityViewModel');
    getAllImagePaths();
    loadData();
    loadbackgroundImage();
    _textController.addListener(initState);
  }
  bool get isfetchingUpdateVersion => !chatclientPlugin.uonboarded; //在这里反着来
  String? get uuuavatarImagePathValue => ImageRepository.avatarImagePathValue;

  bool available = false;
  get availableValue => available;

  bool _isListening = false;
  get isListening => _isListening;

  void changeIsListening() {
    _isListening = !_isListening;
    notifyListeners();
  }

  String recognizedText = "";
  get recognizedTextValue => recognizedText;

  String message = "";
  get messageValue => message;
  stt.SpeechToText speech = stt.SpeechToText();
  Future<void> listenSpeech(setState, BuildContext context) async {
    if (!available) {
      available = await speech.initialize();
    }
    if (available) {
      setState(() {
        recognizedText = "";
      });
      speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
      );
      speech.statusListener = (status) async {
        if (status == 'listening') {
          setState(() => _isListening = true);
        }
        // if (status == 'notListening') {
        //   setState(() => _isListening = false);
        // }
        if (status == 'done') {
          if (recognizedText.isNotEmpty) {
            Navigator.pop(context);
            await routeTotextPage(recognizedText, context);
          }
          setState(() {
            _isListening = false;
            recognizedText = "";
          });
        }
      };
    } else {
      setState(() {
        _isListening = false;
        recognizedText = "Can't Recognize\nVoice";
      });
    }
    notifyListeners();
  }

  void stopSpeech(setState) {
    if (available) {
      speech.stop();
      setState(() {
        _isListening = false;
      });
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
                                    Hero_icons_outline.check_badge, // 使用相同的图标
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8), // 增加图标和文本之间的间距
                                  Expanded(
                                    child: Text(
                                      "文字已复制到剪切板\nThe text has been copied to the clipboard.",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green, // 设置 SnackBar 背景颜色
                              duration:
                                  const Duration(milliseconds: 2000), // 设置持续时间
                              behavior:
                                  SnackBarBehavior.floating, // 使 SnackBar 浮动显示
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15.0), // 设置圆角
                              ),
                              margin:
                                  const EdgeInsets.all(16.0), // 设置 margin，调整位置
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            text,
                          ),
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

  Future<void> getAllImagePaths() async {
    // 获取应用程序的文档目录
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    // 遍历该目录下的所有文件
    Directory dir = Directory(appDocPath);
    List<FileSystemEntity> entities = dir.listSync(); // 获取所有文件和目录

    // 遍历文件并筛选出图像文件路径
    for (var entity in entities) {
      if (entity is File) {
        String filePath = entity.path;
        // 检查文件扩展名是否是图像格式（如 .png, .jpg, .jpeg, .gif 等）
        if (filePath.endsWith('.png') ||
            filePath.endsWith('.jpg') ||
            filePath.endsWith('.jpeg') ||
            filePath.endsWith('.gif')) {
          imagePaths.add(filePath);
        }
      }
    }
  }

  Future<void> showDeleteConfirmationSheet(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('确定要删除聊天记录吗？'),
          message: const Text('此操作将清空所有聊天记录，无法恢复。'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () async {
                await _chatBox.clear(); // 清空聊天记录
                Navigator.of(context).pop(); // 关闭操作表单
              },
              isDestructiveAction: true,
              child: const Text('删除'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭操作表单
            },
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清除所有缓存数据
    print('所有缓存数据已被清除');
  }

  List<Map<String, dynamic>> jsonMessages = [
    {"role": "user", "content": "地球有多大"},
    {
      "role": "assistant",
      "content": ":item[地球]{ to=\"地球 \" }的直径大约为12,742千米(7,917英里)。"
    },
    {"role": "user", "content": "这个夏天我可以去哪里旅游"}
  ];
  List<Map<String, dynamic>> get jsonMessagesList => jsonMessages;

  void imagePath(String imagePath) async {
    _image = File(imagePath);
    notifyListeners();
  }

  void uimagePath(File? imagePath) async {
    _image = imagePath;
    notifyListeners();
  }

  File? _image;
  File? get image => _image;

  static late CgColor _dominantColor;
  CgColor get dominantColor => _dominantColor;

  static File? _imageBackground;
  File? get imageBackground => _imageBackground;

  void clearImageBackground() async {
    _imageBackground = null;
    notifyListeners();
  }

  final picker = ImagePicker();
  final _picker = HLImagePickerAndroid();
  static List<HLPickerItem> items = [];
  List<HLPickerItem> get itemsList => items;

  static List<HLPickerItem> uitems = [];
  List<HLPickerItem> get uitemsList => uitems;

  List<String> uupath = [];
  List<String> get uu1path => uupath;

  String uuname = 'uuu';
  String get uu1name => uuname;

  bool uupickimage = false;
  bool get uu1pickimage => uupickimage;

  static bool _isgoingpickImage = false;
  bool get isgoingpickImage => _isgoingpickImage; //保证每次打开都是选择后的相片

  bool _isfetching = true; //开始声明为true是因为不让所有消息六四输出
  bool get isfetching => _isfetching;

  bool isNeedTypingIndicator = false;
  bool get uuuisNeedTypingIndicator => isNeedTypingIndicator;

  void Eisfetching() {
    _isfetching = true;
    notifyListeners();
  }

  static bool _animating = false;
  bool get animating => _animating;

  static bool _openreply = false;
  bool get openreply => _openreply;

  static bool _isGeminichat = false;
  bool get isGemini => _isGeminichat;

  static String _listenText = '';
  String get listenText => _listenText;

  bool _itemdialogs = false;
  bool get itemdialogs => _itemdialogs;

  static bool _changeUI = false;
  bool get changeUI => _changeUI;

  static bool _chatImage = false;
  bool get chatImage => _chatImage;

  static bool _pickermodel = false;
  bool get pickermodel => _pickermodel;

  bool _chatwithHistory = false;
  bool get chatwithHistory => _chatwithHistory;

  bool _exchange = false;
  bool get exchange => _exchange;

  void UchangeUI() {
    if (_changeUI == false) {
      _changeUI = true;
    }
    notifyListeners();
  }

  void EchangeUI() {
    _changeUI = false;
    notifyListeners();
  }

  void changeGeminichat() {
    _isGeminichat = true;
    notifyListeners();
  }

  void uchangeGeminichat() {
    _isGeminichat = false;
    notifyListeners();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      if (position.pixels < position.maxScrollExtent - 50) {
        // 添加阈值
        _scrollController.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void showInputDialog(BuildContext context) {
    String folderPrefix = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('输入聊天名称'),
          content: Column(
            children: [
              CupertinoTextField(
                placeholder: '输入名称',
                onChanged: (value) {
                  folderPrefix = value; // 更新输入的文件夹前缀
                },
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: UpopenImagePicker, // 点击选择图片
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Hero_icons_outline.plus,
                          color: Colors.black, size: 30),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showDeleteConfirmationSheet(context);
                    }, // Pass context her
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Hero_icons_outline.backspace,
                          color: Colors.black, size: 30),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _isfetching = true;
                      if (!isBottomNavVisibleValue) {
                        ImageRepository.setBottomNavVisible();
                      } else {
                        print('已经打开了底部导航栏');
                      }
                      EchangeUI();
                      Navigator.of(context).pop();
                    },
                    // 点击选择图片
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Hero_icons_outline.arrow_uturn_right,
                          color: Colors.black, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                saveName(folderPrefix); // 保存文本和图片路径
                Navigator.pop(context); // 关闭对话框
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString('uname'); // 获取存储的数据
    List<String>? storedPath = prefs.getStringList('upath');
    uuname = storedName ?? '';
    uupath = storedPath ?? [];
    notifyListeners();
  }

  void saveName(String ufolderPrefix) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (ufolderPrefix.isNotEmpty) {
      uuname = ufolderPrefix;
      prefs.setString('uname', ufolderPrefix); // 将文本和图片路径存储起来
      debugPrint('Saved name and path: $ufolderPrefix');
      notifyListeners();
    }
    if (uupickimage) {
      prefs.setStringList('upath', uitems.map((e) => e.path).toList());
      List<String>? storedPath = prefs.getStringList('upath');
      uupath = storedPath ?? [];
      uupickimage = false;
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> UpopenImagePicker() async {
    try {
      final images = await _picker.openPicker(
        cropping: false,
        selectedIds: null,
        pickerOptions: const HLPickerOptions(
          mediaType: MediaType.image,
          enablePreview: true,
          isExportThumbnail: true,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: 0.9,
          maxSelectedAssets: 12,
          usedCameraButton: true,
          numberOfColumn: 4,
          isGif: true,
        ),
      );

      uitems = images;
      uupickimage = true;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> UopenCamera() async {
    _isgoingpickImage = true;
    try {
      final image = await _picker.openCamera(
        cropping: false,
        cameraOptions: const HLCameraOptions(
          cameraType: CameraType.image,
          recordVideoMaxSecond: 40,
          isExportThumbnail: true,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: 0.9,
        ),
      );

      items = [image];
      notifyListeners();
      changechatwithHistory();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> UopenImagePicker() async {
    _isgoingpickImage = true;
    try {
      final images = await _picker.openPicker(
        cropping: false,
        selectedIds: null,
        pickerOptions: const HLPickerOptions(
          mediaType: MediaType.image,
          enablePreview: true,
          isExportThumbnail: true,
          thumbnailCompressFormat: CompressFormat.jpg,
          thumbnailCompressQuality: 0.9,
          maxSelectedAssets: 12,
          usedCameraButton: true,
          numberOfColumn: 3,
          isGif: true,
        ),
      );

      items = images;
      notifyListeners();
      changechatwithHistory();
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  String getRandomUserAgent() {
    // 生成随机用户代理字符串
    final userAgents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15',
      'Mozilla/5.0 (Linux; Android 10; Pixel 3 XL Build/QP1A.190711.020) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Mobile Safari/537.36'
    ];
    return userAgents[Random().nextInt(userAgents.length)];
  }

  Future<void> uexchange() async {
    if (_exchange == false) {
      _exchange = true;
    } else {
      _exchange = false;
    }

    notifyListeners();
  }

  Future<void> ureplychange() async {
    if (_openreply == true) {
      _openreply = false;
    }
    notifyListeners();
  }

  Future<void> initState() async {
    _listenText = _textController.text;
    // 监听滚动事件
    // scrollController.addListener(() {
    //   // 检查当前滚动位置和上一次的滚动位置
    //   if (scrollController.position.userScrollDirection ==
    //       ScrollDirection.reverse) {
    //     // 向下滑动
    //     setBottomNavVisible();
    //   } else if (scrollController.position.userScrollDirection ==
    //       ScrollDirection.forward) {
    //     // 向上滑动
    //     setBottomNavVisible();
    //   }
    // });
    if (_listenText.length >= 1 && _listenText.substring(0, 1) == '/') {
      // 当前两个字符是 '/@' 时，显示回复框
      if (!_openreply) {
        _openreply = true; // 设置为 true 显示回复框
      }
    } else {
      if (_openreply) {
        _openreply = false;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _textController.removeListener(initState);
    _textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> uitemdialogs() async {
    if (_itemdialogs == false) {
      _itemdialogs = true;
    } else {
      Mitemdialogs();
      _itemdialogs = true;
    }
    notifyListeners();
  }

  Future<void> Mitemdialogs() async {
    if (_itemdialogs == true) {
      _itemdialogs = false;
    }
    notifyListeners();
  }

  void savegoogledes(String url, String des) {
    final desmessage = ChatMessage(isSender: true, text: des, imagePath: null);
    final imessage = ChatMessage(
        isSender: false, text: "请欣赏来自labs.google生成的图像🤎🍒🌸", imagePath: url);
    _chatBox.add(desmessage);
    _chatBox.add(imessage);
    notifyListeners();
  }

  Future<void> UchatwithHistory(String text) async {
    final url = Uri.parse('https://chat.writingmate.ai/api/chat/public');
    _isfetching = true;
    isNeedTypingIndicator = true;

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

    final message = ChatMessage(isSender: true, text: text, imagePath: null);
    // 将发送的消息构建为 JSON 格式并存储到 Hive
    _chatBox.add(message);

    // 从 Hive 中获取所有消息
    List<ChatMessage> messages = _chatBox.values.toList();
    // 转换消息为 JSON 格式
    jsonMessages = convertMessagesToJsonWithHistory(messages);
    print(jsonMessages);

    final body = jsonEncode({
      "response_format": {"type": "text"},
      "chatSettings": {
        "model": "gpt-4o-mini",
        "temperature": 0.8,
        "contextLength": 16385,
        "includeProfileContext": false,
        "includeWorkspaceInstructions": false,
        "embeddingsProvider": "openai"
      },
      "messages": jsonMessages,
      "customModelId": ""
    });

    // 发送POST请求
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body, // 将Dart对象转换为JSON字符串
      );

      if (response.statusCode == 200) {
        final compressedBytes = response.bodyBytes;

        // 使用 Brotli 包解压缩
        final decodedBytes = brotli.decode(compressedBytes);
        final decodedString = utf8.decode(decodedBytes);
        final message = ChatMessage(
          isSender: false,
          text: decodedString,
          imagePath: null,
        );
        // 将接收到的消息存储到 Hive
        _chatBox.add(message);
        Player.asset("assets/audios/message.mp3");
        _isfetching = false;
        isNeedTypingIndicator = false;
        notifyListeners();
        print('Response data: $decodedString');
      } else {
        _isfetching = false;
        isNeedTypingIndicator = false;
        notifyListeners();
        // 请求失败
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  List<Map<String, dynamic>> convertMessagesToJsonWithHistory(
      List<ChatMessage> messages) {
    List<Map<String, dynamic>> jsonList = [];

    for (var message in messages) {
      Map<String, dynamic> jsonItem;

      if (message.isSender) {
        jsonItem = {
          "role": "user",
          "content": message.text,
        };
      } else {
        jsonItem = {
          "role": "system",
          "content": message.text,
        };
      }

      jsonList.add(jsonItem);
    }

    return jsonList;
  }

  Future<Map<String, dynamic>?> sendmessage(
      [String query = 'How are you doing today?']) async {
    _isfetching = true;
    isNeedTypingIndicator = true;
    final message = ChatMessage(isSender: true, text: query, imagePath: null);
    // 将发送的消息构建为 JSON 格式并存储到 Hive
    _chatBox.add(message);

    // 根据 _isGeminichat 的值选择不同的 API
    final apiUrl = _isGeminichat
        ? 'https://mylinktoa.globeapp.dev/linka?q=${Uri.encodeComponent(query)}'
        : 'https://ai-answer-generator-3.toolzflow.app/api/chat/public'; //https://labs.writingmate.ai/api/chat/public

    print(apiUrl);

    try {
      // 如果 _isGeminichat 为 false，发送 POST 请求到 writingmate API
      final response = _isGeminichat
          ? await http.get(Uri.parse(apiUrl))
          : await http.post(
              Uri.parse(apiUrl),
              headers: {
                "Content-Type": "application/json",
                "User-Agent":
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0", // Updated User-Agent
                "Referer":
                    "https://ai-answer-generator-3.toolzflow.app/", // Updated Referer
                "Accept": "*/*", // Updated Accept
                "Accept-Encoding":
                    "gzip, deflate, br, zstd", // Added Accept-Encoding
                "Accept-Language": "zh-CN,zh;q=0.9", // Added Accept-Language
                "Cache-Control": "no-cache", // Added Cache-Control
                "Origin":
                    "https://ai-answer-generator-3.toolzflow.app", // Added Origin
                "Pragma": "no-cache", // Added Pragma
                "Sec-Fetch-Dest": "empty", // Added Sec-Fetch-Dest
                "Sec-Fetch-Mode": "cors", // Added Sec-Fetch-Mode
                "Sec-Fetch-Site": "same-origin", // Added Sec-Fetch-Site
                "Sec-Fetch-Storage-Access":
                    "active", // Added Sec-Fetch-Storage-Access
                "Priority": "u=1, i", // Added Priority
                "Sec-CH-UA":
                    '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"', // Added Sec-CH-UA
                "Sec-CH-UA-Mobile": "?0", // Added Sec-CH-UA-Mobile
                "Sec-CH-UA-Platform": '"Windows"', // Added Sec-CH-UA-Platform
              },
              body: jsonEncode({
                "response_format": {"type": "text"},
                "chatSettings": {
                  "model": "gpt-4o-mini",
                  "temperature": 0.3, // 与浏览器保持一致
                  "contextLength": 16385,
                  "includeProfileContext": false,
                  "includeWorkspaceInstructions": false,
                  "embeddingsProvider": "openai"
                },
                "messages": [
                  {"role": "user", "content": query}
                ],
                "customModelId": ""
              }),
            );

      if (response.statusCode == 200) {
        if (_isGeminichat) {
          // 处理 JSON 响应
          Map<String, dynamic> data = jsonDecode(response.body);
          final message = ChatMessage(
            isSender: data['isSender'],
            text: data['text'],
            imagePath: null,
          );
          _chatBox.add(message);
          Player.asset("assets/audios/message.mp3");
          _isfetching = false;
          isNeedTypingIndicator = false;
        } else {
          final compressedBytes = response.bodyBytes;

          // 使用 Brotli 包解压缩
          final decodedBytes = brotli.decode(compressedBytes);
          final decodedString = utf8.decode(decodedBytes);
          print(decodedString);
          // 处理纯文本响应
          final message = ChatMessage(
            isSender: false,
            text: decodedString, // 直接使用返回的纯文本
            imagePath: null,
          );
          _chatBox.add(message);
          Player.asset("assets/audios/message.mp3");
          _isfetching = false;
          isNeedTypingIndicator = false;
        }
        notifyListeners();
      } else {
        _isfetching = false; // Reset fetching state in case of error
        isNeedTypingIndicator = false;
        notifyListeners();
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      _isfetching = false; // Reset fetching state in case of exception
      isNeedTypingIndicator = false;
      notifyListeners();
      print('An error occurred: $e');
    }
    return null;
  }

  // 读取背景图片
  Future<void> loadbackgroundImage() async {
    if (_imageBackground != null) {
      print('现在有背景图片'); //如果通过，则表示已经有背景图片
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString('backgroundImage'); // 获取存储的数据
    if (storedName != null) {
      _imageBackground = File(storedName);
    } else {
      print('没有找到存储的背景图片');
    }

    notifyListeners();
  }

  Future<void> pickImageforbackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      prefs.setString('backgroundImage', pickedFile.path); // 将文本和图片路径存储起来
      _imageBackground = File(pickedFile.path);
      notifyListeners();
      print(_imageBackground!.path);
      print(_imageBackground);
    }
    notifyListeners();
  }

  Future<void> chatwithImage(String text, BuildContext context) async {
    if (_image == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('请添加图片'),
            // content: const Text('当前没有任何图片可以删除。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('确定'),
              ),
            ],
          );
        },
      );
      return; // 在这里结束执行
    }
    _isfetching = true;
    isNeedTypingIndicator = true;
    final message = ChatMessage(
        isSender: true, text: text, imagePath: _image?.path); // 存储图像路径
    // 将发送的消息构建为 JSON 格式并存储到 Hive
    _chatBox.add(message);

    // 从 Hive 中获取图像路径
    List<ChatMessage> messages = _chatBox.values.toList();
    String? imagePath = messages.last.imagePath;

    if (imagePath != null) {
      // 创建 FileImage
      FileImage imageProvider = FileImage(File(imagePath));

      // 提取图像中的颜色
      List<CgColor> colorList = await extractColor(imageProvider, 10);

      if (colorList.isNotEmpty) {
        // 获取最突出的颜色
        _dominantColor = colorList.first;
        _animating = true;
        print('好了');
        notifyListeners();
      }
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://mydiumtify.globeapp.dev/chatadvance?q=${Uri.encodeComponent(text)}'),
    );

    // request.fields['q'] = _textController.text;

    // 获取文件的 MIME 类型
    final mimeTypeData =
        lookupMimeType(_image!.path, headerBytes: [0xFF, 0xD8])?.split('/');

    // 添加图片数据
    request.files.add(await http.MultipartFile.fromPath(
      'file', // 文件名
      _image!.path,
      contentType: h2.MediaType(mimeTypeData![0], mimeTypeData[1]),
    ));

    // 发送请求并处理响应
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final responseBody = jsonDecode(responseData.body);
      final message = ChatMessage(
        isSender: false,
        text: responseBody['generated_text'],
        imagePath: null,
      );
      // 将接收到的消息存储到 Hive
      _chatBox.add(message);
      Player.asset("assets/audios/message.mp3");
      _isfetching = false;
      isNeedTypingIndicator = false;
      _image = null;
      notifyListeners();
    } else {
      _isfetching = false; // Reset fetching state in case of error
      isNeedTypingIndicator = false;
      notifyListeners();
      print('Upload failed with status: ${response.statusCode}');
    }
  }

  void choosechatmodel() {
    if (_chatImage == false) {
      _chatImage = true;
    } else {
      _chatImage = false;
    }
    notifyListeners();
  }

  void choosepicker(BuildContext context) {
    if (_pickermodel == false) {
      // 如果数据库已经为空，提示用户
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('请求获取本机照片'),
            content: const Text('双击可以切换图片获取方式'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消', style: TextStyle(color: Colors.black)),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  _pickermodel = true;
                  UopenImagePicker();
                  notifyListeners();
                  Navigator.of(context).pop();
                },
                child: const Text('确定', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('请求获取本机相机照片'),
            content: const Text('双击可以切换图片获取方式'),
            // content:
            // const Text('您正在尝试删除一张重要的图片。此操作不可撤销，删除后将无法恢复。请确认您是否真的要删除这张图片。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                },
                child: const Text('取消', style: TextStyle(color: Colors.black)),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  _pickermodel = false;
                  UopenCamera();
                  notifyListeners();
                  Navigator.of(context).pop(); // 关闭对话框
                },
                child: const Text('确定', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );
    }
  }

  void onScreenshot() async {
    EasyLoading.show(status: '正在创建截图，请勿操作');
    var context = _shotKey.currentContext!;
    WidgetShotRenderRepaintBoundary repaintBoundary =
        context.findRenderObject() as WidgetShotRenderRepaintBoundary;
    Uint8List jpgBytes;
    bool isFirstUpdate = true; // 状态标记

    try {
      jpgBytes = await repaintBoundary.screenshotJpg(
        backgroundColor: Colors.white,
        workerName: 'imageMergeTransform',
        onProcess: (current, total) {
          if (current == 0 && isFirstUpdate) {
            EasyLoading.show(status: '正在合并截图，请稍后');
            isFirstUpdate = false; // 更新状态
          } else if (current > 0) {
            EasyLoading.showProgress(current / total,
                status: '正在创建截图，请稍后, $current/$total');
          }
        },
      );
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('生成截图失败: ${e.toString()}');
      return;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // 在 Android 或 iOS 上保存图片到相册
        await ImageGallerySaverPlus.saveImage(jpgBytes,
            quality: 100,
            name: '🎉🎉✨✨✨_${DateTime.now().millisecondsSinceEpoch}.png');
        EasyLoading.dismiss();
        EasyLoading.showSuccess('截图已保存至相册🎉🎉');
      } else if (Platform.isWindows) {
        // 在 Windows 上保存图片到桌面
        Directory desktopDir = await _getWindowsDesktopPath();
        String filePath =
            '${desktopDir.path}\\${DateTime.now().millisecondsSinceEpoch}.png';
        File file = File(filePath);
        await file.writeAsBytes(jpgBytes);
        EasyLoading.dismiss();
        EasyLoading.showSuccess('截图已保存至桌面🎉🎉');
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError('当前平台不支持截图保存');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('保存截图失败: ${e.toString()}');
    }
  }

// 获取 Windows 桌面路径
  Future<Directory> _getWindowsDesktopPath() async {
    String desktopPath = '${Platform.environment['USERPROFILE']}\\Desktop';
    return Directory(desktopPath);
  }
}
