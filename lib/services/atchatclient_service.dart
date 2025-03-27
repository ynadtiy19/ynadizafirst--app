import 'dart:async';
import 'dart:io';

import 'package:at_client/at_client.dart';
import 'package:at_onboarding_cli/at_onboarding_cli.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:version/version.dart';

class AtchatclientService with ListenableServiceMixin {
  PostService() {
    listenToReactiveValues([_uonboarded]);
    listenToReactiveValues([recievemessage]);
    // listenToReactiveValues([subscription]);
  }

  static const String fromAtsign = '@gemini2banana';
  static const String toAtsign = '@dolphin9interim';
  static const String nameSpace = 'atsign'; //决于应用程序的需求或者是通知服务的命名规则。
  static const String rootDomain = 'root.atsign.org';
  // static const String fromAtsign = '@absolute3140';
  // static const String toAtsign = '@83purple';

  static Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.manageExternalStorage.request().isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }

  static Future<String> getLocalFilePath(String atsignFile) async {
    // Windows 平台，直接返回 assets 路径
    if (Platform.isWindows) {
      // ⚡ 在编辑器中运行（调试模式）
      if (kDebugMode) {
        print('在编辑器中运行，直接返回 assets 路径');
        return 'assets/keys/$atsignFile';
      }
      // ⚡ 在打包后的 Windows 可执行文件中运行
      return 'data/flutter_assets/assets/keys/$atsignFile'; //windows端已经解决
    }

    // 获取应用支持目录 (Android/iOS)
    final directory = await getApplicationDocumentsDirectory();
    final localPath = '${directory.path}/$atsignFile';

    final file = File(localPath);

    // 文件已存在，直接返回路径
    if (await file.exists()) {
      if (kDebugMode) {
        print('文件已存在，直接使用');
      }
      return localPath;
    }

    // 读取 assets 资源并写入本地
    try {
      final byteData = await rootBundle.load('assets/keys/$atsignFile');
      final buffer = byteData.buffer.asUint8List();
      await file.writeAsBytes(buffer);
      if (kDebugMode) {
        print('文件已写入：$localPath');
      }
      return localPath;
    } catch (e) {
      if (kDebugMode) {
        print('加载并写入文件失败: $e');
      }
      throw Exception('无法加载文件');
    }
  }

  late bool _uonboarded = false;
  bool get uonboarded => _uonboarded;

  StreamSubscription? uuusubscription;

  /// 监听消息变化
  final ValueNotifier<String?> recievemessage =
      ValueNotifier<String?>('早上好呀，喝杯咖啡');
  ValueNotifier<String?> get recievemessageValue => recievemessage;

  Future<void> atauthenticateUser(BuildContext context) async {
    await requestStoragePermission();
    if (_uonboarded) {
      if (kDebugMode) {
        print('已经认证过了');
      }
      await atchatTalk('🎉🎉', context);
    } else {
      await authenticateUser(context);
    }
    notifyListeners();
  }

  Future<bool> atchatTalk(String? input, BuildContext context) async {
    bool result = false;
    if (_uonboarded) {
      result = await atTalk(uuusubscription, input, recievemessage, context);
    }
    notifyListeners();
    return result;
  }

  Future<void> authenticateUser(BuildContext context) async {
    String atsignFile;
    atsignFile = '${fromAtsign}_key.atKeys';
    AtServiceFactory? atServiceFactory;

    // 获取本地文件路径
    String filePath = await getLocalFilePath(atsignFile);
    final supportDirectory = await getApplicationDocumentsDirectory();
    final hiveStoragePath =
        '${supportDirectory.path}/.atsign/$fromAtsign/storage';
    final commitLogPath = '$hiveStoragePath/commitLog';
    final downloadPath = '${supportDirectory.path}/.atsign/files';

    AtOnboardingPreference atOnboardingConfig = AtOnboardingPreference()
      ..namespace = nameSpace
      ..hiveStoragePath = hiveStoragePath
      ..downloadPath = downloadPath
      ..isLocalStoreRequired = true
      ..rootDomain = rootDomain
      ..fetchOfflineNotifications = true
      ..atKeysFilePath = filePath
      ..commitLogPath = commitLogPath
      ..atProtocolEmitted = Version(2, 0, 0);

    AtOnboardingService onboardingService = AtOnboardingServiceImpl(
        fromAtsign, atOnboardingConfig,
        atServiceFactory: atServiceFactory);

    // if (uonboarded) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('已经连接过，无需重复连接')),
    //   );
    // }
    Duration retryDuration = const Duration(seconds: 2);
    while (!_uonboarded) {
      if (kDebugMode) {
        print('Authenticating ... $_uonboarded');
      }
      try {
        if (kDebugMode) {
          print('Connecting ... ');
        }
        await Future.delayed(const Duration(milliseconds: 1000));
        _uonboarded = await onboardingService.authenticate();
      } catch (exception, stackTrace) {
        if (kDebugMode) {
          print('Error: $exception');
        }
        if (kDebugMode) {
          print('Stack trace:\n$stackTrace');
        }
      }

      if (!uonboarded) {
        await Future.delayed(retryDuration);
      }
    }
    if (kDebugMode) {
      print('Authenticated $_uonboarded');
    }
    await atchatTalk('111💖💖💖🎉🎉', context);
    notifyListeners();
  }

  Future<bool> atTalk(
    StreamSubscription? subscription,
    String? input,
    ValueNotifier<String?> recievemessage, // 传入可变的变量
    BuildContext context,
  ) async {
    final AtSignLogger logger = AtSignLogger('atTalk');
    logger.hierarchicalLoggingEnabled = true;
    logger.logger.level = Level.SHOUT;
    AtClient atClient = AtClientManager.getInstance().atClient;

    // Subscribe to the notifications only once (outside atTalk)
    if (subscription == null) {
      subscription = atClient.notificationService
          .subscribe(regex: 'attalk.$nameSpace@', shouldDecrypt: true)
          .listen(
        ((notification) async {
          String keyAtsign = notification.key;
          keyAtsign = keyAtsign.replaceAll('${notification.to}:', '');
          keyAtsign = keyAtsign.replaceAll(
            '.$nameSpace${notification.from}',
            '',
          );
          if (keyAtsign.startsWith('attalk')) {
            logger.info('atTalk update received from ${notification.from}');
            // 假设 talk 是从服务器或其他地方接收到的 Base64 字符串
            recievemessage.value = notification.value!; // 这里更新值
            print('recievemessage :${recievemessage.value}');
            notifyListeners();
          }
        }),
        onError: (e) {
          logger.severe('Notification Failed:$e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('通知接收失败: $e')));
        },
        onDone: () => logger.info('Notification listener stopped'),
      );
    } else {
      subscription.resume();
    }
    bool success = await sendMessage(
      fromAtsign,
      toAtsign,
      nameSpace,
      input!,
      atClient,
      logger,
      context,
    );

    return success;
  }

  Future<bool> sendMessage(
    String fromAtsign,
    String toAtsign,
    String nameSpace,
    String mes,
    AtClient atClient,
    AtSignLogger logger,
    BuildContext context,
  ) async {
    if (mes.isEmpty) return false;

    if (mes == "/退出") {
      return false;
    }

    if (mes.startsWith(RegExp('^/@'))) {
      toAtsign = mes.replaceFirst(RegExp('^/'), '');
      print('Now talking to: $toAtsign');
      return false;
    }

    final metaData = Metadata()
      ..isPublic = false
      ..isEncrypted = true
      ..namespaceAware = true;

    final key = AtKey()
      ..key = 'attalk'
      ..sharedBy = fromAtsign
      ..sharedWith = toAtsign
      ..namespace = nameSpace
      ..metadata = metaData;

    bool success = await sendNotification(
      atClient.notificationService,
      key,
      mes,
      logger,
      context,
    );

    if (!success) {
      print("发送失败");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('消息发送失败')));
    } else {
      // print('消息已发送');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('消息已发送')),
      // );
    }
    return success;
  }

  Future<bool> sendNotification(
    NotificationService notificationService,
    AtKey key,
    String input,
    AtSignLogger logger,
    BuildContext context,
  ) async {
    bool success = false;

    for (int retry = 0; retry < 3; retry++) {
      try {
        NotificationResult result = await notificationService.notify(
          NotificationParams.forUpdate(key, value: input),
          waitForFinalDeliveryStatus: false,
          checkForFinalDeliveryStatus: false,
        );

        if (result.atClientException != null) {
          logger.warning(result.atClientException);
          retry++;
          await Future.delayed(Duration(milliseconds: (500 * (retry))));
        } else {
          success = true;
          break;
        }
      } catch (e) {
        logger.warning(e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('通知发送失败: $e')));
      }
    }

    return success;
  }
}
