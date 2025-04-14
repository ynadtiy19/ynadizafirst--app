import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate_border/flutter_animate_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';

import '../../utils/hero-icons-outline_icons.dart';
import '../../widgets/common/fullscreen/fullscreen_image_viewer.dart';
import '../promotetowords/promotetowords_view.dart';
import '../prompt_to_query_favorite/prompt_to_query_favorite_view.dart';
import '../prompt_to_translate/prompt_to_translate_view.dart';
import '../travelcard/travelcard_view.dart';
import 'UItools/SimpleScrollView.dart';
import 'prompt_to_real_viewmodel.dart';

class PromptToRealView extends StackedView<PromptToRealViewModel> {
  const PromptToRealView({super.key});

  @override
  Widget builder(
    BuildContext context,
    PromptToRealViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 216, 219, 231),
      body: Padding(
        padding: EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  FlutterAnimateBorder(
                    controller: FlutterAnimateBorderController()
                      ..setGradient(
                        const RadialGradient(
                          radius: 3.2,
                          colors: [
                            Colors.green,
                            Colors.redAccent,
                            Colors.amberAccent
                          ],
                        ),
                      )
                      ..setLineThickness(2)
                      ..setLineWidth(48)
                      ..setLinePadding(12)
                      ..setCornerRadius(12),
                    child: IconButton.outlined(
                      tooltip: '打开旋转相册',
                      icon: const Icon(Hero_icons_outline.light_bulb),
                      color: Colors.grey,
                      onPressed: () {
                        _showCustomDialog(context, viewModel);
                      },
                    ),
                  ),
                  const SizedBox(width: 21),
                  Expanded(
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (KeyEvent event) {
                        // 检查是否是放下按钮（一般是“返回”键）
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.escape) {
                          // 关闭输入框的焦点
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: FlutterAnimateBorder(
                        controller: FlutterAnimateBorderController()
                          ..setGradient(
                            const RadialGradient(
                              radius: 0.75,
                              colors: [
                                Colors.green,
                                Colors.yellow,
                                Colors.redAccent,
                                Colors.amberAccent
                              ],
                            ),
                          )
                          ..setLineThickness(2)
                          ..setLineWidth(48)
                          ..setLinePadding(12)
                          ..setCornerRadius(12),
                        child: TextFormField(
                          focusNode: viewModel.promoterealfocusNode,
                          maxLength: 1000,
                          showCursor: false,
                          controller: viewModel.query,
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          onFieldSubmitted: (value) async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            await viewModel.generateImagesFromMultipleSources(
                                context, viewModel.query.text);
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.purple[100],
                            hintText: '输入提示文本...',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.lightGreen, // 聚焦时的粉橙色边框
                                width: 2.0,
                              ),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton.outlined(
                                tooltip: '生成图像',
                                onPressed: viewModel.isGenerating
                                    ? null
                                    : () async {
                                        if (viewModel.query.text.isEmpty) {
                                          print('is empty');
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          _showCustomDialog2(context);
                                        } else {
                                          await viewModel
                                              .generateImagesFromMultipleSources(
                                                  context,
                                                  viewModel.query.text);
                                        }
                                      },
                                iconSize: 27.0,
                                color: Colors.black87,
                                icon: const Icon(
                                    Hero_icons_outline.rocket_launch),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Painting',
                    style: GoogleFonts.sacramento().copyWith(
                      color: const Color.fromARGB(255, 5, 5, 2),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    )),
                const SizedBox(width: 4),
                Row(
                  children: [
                    Ink(
                      width: 65,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 216, 219, 231),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () async {
                            final clipboardData =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            viewModel.query.text = clipboardData!.text!;
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Tooltip(
                              message: 'Paste from clipboard',
                              child: Icon(
                                Hero_icons_outline.square_2_stack,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Ink(
                      width: 65,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 216, 219, 231),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            viewModel.query.clear();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Tooltip(
                              message: 'Clean',
                              child: Icon(
                                Hero_icons_outline.archive_box_x_mark,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Ink(
                      width: 65,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 216, 219, 231),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            deleteImage(context, viewModel);
                          },
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
                    Ink(
                      width: 65,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 216, 219, 231),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              builder: (BuildContext context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.83, // 初始高度为屏幕高度的30%
                                  minChildSize: 0.1, // 最小高度为屏幕高度的10%
                                  maxChildSize: 0.95, // 最大高度为屏幕高度的80%
                                  builder: (BuildContext context,
                                      ScrollController scrollController) {
                                    return DefaultTabController(
                                      length: 4,
                                      child: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          final TabController tabController =
                                              DefaultTabController.of(context);

                                          // 使用标志变量来避免多次调用 setState
                                          bool isScrolling = false;

                                          tabController.addListener(() {
                                            // 仅在选项卡切换时调用 setState
                                            if (!tabController
                                                .indexIsChanging) {
                                              setState(() {}); //滑动tab的关键
                                            }
                                          });
                                          return Column(
                                            children: [
                                              CustomTabBar(
                                                  tabController: tabController),
                                              Expanded(
                                                child: NotificationListener<
                                                    ScrollNotification>(
                                                  onNotification:
                                                      (scrollNotification) {
                                                    // 仅在滚动结束时调用 setState
                                                    if (scrollNotification
                                                        is ScrollEndNotification) {
                                                      if (isScrolling) {
                                                        setState(() {});
                                                        // isScrolling = true;
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    10), () {
                                                          isScrolling = false;
                                                        });
                                                      }
                                                    }
                                                    return true;
                                                  },
                                                  child: TabBarView(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    controller: tabController,
                                                    children: [
                                                      TravelcardView(
                                                        scrollController:
                                                            scrollController,
                                                      ),
                                                      PromptToQueryFavoriteView(
                                                        scrollController:
                                                            scrollController,
                                                      ),
                                                      PromptToTranslateView(
                                                        scrollController:
                                                            scrollController,
                                                      ),
                                                      PromotetowordsView(
                                                        scrollController:
                                                            scrollController,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Tooltip(
                              message: 'More',
                              child: Icon(
                                Hero_icons_outline.rectangle_stack,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // !PromptToRealViewModel.isInitialLoading &&
            !PromptToRealViewModel.isloading //此时isInitialLoading为true（改变了）
                ? viewModel.uuimageBox.isEmpty
                    ? const SizedBox(
                        height: 250, width: 250, child: Text('原始图像为空'))
                    : !PromptToRealViewModel.isInitialLoading
                        ? ImageGridView(
                            imageData: viewModel.uuimageBox.values
                                .map((image) => image.data)
                                .toList(),
                            onImageTap: (context, imageData, value) async {
                              if (value) {
                                // 如果 value 为 true，执行保存操作
                                await viewModel.saveImageFromBase64(
                                    context, imageData);
                                return true; // 返回 true 表示保存成功
                              } else {
                                // 显示取消保存的提示
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Hero_icons_outline.check_badge,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '取消保存，这张图片已经存在于收藏中', // 中文部分
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green, // 使用绿色
                                    duration:
                                        const Duration(milliseconds: 2350),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                );
                                return false; // 返回 false
                              }
                            },
                            crossAxisCount: 3, // 设置为 3 列
                          )
                        : ImageGridView(
                            imageData: PromptToRealViewModel.images,
                            onImageTap: (context, imageData, value) async {
                              // 处理点击事件...
                              if (value) {
                                await viewModel.saveImageFromBase64(
                                    context, imageData);
                                return true; // 表示保存成功
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(
                                          Hero_icons_outline.check_badge,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '取消保存，这张图片已经存在于收藏中', // 中文标题
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green, // 使用绿色
                                    duration:
                                        const Duration(milliseconds: 2350),
                                    behavior: SnackBarBehavior.fixed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                );
                                return false; // 返回 false
                              }
                            },
                            crossAxisCount: 3,
                          )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset(
                            'images/loading3.json',
                            frameRate: const FrameRate(120),
                            repeat: true,
                            animate: true,
                          ),
                        ),
                        const Text(
                          '请等待...',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void deleteImage(BuildContext context, PromptToRealViewModel viewModel) {
    if (viewModel.uuimageBox.isEmpty) {
      // 如果数据库已经为空，提示用户
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('无图片可删除'),
            content: const Text('当前没有任何图片可以删除。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '确定',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('确认删除图片'),
          content:
              const Text('您正在尝试删除一张重要的图片。此操作不可撤销，删除后将无法恢复。请确认您是否真的要删除这张图片。'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                viewModel.ImageRepository.deleteImages();
                if (PromptToRealViewModel.images.isNotEmpty) {
                  PromptToRealViewModel.images.clear();
                }
                viewModel.setInitialLoading();
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.black),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text(
                '取消',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  } //删除所有图片

  void _showCustomDialog(
      BuildContext context, PromptToRealViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: true, // 点击对话框外部区域可以关闭
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            height: 200, // 自定义高度
            width: 410, // 自定义宽度
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(55), // 设置圆角
              ),
              backgroundColor: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: SimpleScrollView(
                  updateImages: (String prompt) {
                    if (prompt.isNotEmpty) {
                      viewModel.setQuery(prompt);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCustomDialog2(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('请输入内容'),
        content: GestureDetector(
          onTap: () async {
            Clipboard.setData(
              const ClipboardData(
                  text:
                      '薄雾轻盈地笼罩在翠绿的山峦之间，露珠在晨光的照耀下闪闪发光。小道旁的野花盛开，散发出淡淡的清香。鸟儿在树梢上欢快地唱着歌，仿佛在迎接新的一天。远处的山顶上，一缕阳光正透过云层，洒下温暖的金色光芒'),
            );
            await Haptics.vibrate(HapticsType.soft);
          },
          child: const Text(
              '例如：薄雾轻盈地笼罩在翠绿的山峦之间，露珠在晨光的照耀下闪闪发光。小道旁的野花盛开，散发出淡淡的清香。鸟儿在树梢上欢快地唱着歌，仿佛在迎接新的一天。远处的山顶上，一缕阳光正透过云层，洒下温暖的金色光芒。'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop(); // 关闭对话框
            },
            child: const Text(
              '取消',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  PromptToRealViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PromptToRealViewModel();
}

class CustomTabBar extends StatelessWidget {
  final TabController tabController;

  CustomTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        // textBaseline: TextBaseline.alphabetic,
        children: [
          CustomTabButton(
            text: '图库',
            index: 0,
            tabController: tabController,
            defaultColor: Colors.transparent,
            selectedColor: const Color.fromRGBO(253, 218, 225, 1),
          ),
          const SizedBox(width: 8.0),
          CustomTabButton(
            text: '收藏',
            index: 1,
            tabController: tabController,
            defaultColor: Colors.transparent,
            selectedColor: const Color.fromRGBO(253, 218, 225, 1),
          ),
          const SizedBox(width: 8.0),
          CustomTabButton(
            text: '翻译',
            index: 2,
            tabController: tabController,
            defaultColor: Colors.transparent,
            selectedColor: const Color.fromRGBO(253, 218, 225, 1),
          ),
          const SizedBox(width: 8.0),
          CustomTabButton(
            text: '润色',
            index: 3,
            tabController: tabController,
            defaultColor: Colors.transparent,
            selectedColor: const Color.fromRGBO(248, 195, 206, 1.0),
          ),
        ],
      ),
    );
  }
}

class CustomTabButton extends StatelessWidget {
  final String text;
  final int index;
  final TabController tabController;
  final Color defaultColor;
  final Color selectedColor;

  CustomTabButton({
    required this.text,
    required this.index,
    required this.tabController,
    required this.defaultColor,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = tabController.index == index;
    return Ink(
      decoration: BoxDecoration(
        color: isActive ? selectedColor : defaultColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          tabController.animateTo(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageGridView extends StatelessWidget {
  final List<String> imageData; // 用于传递 Base64 图像数据的列表
  final Function(BuildContext, String, bool) onImageTap; // 图片点击的回调函数
  final int crossAxisCount; // 用于设置每行显示的图片数量

  const ImageGridView({
    Key? key,
    required this.imageData,
    required this.onImageTap,
    this.crossAxisCount = 3, // 默认值为 3
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // 使用传递的参数
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: imageData.length,
        itemBuilder: (context, index) {
          final imageBase64 = imageData[index];
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      FullscreenImageViewer.open(
                        context: context,
                        child: Image.memory(
                          base64Decode(imageBase64),
                          fit: BoxFit.contain,
                        ),
                        closeWidget:
                            const Icon(Hero_icons_outline.x_mark), // 关闭按钮
                        saveWidget: const Icon(
                            Hero_icons_outline.heart), // 如果需要保存按钮可以传入
                        onTap: () async {
                          await onImageTap(context, imageBase64, true);
                          print("图片被点击");
                        },
                      );
                    },
                    child: Image.memory(
                      base64Decode(imageBase64),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
