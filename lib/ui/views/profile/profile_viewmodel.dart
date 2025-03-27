import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:json_cache/json_cache.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

import '../../utils/hero-icons-outline_icons.dart';

class ProfileViewModel extends BaseViewModel {
  final jsonCacheMem = JsonCacheMem();
  JsonCacheMem get jsonCacheKey => jsonCacheMem;

  final GlobalKey _key = GlobalKey();
  GlobalKey get key => _key;

  static bool hasProfile = false;

  @override
  ProfileViewModel() {
    initialize();
    print('初始化ProfileViewModel');
  }

  late int _selectedIndex = 0; // 存储选中的按钮索引
  int get selectedIndex => _selectedIndex;

  void onTabChangeprofile(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  final List<Map<String, dynamic>> buttonConfigs = const [
    {
      'bgColor': Color.fromARGB(255, 255, 219, 205),
      'iconBgColor': Color.fromARGB(170, 206, 96, 96),
      'tooltip': 'pinterestImg',
      'text': '气息',
      'icon': Hero_icons_outline.cake,
    },
    {
      'bgColor': Color.fromARGB(255, 255, 219, 205),
      'iconBgColor': Color.fromARGB(170, 206, 96, 96),
      'tooltip': '美食',
      'text': '美食',
      'icon': Hero_icons_outline.cake,
    },
    {
      'bgColor': Color.fromARGB(255, 255, 219, 205),
      'iconBgColor': Color.fromARGB(245, 245, 181, 45),
      'tooltip': '动物',
      'text': '动物',
      'icon': Icons.pets,
    },
    {
      'bgColor': Color.fromARGB(255, 255, 219, 205),
      'iconBgColor': Color.fromARGB(245, 196, 208, 208),
      'tooltip': '旅行',
      'text': '旅行',
      'icon': Hero_icons_outline.truck,
    },
    {
      'bgColor': Color.fromARGB(255, 255, 219, 205),
      'iconBgColor': Color.fromARGB(245, 225, 190, 231),
      'tooltip': '家乡的风景画',
      'text': '家乡',
      'icon': Hero_icons_outline.gift,
    },
  ];
  List<Map<String, dynamic>> get buttonConfig => buttonConfigs;

  Future<Uint8List?> getImageBytes(String imageUrl) async {
    final imageProvider = FastCachedImageProvider(imageUrl);
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);

    Completer<Uint8List?> completer = Completer<Uint8List?>();

    imageStream.addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) async {
      final byteData = await info.image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      completer.complete(bytes); // 完成 Future 并返回图像字节数据
    }));

    return completer.future; // 返回 Future
  }

  Future<void> saveCachedImageToGallery(String url) async {
    try {
      final bytes = await getImageBytes(url);
      if (bytes!.isEmpty) {
        print('No cached image found for URL: $url');
        return;
      }
      // 请求存储权限
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // 保存图片到相册
        await ImageGallerySaverPlus.saveImage(
          bytes,
          quality: 100,
          name: '云雨之洲✨✨✨_${DateTime.now().millisecondsSinceEpoch}',
        );
        print('Image saved to gallery from cache');
      } else {
        print("Permission Denied");
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // 异步初始化方法
  Future<void> initialize() async {
    hasProfile = await loadData();
    print('初始化ProfileViewModel, hasProfile: $hasProfile');
    notifyListeners(); // 通知UI更新
  }

  // 默认数据用[int index = 20]
  Future<void> profileImageFetch([int index = 20]) async {
    final url = Uri.parse('https://mydiumtify.globeapp.dev/ipfs?index=$index');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          // Convert data to the expected format
          Map<String, Map<String, dynamic>> formattedData = {};
          data.forEach((key, value) {
            formattedData[key] = Map<String, dynamic>.from(value);
          });
          print(formattedData);
          // 处理数据并存储
          await saveFirst10MediaInfo(formattedData);
          await jsonCacheMem.refresh('uuuprofile', formattedData);
          notifyListeners();
        } else {
          print('请求成功，但返回的数据为空');
        }
      } else {
        print('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print('请求异常: $e');
    }
  }

  Future<void> saveFirst10MediaInfo(
      Map<String, Map<String, dynamic>> mediaInfoMap) async {
    // 检查 mediaInfoMap 是否为空
    if (mediaInfoMap.isNotEmpty) {
      // 获取前10条数据，如果长度小于10则获取所有数据
      final first10Items = mediaInfoMap.entries.take(10).toList();

      // 创建新的 Map 来存储前10条数据
      final first10MediaInfoMap = <String, Map<String, dynamic>>{};

      for (var entry in first10Items) {
        first10MediaInfoMap[entry.key] = entry.value;
      }

      // 将前10条数据的 Map 转换为 JSON 字符串
      final first10MediaInfoJson = jsonEncode(first10MediaInfoMap);

      // 获取 SharedPreferences 实例
      final prefs = await SharedPreferences.getInstance();

      // 将 JSON 字符串保存到 SharedPreferences
      await prefs.setString('first10MediaInfoMap', first10MediaInfoJson);

      print('前10条 mediaInfoMap 数据已成功存储到 SharedPreferences');
    } else {
      print('mediaInfoMap 为空，无法存储数据');
    }
  }

  Future<bool> loadData() async {
    // 获取 SharedPreferences 实例
    print('loadData');
    final prefs = await SharedPreferences.getInstance();

    // 从 SharedPreferences 中读取存储的 JSON 字符串
    final String? first10MediaInfoJson = prefs.getString('first10MediaInfoMap');

    if (first10MediaInfoJson != null) {
      // 将 JSON 字符串转换为 Map<String, Map<String, dynamic>>
      final Map<String, dynamic> decodedJson = jsonDecode(first10MediaInfoJson);

      // 转换为 <String, Map<String, dynamic>> 类型
      final Map<String, Map<String, dynamic>> mediaInfoMap = decodedJson.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
      );

      // 将 mediaInfoMap 存储到 jsonCacheMem
      await jsonCacheMem.refresh('uuuprofile', mediaInfoMap);
      notifyListeners();

      print('成功将 first10MediaInfoMap 更新到 mediaInfoMap 并存储到 jsonCacheMem');
      return true;
    } else {
      await profileImageFetch();
      print('没有找到存储的 first10MediaInfoMap 数据');
      return false;
    }
  }
}
