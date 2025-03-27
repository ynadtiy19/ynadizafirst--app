import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hung/app/app.bottomsheets.dart';
import 'package:hung/app/app.dialogs.dart';
import 'package:hung/app/app.locator.dart';
import 'package:hung/services/chat_message.dart';
import 'package:hung/services/image_data.dart';
import 'package:kplayer/kplayer.dart';

import 'app_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 3));

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // ⚡ 推荐使用 Hive.initFlutter() 进行初始化
  await Hive.initFlutter();

  // ✅ 先注册所有适配器（Adapter）
  Hive.registerAdapter(ImageDataAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  // Hive.registerAdapter(CommitEntryAdapter()); // 🚀 关键：添加这个
  // Hive.registerAdapter(AtDataAdapter());

  // ✅ 然后再打开 Box
  // // 删除相关的 Box 数据
  // await Hive.deleteBoxFromDisk('imagesBox');
  // await Hive.deleteBoxFromDisk('favoriteImagesBox');
  // await Hive.deleteBoxFromDisk('chatjson');

  // 打开新的 Box
  await Hive.openBox<ImageData>('imagesBox');
  await Hive.openBox<ImageData>('favoriteImagesBox');
  await Hive.openBox<ChatMessage>('chatjson');

  EasyLoading.init();

  await setupLocator(); // 先注册依赖
  setupDialogUi();
  setupBottomSheetUi();
  Player.boot();

  runApp(const AppLoader());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.none
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..displayDuration = const Duration(milliseconds: 1000)
    ..userInteractions = false;
}
