import 'dart:io';

import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:listview_screenshot/listview_screenshot.dart';
import 'package:pretty_animated_buttons/widgets/pretty_shadow_button.dart';
import 'package:stacked/stacked.dart';

import '../../../services/chat_message.dart';
import '../../common/ui_helpers.dart';
import '../../utils/hero-icons-outline_icons.dart';
import '../../widgets/common/popmenu/gptdropdown.dart';
import 'bubbletext.dart';
import 'chatmessagebar.dart';
import 'chatsity_viewmodel.dart';

class ChatsityView extends StackedView<ChatsityViewModel> {
  const ChatsityView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChatsityViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // 允许内容衍生进入appbar后面
      appBar: MyCustomAppBar(
        onAvatarTap: () {
          viewModel.showInputDialog(context);
        },
        title: viewModel.uu1name,
        avatarUrl: viewModel.uu1path,
        isOnline: viewModel.isfetchingUpdateVersion,
        // isOnline: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: viewModel.imageBackground == null
                ? const FastCachedImage(
                    fadeInDuration: Duration(milliseconds: 123),
                    url:
                        'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223901/c15e0758-5f12-44dc-9a8c-47c7e2b83a9b_vtqgil.jpg', // 替换为你的图片URL
                    fit: BoxFit.cover, // 确保图片覆盖整个背景
                  )
                : Image.file(
                    viewModel.imageBackground!,
                    fit: BoxFit.cover,
                  ),
          ),
          viewModel.changeUI
              ? Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 10),
                    child: ValueListenableBuilder(
                      valueListenable: viewModel.chatBox.listenable(),
                      builder: (context, Box<ChatMessage> box, _) {
                        return ChatListView(
                          chatsityViewModel: viewModel,
                          chatBox: box,
                          scrollController: viewModel.scrollController,
                          isFetching: viewModel.isfetching,
                          isNeedTypingIndicator:
                              viewModel.uuuisNeedTypingIndicator,
                          shotKey: viewModel.shotKey,
                          routeToTextPage: viewModel.routeTotextPage,
                        );
                      },
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 70),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('聊天',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 30)),
                                content: const Text('选择一个你喜欢的聊天机器人'),
                                actions: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Column(
                                      children: [
                                        PrettyShadowButton(
                                          label: "进入Chatgpt聊天",
                                          onPressed: () {
                                            viewModel.uchangeGeminichat();
                                            viewModel.UchangeUI();
                                            viewModel.ImageRepository
                                                .setBottomNavVisible(); //调用方法
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icons.arrow_forward,
                                          shadowColor: Colors.green,
                                        ),
                                        const SizedBox(height: 10),
                                        PrettyShadowButton(
                                          label: "进入Gemini聊天",
                                          onPressed: () {
                                            viewModel.changeGeminichat();
                                            viewModel.UchangeUI();
                                            viewModel.ImageRepository
                                                .setBottomNavVisible();
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icons.arrow_forward,
                                          shadowColor: Colors.green,
                                        ),
                                        const SizedBox(height: 10),
                                        PrettyShadowButton(
                                          label: "选择喜欢的背景墙",
                                          onPressed: () {
                                            viewModel.pickImageforbackground();
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icons.arrow_forward,
                                          shadowColor: Colors.green,
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          child: const Text('取消',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: screenWidth(context) / 2,
                          height: screenWidth(context) / 2,
                          margin: const EdgeInsets.all(1),
                          padding: const EdgeInsets.all(0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: null,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: screenWidth(context) * 0.725,
                                height: screenWidth(context) * 0.725,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: viewModel.uuuavatarImagePathValue !=
                                            null
                                        ? FileImage(File(viewModel
                                                .uuuavatarImagePathValue!))
                                            as ImageProvider
                                        : const AssetImage('images/uu4.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Center(
                                  child: CustomPaint(
                                    painter: CircleBorderWithGlow(
                                      color: Colors.amber[100]!,
                                      strokeWidth: 2,
                                      glowRadius: 5, // 光晕半径
                                    ),
                                    child:
                                        Container(), // 使用空容器，因为绘制已经在 CustomPaint 中完成
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '免费助手',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Ink(
                              width: 65,
                              decoration: BoxDecoration(
                                color: Colors.pink[100],
                                borderRadius: BorderRadius.circular(
                                    12), // 如果 InkWell 有圆角，这里也要设置
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashFactory: InkSparkle
                                      .constantTurbulenceSeedSplashFactory,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  onTap: () async {
                                    viewModel.clearImageBackground();
                                    await viewModel.clearSharedPreferences();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Hero_icons_outline.check_badge,
                                                color: Colors.white), // 添加图标
                                            SizedBox(width: 10), // 调整间距
                                            Text("缓存数据已清除"),
                                          ],
                                        ),
                                        backgroundColor: Colors.green, // 设置背景颜色
                                        behavior: SnackBarBehavior
                                            .floating, // 让 Snackbar 悬浮
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              15.0), // 圆角设计
                                        ),
                                        duration: const Duration(
                                            milliseconds: 2500), // 显示 2.5s
                                      ),
                                    );
                                  },
                                  //删除缓存中所有数据
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      message: 'Delete all picture',
                                      child: Icon(
                                        Hero_icons_outline.trash,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 使用自定义的 CustomGridColumn 部件
                      const CustomGridColumn(
                        imageUrls: [
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223299/Nature_picture_Nature_photography_Natural_beauty_l8r5by.jpg',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223299/9493c0d0-9f7a-4f8e-9b5a-34fa0052ca2c_ny8bza.jpg',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742224048/e401c996-4daa-493b-9574-bf43407355a8_f8a31r.jpg',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223962/f70cbffb-6ac7-4268-9769-6849cdaf2ee9_a5ltrd.jpg',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223299/Nature_picture_Nature_photography_Natural_beauty_l8r5by.jpg',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742224114/Telefon_duvar_ka%C4%9F%C4%B1tlar%C4%B1_hc9ac6.jpg',
                        ],
                        items: [
                          '创作',
                          '关键词',
                          '写诗歌',
                          '写故事',
                          '图像识别',
                          '提示词',
                        ],
                        itemHeight: 50.0, // 控制每个项目的高度
                        spacing: 10.0, // 控制项目之间的间隔
                      ),
                      CustomSection(
                        title: 'ChatGPT',
                        buttonText: '浏览全部',
                        imageUrls: const [
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223901/c15e0758-5f12-44dc-9a8c-47c7e2b83a9b_vtqgil.jpg',
                          'https://utfs.io/f/e9rePmZszdcgET7tYDSeQbHLKAarSm17Rl6j2dw3g0IcCYNP',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742224114/Telefon_duvar_ka%C4%9F%C4%B1tlar%C4%B1_hc9ac6.jpg',
                        ],
                        cardTitles: const [
                          'Top 50 Global',
                          'Trending Now',
                          'Popular Hits',
                        ],
                        cardDescriptions: const [
                          'Worldwide hits.\nCover: Bad Bunny',
                          'Latest trends in music.',
                          'The most popular songs right now.',
                        ],
                        onButtonPressed: () {
                          //进入其他界面
                          print('clear chatbox');
                        },
                        onCardPressed: () {
                          //进入卡片所在的界面
                        },
                      ),
                      CustomSection(
                        title: 'Google Gemini',
                        buttonText: '浏览全部',
                        imageUrls: const [
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223901/c15e0758-5f12-44dc-9a8c-47c7e2b83a9b_vtqgil.jpg',
                          'https://res.cloudinary.com/ddgzciyug/image/upload/v1742223962/f70cbffb-6ac7-4268-9769-6849cdaf2ee9_a5ltrd.jpg',
                          'https://utfs.io/f/e9rePmZszdcgCYSAVwB68En15KMm7CcRVx0pUrehv3OJqtXi',
                        ],
                        cardTitles: const [
                          'Top 50 Global',
                          'Trending Now',
                          'Popular Hits',
                        ],
                        cardDescriptions: const [
                          'Worldwide hits.\nCover: Bad Bunny',
                          'Latest trends in music.',
                          'The most popular songs right now.',
                        ],
                        onButtonPressed: () {},
                        onCardPressed: () {},
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ],
      ),
      bottomNavigationBar: viewModel.changeUI
          ? SafeArea(
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyboardListener(
                      // 监听键盘事件的焦点节点
                      focusNode: FocusNode(),
                      onKeyEvent: (KeyEvent event) {
                        // 检查是否是放下按钮（一般是“返回”键）
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.escape) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      child: chatMessageBar(
                        textController: viewModel.textController,
                        replyingTo: viewModel.listenText,
                        ureplyactions: [
                          TodoViewMenu(
                            destinations:
                                TodoViewMenuDestination.values.toList(),
                            onSelected:
                                (TodoViewMenuDestination destination) async {
                              // 处理菜单项选择
                              switch (destination) {
                                case TodoViewMenuDestination.photo:
                                  await viewModel.UopenImagePicker();
                                  print('请求打开相册');
                                  break;
                                case TodoViewMenuDestination.camera:
                                  await viewModel.UopenCamera();
                                  print('请求打开相机');
                                  break;
                                case TodoViewMenuDestination.microphone:
                                  showDialog(
                                    context: context,
                                    builder: (context) => StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          backgroundColor:
                                              const Color(0XFF1e1c22),
                                          actionsPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 40.0),
                                          title: Text('Tap To Speak',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 30.0,
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold,
                                              )),
                                          actionsAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          actions: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: Text(
                                                  viewModel.recognizedTextValue,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 30.0)),
                                            ),
                                            StatefulBuilder(
                                              builder: (BuildContext context,
                                                  StateSetter setState) {
                                                return Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: AvatarGlow(
                                                      glowColor: Colors.yellow,
                                                      animate:
                                                          viewModel.isListening,
                                                      repeat: true,
                                                      child: InkWell(
                                                        overlayColor:
                                                            const MaterialStatePropertyAll(
                                                                Colors
                                                                    .transparent),
                                                        onTap: () async {
                                                          // 调用 setState 更新状态
                                                          setState(() {
                                                            viewModel
                                                                .changeIsListening();
                                                          });
                                                          print(viewModel
                                                              .isListening);
                                                          print(viewModel
                                                              .availableValue);
                                                          if (viewModel
                                                              .isListening) {
                                                            await viewModel
                                                                .listenSpeech(
                                                                    setState,
                                                                    context);
                                                          } else {
                                                            viewModel
                                                                .stopSpeech(
                                                                    setState);
                                                          }
                                                        },
                                                        child: CircleAvatar(
                                                          radius: 40.0,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          child: Icon(
                                                            viewModel
                                                                    .isListening
                                                                ? Icons.mic
                                                                : Icons
                                                                    .mic_none,
                                                            size: 40.0,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                  print('语音转文本');
                                  break;
                                case TodoViewMenuDestination.sparkles:
                                  print('文字转语音');
                                  break;
                                case TodoViewMenuDestination.editList:
                                  print('获取更新版本');
                                  break;
                                default:
                                  print('Unknown Action');
                                  break;
                              }
                            },
                          ),
                        ],
                        onTapCloseReply: () {
                          viewModel.ureplychange(); //关闭回复框
                        },
                        replying: viewModel.openreply, //openreply为true时候，显示回复框
                        messageBarColor: viewModel.animating
                            ? Color.fromARGB(
                                255,
                                viewModel.dominantColor.r,
                                viewModel.dominantColor.g,
                                viewModel.dominantColor.b)
                            : Colors.white,
                        messageBarHintText: '消息',
                        messageBarHintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        infillColor: const Color.fromARGB(100, 255, 219, 205),
                        sendButtonIcon: viewModel.chatImage
                            ? Hero_icons_outline.arrow_small_up //图像对话
                            : viewModel.chatwithHistory
                                ? Hero_icons_outline.rocket_launch //多轮聊天
                                : Hero_icons_outline.paper_airplane, //谷歌聊天
                        sendButtonColor: Colors.green,
                        onSend: (text) async {
                          viewModel.UchangeUI();
                          viewModel.chatImage
                              ? await viewModel.chatwithImage(text, context)
                              : viewModel.chatwithHistory
                                  ? await viewModel.UchatwithHistory(text)
                                  : await viewModel.sendmessage(text);
                        }, //文本框中信息为_
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Ink(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 219, 205),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    onTap: () {
                                      viewModel.uexchange();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Tooltip(
                                        message: viewModel.exchange
                                            ? '显示选定图片'
                                            : '切换图标', // 根据您的逻辑修改提示信息
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    170, 206, 96, 96),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: AnimatedSwitcher(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    return ScaleTransition(
                                                      scale: animation,
                                                      child: AnimatedBuilder(
                                                        animation: animation,
                                                        builder:
                                                            (context, child) {
                                                          return ColorFiltered(
                                                            colorFilter:
                                                                ColorFilter
                                                                    .mode(
                                                              Colors.black
                                                                  .withOpacity(
                                                                      animation
                                                                          .value),
                                                              BlendMode.srcIn,
                                                            ),
                                                            child: child,
                                                          );
                                                        },
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                                  child: viewModel.exchange
                                                      ? const Icon(
                                                          Hero_icons_outline
                                                              .swatch,
                                                          key: ValueKey(
                                                              'swatchIcon'),
                                                          color: Colors.black,
                                                          size:
                                                              20) // 调整图标大小以适应容器
                                                      : const Icon(
                                                          Hero_icons_outline
                                                              .bars_3,
                                                          key: ValueKey(
                                                              'bars3Icon'),
                                                          color: Colors.black,
                                                          size:
                                                              20), // 调整图标大小以适应容器
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Ink(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 219, 205),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    onTap: () {
                                      viewModel.changechatwithHistory();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Tooltip(
                                        message: viewModel.chatwithHistory
                                            ? '启动多轮聊天'
                                            : '已关闭多轮聊天', // 根据您的逻辑修改提示信息
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AvatarGlow(
                                              glowCount: 2,
                                              glowRadiusFactor: 1.2,
                                              animate:
                                                  viewModel.chatwithHistory,
                                              startDelay:
                                                  const Duration(seconds: 0),
                                              glowColor: Colors.yellowAccent,
                                              glowShape: BoxShape.circle,
                                              curve: Curves.fastOutSlowIn,
                                              child: Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      170, 206, 96, 96),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: viewModel
                                                          .chatwithHistory
                                                      ? const Icon(
                                                          Hero_icons_outline
                                                              .bell_alert,
                                                          color: Colors.green,
                                                          size:
                                                              20) // 调整图标大小以适应容器
                                                      : const Icon(
                                                          Hero_icons_outline
                                                              .bell,
                                                          color: Colors.black,
                                                          size:
                                                              20), // 调整图标大小以适应容器
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Ink(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 219, 205),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12)),
                                    onTap: () {
                                      viewModel.choosechatmodel();
                                    },
                                    // onDoubleTap: () {
                                    //   viewModel.choosepicker(context);
                                    // },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Tooltip(
                                        message: viewModel.pickermodel
                                            ? '切换到相机'
                                            : '切换到相册', // 根据您的逻辑修改提示信息
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    170, 206, 96, 96),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Icon(
                                                    Hero_icons_outline.photo,
                                                    color: viewModel.chatImage
                                                        ? Colors.green
                                                        : Colors.black,
                                                    size: 20), // 调整图标大小以适应容器
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: viewModel.isgoingpickImage
                          ? Container(
                              color: const Color.fromRGBO(239, 220, 220, 0.8),
                              height: 240,
                              width: double.infinity,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: viewModel.itemsList.length,
                                itemBuilder: (_, index) {
                                  File? imageFile =
                                      File(viewModel.itemsList[index].path);
                                  if (viewModel.itemsList[index].type ==
                                      "video") {
                                    imageFile =
                                        viewModel.itemsList[index].thumbnail !=
                                                null
                                            ? File(viewModel
                                                .itemsList[index].thumbnail!)
                                            : null;
                                  }
                                  return imageFile != null
                                      ? InkWell(
                                          // onTap:
                                          //     viewModel.itemsList[index].type ==
                                          //             "video"
                                          //         ? () {}
                                          //         : null,
                                          onTap: () {
                                            // 在这里处理图片点击事件
                                            viewModel.uimagePath(imageFile);
                                            print(imageFile);
                                          },
                                          child: Image.file(imageFile))
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          alignment: Alignment.center,
                                          width: 320,
                                          height: double.infinity,
                                          child: const Text('No thumbnail'));
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(width: 8.0),
                              ),
                            )
                          : Container(
                              color: const Color.fromARGB(255, 216, 219, 231),
                              height: 80,
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: viewModel.imagePathsList.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, // 每行显示两张图片
                                  crossAxisSpacing: 4.0, // 设置图片之间的横向间距
                                  mainAxisSpacing: 4.0,
                                ), // 设置图片之间的纵向间距),
                                itemBuilder: (context, index) {
                                  final imagePath =
                                      viewModel.imagePathsList[index];
                                  return InkWell(
                                    onTap: () {
                                      // 提取图像路径并更新 _image
                                      File imageFile = File(imagePath);
                                      print(imagePath);
                                      viewModel.uimagePath(imageFile);
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.greenAccent),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(imagePath), // 从文件路径中加载图像
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                      secondChild: const SizedBox(),
                      crossFadeState: viewModel.exchange
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 350),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  ChatsityViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatsityViewModel(context);
}

// 自定义绘制器
class CircleBorderWithGlow extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double glowRadius;

  CircleBorderWithGlow({
    required this.color,
    required this.strokeWidth,
    required this.glowRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2 - glowRadius; // 调整半径以适应光晕

    // 绘制光晕
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5) // 设置光晕颜色和透明度
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + glowRadius * 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);

    canvas.drawCircle(center, radius + glowRadius, glowPaint);

    // 绘制边框
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // 如果绘制内容不变，返回 false 以优化性能
  }
}

class CustomGridColumn extends StatelessWidget {
  final List<String> items; // 用于接收展示的内容
  final List<String> imageUrls; // 用于接收背景图片的 URL
  final double itemHeight; // 控制每个item的高度
  final double spacing; // 控制item之间的间隔

  const CustomGridColumn({
    Key? key,
    required this.items,
    required this.imageUrls, // 新增背景图片 URL 列表参数
    this.itemHeight = 150.0, // 设置默认高度
    this.spacing = 10.0, // 设置默认间隔
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2) // 两列展示
          Padding(
            padding: EdgeInsets.only(bottom: spacing), // item之间的垂直间隔
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGridItem(items[i], imageUrls[i]), // 左侧的item
                if (i + 1 < items.length && i + 1 < imageUrls.length)
                  _buildGridItem(items[i + 1], imageUrls[i + 1]), // 右侧的item
              ],
            ),
          ),
      ],
    );
  }

// 生成网格中的每个长方形项目
  Widget _buildGridItem(String text, String imageUrl) {
    return Expanded(
      child: Container(
        height: itemHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FastCachedImageProvider(
                imageUrl), // 使用 CachedNetworkImageProvider
            fit: BoxFit.cover, // 确保图片覆盖整个容器
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerLeft, // 设置文本居左对齐
        margin: const EdgeInsets.symmetric(horizontal: 12.0), // 控制左右间隔
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 为文本添加左右内边距
        child: Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          textAlign: TextAlign.left, // 确保文本左对齐
        ),
      ),
    );
  }
}

class RecentPlayCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onCardPressed;

  const RecentPlayCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onCardPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: onCardPressed,
        splashColor: Colors.purpleAccent.withOpacity(0.3), // 涟漪颜色，带有一点点紫色
        highlightColor: Colors.grey.withOpacity(0.1), // 点击时的背景颜色
        splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        radius: 300.0, // 控制涟漪扩散的半径
        onLongPress: () {}, // 长按时触发涟漪的效果
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                alignment: Alignment.topCenter, // 可选，设置 Stack 中的元素对齐方式
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0), // 图片圆角
                    child: FastCachedImage(
                      fadeInDuration: const Duration(milliseconds: 123),
                      url: imageUrl,
                      width: 100, // 图片宽度
                      height: 100, // 图片高度
                      fit: BoxFit.cover, // 图片填充方式
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0), // 播放按钮的内边距
                      child: InkWell(
                        onTap: () {
                          print('点击了爱心');
                        },
                        child: const Icon(
                          Hero_icons_outline.heart, // 播放图标
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 65,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0), // 播放按钮的内边距
                      child: InkWell(
                        onTap: () {
                          print('点击了评论');
                        },
                        child: const Icon(
                          Hero_icons_outline
                              .chat_bubble_bottom_center_text, // 评论图标
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              AutoSizeText(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1, // 限制一行显示
                overflow: TextOverflow.ellipsis, // 文字溢出时显示省略号
              ),
              AutoSizeText(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                maxLines: 2, // 限制两行显示
                overflow: TextOverflow.ellipsis, // 文字溢出时显示省略号
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedLoadingBar extends StatefulWidget {
  final double height;
  final List<Color> colors;
  final Duration duration;

  /// Creates an [AnimatedLoadingBar].
  ///
  /// The [colors] parameter must not be null and should contain at least two colors.
  /// The [height] parameter specifies the height of the loading bar.
  /// The [duration] parameter specifies the duration of the color animation.

  const AnimatedLoadingBar({
    Key? key,
    this.height = 10.0,
    required this.colors,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _AnimatedLoadingBarState createState() => _AnimatedLoadingBarState();
}

class _AnimatedLoadingBarState extends State<AnimatedLoadingBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = TweenSequence<Color?>(
      widget.colors.asMap().entries.map((entry) {
        int idx = entry.key;
        Color color = entry.value;
        Color nextColor = widget.colors[(idx + 1) % widget.colors.length];
        return TweenSequenceItem(
          tween: ColorTween(begin: color, end: nextColor),
          weight: 1,
        );
      }).toList(),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LinearProgressIndicator(
          backgroundColor: Colors.brown.shade100,
          color: _animation.value,
          minHeight: widget.height,
        );
      },
    );
  }
}

class MyCustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyCustomAppBar({
    Key? key,
    required this.onAvatarTap,
    required this.isOnline,
    required this.avatarUrl,
    required this.title,
  }) : super(key: key);

  final VoidCallback onAvatarTap; // 使用 VoidCallback 代替 Widget Function() 类型
  final String title;
  final List<String> avatarUrl;
  final bool isOnline;

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  _MyCustomAppBarState createState() => _MyCustomAppBarState();
}

class _MyCustomAppBarState extends State<MyCustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.isOnline) {
      _controller.forward(); // 启动加载条
    }
  }

  @override
  void didUpdateWidget(MyCustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _controller.forward(); // 显示加载条
      } else {
        _controller.reverse(); // 隐藏加载条
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 加载条部分
        Positioned(
          top: 0,
          left: 3,
          right: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: widget.isOnline
                  ? const AnimatedLoadingBar(
                      colors: [Colors.brown],
                      height: 5.0,
                      duration: Duration(seconds: 1),
                    )
                  : null,
            ),
          ),
        ),
        // AppBar部分
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 12.0), // 设置顶部间距
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onAvatarTap,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AvatarGlow(
                          animate: true,
                          startDelay: const Duration(seconds: 0),
                          glowColor: Colors.yellowAccent,
                          glowShape: BoxShape.circle,
                          curve: Curves.fastOutSlowIn,
                          child: AdvancedAvatar(
                            image: const NetworkImage(
                                'https://c-ssl.dtstatic.com/uploads/blog/202304/15/20230415081411_f2e46.thumb.400_0.jpg'),
                            size: 60.0, // Set the avatar size
                            statusColor: Colors
                                .green, // Set status color for activity indicator
                            statusAlignment: Alignment
                                .topRight, // Position the status indicator
                            foregroundDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors
                                    .yellowAccent, // Border color for the avatar
                                width: 3.0, // Border width
                              ),
                            ),
                            children: [
                              if (10 >
                                  0) // Display notification bubble only if there are notifications
                                AlignCircular(
                                  alignment: Alignment.topRight,
                                  size: const Size.square(20),
                                  child: Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors
                                          .red, // Notification bubble color
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '10', // Notification count
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w100,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Story 1/2',
                          style: TextStyle(
                            color: Colors.grey[100],
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      shape: BoxShape.rectangle,
                    ),
                    width: 110.0,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            List.generate(widget.avatarUrl.length, (index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  splashColor:
                                      const Color.fromARGB(255, 216, 219, 231)
                                          .withOpacity(0.5),
                                  onTap: () {
                                    print('$index');
                                  },
                                  child: Image.file(
                                    File(widget.avatarUrl[index]),
                                    width: 60.0,
                                    height: 60.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSection extends StatelessWidget {
  final String title;
  final String buttonText;
  final List<String> imageUrls; // 修改为 List<String>
  final List<String> cardTitles; // 修改为 List<String>
  final List<String> cardDescriptions; // 修改为 List<String>
  final VoidCallback onButtonPressed;
  final VoidCallback onCardPressed;

  const CustomSection({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.imageUrls,
    required this.cardTitles,
    required this.cardDescriptions,
    required this.onButtonPressed,
    required this.onCardPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取设备屏幕的宽度和高度
    final screenWidth = MediaQuery.of(context).size.width;

    // 计算容器的宽度和高度，为屏幕的四分之一
    final containerWidth = screenWidth / 3.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            TextButton.icon(
              iconAlignment: IconAlignment.end,
              icon: const Icon(
                Icons.chevron_right,
                color: Colors.black87,
                size: 15,
              ),
              onPressed: onButtonPressed,
              label: Text(
                buttonText,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: imageUrls.length, // 根据图片的数量决定item个数
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15.0),
                    child: Ink(
                      width: containerWidth,
                      child: RecentPlayCard(
                        onCardPressed: onCardPressed,
                        imageUrl: imageUrls[index], // 使用对应的图片
                        title: cardTitles[index], // 使用对应的标题
                        description: cardDescriptions[index], // 使用对应的描述
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class ChatListView extends StatefulWidget {
  final Box<ChatMessage> chatBox;
  final ScrollController scrollController;
  final bool isFetching;
  final bool isNeedTypingIndicator;
  final GlobalKey shotKey;
  final ChatsityViewModel chatsityViewModel;
  final Function(String, BuildContext) routeToTextPage;

  const ChatListView({
    super.key,
    required this.chatBox,
    required this.scrollController,
    required this.isFetching,
    required this.isNeedTypingIndicator,
    required this.shotKey,
    required this.routeToTextPage,
    required this.chatsityViewModel,
  });

  @override
  ChatListViewState createState() => ChatListViewState();
}

class ChatListViewState extends State<ChatListView> {
  bool _isAtBottom = true; // 用于跟踪是否在列表底部

  @override
  void initState() {
    super.initState();
    // 监听滚动事件
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    // 移除监听器
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    // 检测滚动位置
    if (widget.scrollController.offset <
        widget.scrollController.position.maxScrollExtent - 25) {
      setState(() {
        _isAtBottom = false; // 离开底部
      });
    } else {
      setState(() {
        _isAtBottom = true; // 回到底部
      });
    }
  }

  void _scrollToBottom() {
    // 平滑滚动到列表底部
    widget.scrollController
        .animateTo(widget.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1300),
            // curve: Curves.easeInOut,
            curve: Curves.easeInCirc);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WidgetShot(
          key: widget.shotKey,
          controller: widget.scrollController,
          child: ListView.builder(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.chatBox.length,
            itemBuilder: (context, index) {
              final message = widget.chatBox.getAt(index)!;
              bool seenStatus;
              bool isNeedTypingIndicator;
              if (index >= widget.chatBox.length &&
                  widget.isNeedTypingIndicator) {
                isNeedTypingIndicator = true;
              } else {
                isNeedTypingIndicator = false;
              }

              if (index >= widget.chatBox.length - 1 && !widget.isFetching) {
                //最后一条消息两种情况{发送时候为true(不满足)，接收到时候为false(满足)==《此时恰巧显示流式输出》}
                seenStatus = widget.isFetching;
              } else {
                seenStatus = true;
              }

              return _buildMessageItem(message, seenStatus,
                  isNeedTypingIndicator, widget.chatsityViewModel, index);
            },
          ),
        ),
        if (!_isAtBottom) // 当不在底部时显示按钮
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageItem(
      ChatMessage message,
      bool seenStatus,
      bool isNeedTypingIndicator,
      ChatsityViewModel chatsityViewModel,
      int index) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (message.imagePath != null)
          BubbleNormalImage(
            id: 'image_$index', // 使用索引生成唯一 ID
            image: Image.file(File(message.imagePath!)),
            color: Colors.purpleAccent,
            seen: seenStatus,
            delivered: true,
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onDoubleTap: () async {
              widget.routeToTextPage(message.text, context);
            },
            child: BubbleSpecial(
              // isNeedTypingIndicator: isNeedTypingIndicator,
              onComplete: (text) {
                chatsityViewModel.Eisfetching(); //当显示完成之后更改bool值完成显示
              },
              isAnimated: seenStatus,
              seen: seenStatus,
              text: message.text,
              isSender: message.isSender,
              color: message.isSender
                  ? const Color.fromRGBO(225, 190, 231, 1)
                  : const Color.fromRGBO(255, 219, 205, 1),
              textStyle: TextStyle(
                fontFamily: 'ShantellSans-Medium',
                fontSize: 14,
                letterSpacing: 0.1,
                color: message.isSender ? Colors.purple : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
