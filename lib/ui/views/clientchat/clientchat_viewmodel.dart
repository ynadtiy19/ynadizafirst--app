import 'dart:convert';
import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart' as dash_chat;
import 'package:downsize/downsize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:hl_image_picker_android/hl_image_picker_android.dart'
    as hl_picker;
import 'package:hl_image_picker_platform_interface/hl_image_picker_platform_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';

import '../../../app/app.locator.dart';
import '../../../services/atchatclient_service.dart';

class ClientchatViewModel extends ReactiveViewModel {
  late final ChatMessagesController _controller;
  ChatMessagesController get clientchatcontroller => _controller;

  late final ChatUser _currentUser;
  get currentchatUser => _currentUser;

  late final ChatUser _aiUser;
  get aichatUser => _aiUser;

  bool _isLoading = false;
  get isLoading => _isLoading;

  bool isSelectingImage = false; // 标记值，初始为 false
  get isSelectingImageValue => isSelectingImage;

  void onisSelectingImageValueChange() {
    if (isSelectingImage) {
      isSelectingImage = false;
    } else {
      isSelectingImage = true;
    }
    print('uuu :$isSelectingImage');
    rebuildUi(); // 通知视图更新,get到上面
  }

  String? selectedImagePath; // 存储选中的图片路径
  get selectedImagePathValue => selectedImagePath;

  void onSelectedImagePathValueChange(String path) {
    selectedImagePath = path;
    print('uuu :$selectedImagePath');
    rebuildUi(); // 通知视图更新,get到上面
  }

  bool isDeleting = true;
  get isDeletingValue => isDeleting;

  final clientchatPlugin = locator<AtchatclientService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [clientchatPlugin];

  @override
  ClientchatViewModel(BuildContext context) {
    _currentUser = ChatUser(id: "Me", firstName: "Me");
    _aiUser = ChatUser(id: "she", firstName: "Will be she");
    _controller = ChatMessagesController();
    _controller.addMessage(ChatMessage(
      text: "Hi! I can help you with various tasks and answer your questions. ",
      user: _aiUser,
      createdAt: DateTime.now(),
    ));
    // clientchatPlugin.atauthenticateUser(context);
  }

  Future<String?> UpopenImagePicker() async {
    try {
      if (Platform.isWindows) {
        // 如果是 Windows 平台，使用 image_picker
        final ImagePicker picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          return pickedFile.path; // 返回选中的图片路径
        } else {
          return null; // 如果没有选中图片，返回 null
        }
      } else {
        final images = await hl_picker.HLImagePickerAndroid().openPicker(
          cropping: false,
          selectedIds: null,
          pickerOptions: const hl_picker.HLPickerOptions(
            mediaType: MediaType.image,
            enablePreview: true,
            isExportThumbnail: true,
            thumbnailCompressFormat: hl_picker.CompressFormat.jpg,
            thumbnailCompressQuality: 0.9,
            maxSelectedAssets: 1,
            usedCameraButton: true,
            numberOfColumn: 4,
            isGif: true,
          ),
        );

        if (images.isNotEmpty) {
          final selectedImage = images[0]; // 获取选择的第一个图片
          return selectedImage.path; // 返回图片路径
        } else {
          return null; // 如果没有选中图片，返回 null
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      return null; // 错误情况下返回 null
    }
  }

  Future<void> deleteImages(BuildContext context) async {
    isDeleting = true; // 设置删除状态为真，触发UI更新

    try {
      // 获取下载目录
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        // 获取该目录下的所有文件
        final files = directory.listSync();

        // 遍历文件，删除符合条件的文件
        for (var file in files) {
          if (file is File && file.path.contains('ynadity19_')) {
            await file.delete();
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法获取下载目录！')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    } finally {
      isDeleting = false; // 删除结束，恢复UI状态
    }
    notifyListeners();
  }

  Future<void> handleMessage(ChatMessage message, BuildContext context) async {
    _isLoading = true;
    try {
      // 如果选择了图像，将图像转为 Base64 并添加到消息中
      if (selectedImagePath != null) {
        // 将图像文件转换为 Base64 字符串
        File imageFile = File(selectedImagePath!);

        Uint8List imageData = await imageFile.readAsBytes();
        Uint8List? compressedData = await Downsize.downsize(
            data: imageData, maxSize: 180, minQuality: 10);
        if (compressedData != null) {
          // 获取字节数据的大小并转换为 KB
          double sizeInKB =
              compressedData.lengthInBytes / 1024; // 1 KB = 1024 bytes
          print('图像大小: ${sizeInKB.toStringAsFixed(2)} KB');
        }

        String base64String = base64Encode(compressedData!);
        String chatimgText = message.text;
        String base64Image =
            '{$chatimgText}data:image/jpeg;base64,$base64String';

        // 创建新的媒体对象并添加到消息
        _controller.addMessage(ChatMessage(
          medias: [
            dash_chat.ChatMedia(
              url: "$selectedImagePath", // 将 Base64 字符串作为 URL
              type: dash_chat.MediaType.image,
              fileName: 'image.png',
            ),
          ],
          text: message.text,
          user: _currentUser,
          createdAt: DateTime.now(),
        ));
        await clientchatPlugin.atchatTalk(base64Image, context);
      } else {
        // 如果没有选择图片，继续执行原来的消息发送逻辑
        _controller.addMessage(ChatMessage(
          text: message.text,
          user: _currentUser,
          createdAt: DateTime.now(),
        ));
        await clientchatPlugin.atchatTalk(message.text, context);
      }
      selectedImagePath = null; // 清空选中的图片路径
    } finally {
      _isLoading = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
