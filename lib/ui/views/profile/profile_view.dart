import 'package:dotted_border/dotted_border.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:hung/ui/views/pinterest/pinterest_view.dart';
import 'package:lottie/lottie.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/hero-icons-outline_icons.dart';
import '../../webviewsite/ynadtiy19.dart';
import '../../widgets/common/fullscreen/fullscreen_image_viewer.dart';
import '../../widgets/common/popmenu/gptdropdown.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({Key? key}) : super(key: key);

  // FutureOr onPopupSelected(
  //     TodoViewMenuDestination destination, Context context) {
  //   return switch (destination) {
  //     TodoViewMenuDestination.deleteCompleted => () {},
  //     TodoViewMenuDestination.feedback => context.hash('/feedback'),
  //     TodoViewMenuDestination.update => context.hash('/update'),
  //     TodoViewMenuDestination.deleteList => () {},
  //     TodoViewMenuDestination.editList => () {},
  //     TodoViewMenuDestination.divider => null,
  //   };
  // }

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) {
    return RefreshIndicator(
      color: Colors.black87,
      onRefresh: () async {
        await viewModel.profileImageFetch(10);
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: const Color.fromARGB(100, 255, 219, 205),
        body: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      'Pinterest',
                      style: GoogleFonts.sacramento().copyWith(
                        color: const Color.fromARGB(255, 5, 5, 2),
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Ink(
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
                                  onTap: () async {
                                    // await DefaultCacheManager().emptyCache();
                                    print('清除缓存成功');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Tooltip(
                                      message: '搜索故事',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 25, // 圆形容器的宽度
                                            height: 25, // 圆形容器的高度
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  170, 206, 96, 96), // 背景颜色
                                              shape: BoxShape.circle, // 圆形
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5), // 阴影颜色
                                                  spreadRadius: 2, // 阴影扩散范围
                                                  blurRadius: 4, // 模糊程度
                                                  offset: const Offset(
                                                      0, 2), // 阴影偏移
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Hero_icons_outline
                                                    .magnifying_glass, // 图标
                                                size: 18, // 图标大小
                                                color: Colors.black87, // 图标颜色
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
                          ),
                          const SizedBox(width: 12),
                          TodoViewMenu(
                            destinations:
                                TodoViewMenuDestination.values.toList(),
                            onSelected: (TodoViewMenuDestination destination) {
                              // 处理菜单项选择
                              switch (destination) {
                                default:
                                  print('Unknown Action');
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            StatefulBuilder(
              builder: (context, setState) {
                return NavigationButtons(
                  buttonConfigs: viewModel.buttonConfig,
                  onButtonTap: (index) {
                    setState(() {
                      viewModel.onTabChangeprofile(index);
                    });
                    print('Button $index tapped');
                  },
                );
              },
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 5),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.only(left: 4.0),
            //         child: Ink(
            //           decoration: const BoxDecoration(
            //             color: Color.fromARGB(255, 255, 219, 205),
            //             borderRadius: BorderRadius.all(Radius.circular(12)),
            //           ),
            //           child: Material(
            //             color: Colors.transparent,
            //             child: InkWell(
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(12)),
            //               onTap: () {
            //                 // 处理点击事件
            //                 print('Button tapped');
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Tooltip(
            //                   message: 'pinterestImg',
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Container(
            //                         width: 25, // 圆形容器的宽度
            //                         height: 25, // 圆形容器的高度
            //                         decoration: const BoxDecoration(
            //                           color: Color.fromARGB(
            //                               170, 206, 96, 96), // 背景颜色
            //                           shape: BoxShape.circle, // 圆形
            //                         ),
            //                         child: const Center(
            //                           child: Icon(
            //                             Hero_icons_outline.cake, // 图标
            //                             size: 18, // 图标大小
            //                             color: Colors.black87, // 图标颜色
            //                           ),
            //                         ),
            //                       ),
            //                       const Text(
            //                         '气息',
            //                         style: TextStyle(
            //                           color: Colors.black87,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 4.0),
            //         child: Ink(
            //           decoration: const BoxDecoration(
            //             color: Color.fromARGB(255, 255, 219, 205),
            //             borderRadius: BorderRadius.all(Radius.circular(12)),
            //           ),
            //           child: Material(
            //             color: Colors.transparent,
            //             child: InkWell(
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(12)),
            //               onTap: () {
            //                 // 处理点击事件
            //                 print('Button tapped');
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Tooltip(
            //                   message: '美食',
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Container(
            //                         width: 25, // 圆形容器的宽度
            //                         height: 25, // 圆形容器的高度
            //                         decoration: const BoxDecoration(
            //                           color: Color.fromARGB(
            //                               170, 206, 96, 96), // 背景颜色
            //                           shape: BoxShape.circle, // 圆形
            //                         ),
            //                         child: const Center(
            //                           child: Icon(
            //                             Hero_icons_outline.cake, // 图标
            //                             size: 18, // 图标大小
            //                             color: Colors.black87, // 图标颜色
            //                           ),
            //                         ),
            //                       ),
            //                       const Text(
            //                         '美食',
            //                         style: TextStyle(
            //                           color: Colors.black87,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 4.0),
            //         child: Ink(
            //           decoration: const BoxDecoration(
            //             color: Color.fromARGB(255, 255, 219, 205),
            //             borderRadius: BorderRadius.all(Radius.circular(12)),
            //           ),
            //           child: Material(
            //             color: Colors.transparent,
            //             child: InkWell(
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(12)),
            //               onTap: () {
            //                 // 处理点击事件
            //                 print('Button tapped');
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Tooltip(
            //                   message: '动物',
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Container(
            //                         width: 25, // 圆形容器的宽度
            //                         height: 25, // 圆形容器的高度
            //                         decoration: const BoxDecoration(
            //                           color: Color.fromARGB(
            //                               245, 245, 181, 45), // 背景颜色
            //                           shape: BoxShape.circle, // 圆形
            //                         ),
            //                         child: const Icon(
            //                           textDirection: TextDirection.ltr,
            //                           weight: 50,
            //                           size: 18,
            //                           Icons.pets,
            //                           color: Colors.black87,
            //                         ),
            //                       ),
            //                       const Text(
            //                         '动物',
            //                         style: TextStyle(
            //                           color: Colors.black87,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 4.0),
            //         child: Ink(
            //           decoration: const BoxDecoration(
            //             color: Color.fromARGB(255, 255, 219, 205),
            //             borderRadius: BorderRadius.all(Radius.circular(12)),
            //           ),
            //           child: Material(
            //             color: Colors.transparent,
            //             child: InkWell(
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(12)),
            //               onTap: () {
            //                 // 处理点击事件
            //                 print('Button tapped');
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Tooltip(
            //                   message: '旅行',
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Container(
            //                         width: 25, // 圆形容器的宽度
            //                         height: 25, // 圆形容器的高度
            //                         decoration: const BoxDecoration(
            //                           color: Color.fromARGB(
            //                               245, 196, 208, 208), // 背景颜色
            //                           shape: BoxShape.circle, // 圆形
            //                         ),
            //                         child: const Icon(
            //                           textDirection: TextDirection.ltr,
            //                           weight: 50,
            //                           size: 18,
            //                           Hero_icons_outline.truck,
            //                           color: Colors.black87,
            //                         ),
            //                       ),
            //                       const Text(
            //                         '旅行',
            //                         style: TextStyle(
            //                           color: Colors.black87,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(left: 4.0),
            //         child: Ink(
            //           decoration: const BoxDecoration(
            //             color: Color.fromARGB(255, 255, 219, 205),
            //             borderRadius: BorderRadius.all(Radius.circular(12)),
            //           ),
            //           child: Material(
            //             color: Colors.transparent,
            //             child: InkWell(
            //               borderRadius:
            //                   const BorderRadius.all(Radius.circular(12)),
            //               onTap: () {
            //                 // 处理点击事件
            //                 print('Button tapped');
            //               },
            //               child: Padding(
            //                 padding: const EdgeInsets.all(8.0),
            //                 child: Tooltip(
            //                   message: '家乡的风景画',
            //                   child: Row(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Container(
            //                         width: 25, // 圆形容器的宽度
            //                         height: 25, // 圆形容器的高度
            //                         decoration: const BoxDecoration(
            //                           color: Color.fromARGB(
            //                               245, 225, 190, 231), // 背景颜色
            //                           shape: BoxShape.circle, // 圆形
            //                         ),
            //                         child: const Icon(
            //                           textDirection: TextDirection.ltr,
            //                           weight: 50,
            //                           size: 18,
            //                           Hero_icons_outline.gift,
            //                           color: Colors.black87,
            //                         ),
            //                       ),
            //                       const Text(
            //                         '家乡',
            //                         style: TextStyle(
            //                           color: Colors.black87,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Container(
              height: 1.5,
              color: Colors.brown.shade300,
            ),
            Expanded(
              child: IndexedStack(
                index: viewModel.selectedIndex,
                children: <Widget>[
                  const PinterestView(),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: viewModel.jsonCacheKey.value('uuuprofile'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.green));
                      } else if (snapshot.hasError) {
                        return Center(child: Text('错误: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            '照片数据正在制作中 ...',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        );
                      }

                      final imageData = snapshot.data!;

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          childAspectRatio: 0.680,
                        ),
                        itemCount: imageData.length,
                        itemBuilder: (context, index) {
                          return ImageCardWidget(
                            context: context,
                            viewModel: viewModel,
                            imageData: imageData,
                            index: index,
                          );
                        },
                      );
                    },
                  ),
                  const Center(child: Text('3')),
                  const Center(child: Text('4')),
                  const Center(child: Text('5')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ProfileViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ProfileViewModel();
}

class NavigationButtons extends StatelessWidget {
  final List<Map<String, dynamic>> buttonConfigs;
  final Function(int) onButtonTap;

  const NavigationButtons({
    super.key,
    required this.buttonConfigs,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          buttonConfigs.length,
          (index) => Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Ink(
              decoration: BoxDecoration(
                color: buttonConfigs[index]['bgColor'],
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  onTap: () {
                    onButtonTap(index); // 返回按钮的索引
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tooltip(
                      message: buttonConfigs[index]['tooltip'],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: buttonConfigs[index]['iconBgColor'],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                buttonConfigs[index]['icon'],
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            buttonConfigs[index]['text'],
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageCardWidget extends StatelessWidget {
  final BuildContext context;
  final ProfileViewModel viewModel;
  final Map<String, dynamic> imageData;
  final int index;

  const ImageCardWidget({
    Key? key,
    required this.context,
    required this.viewModel,
    required this.imageData,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    final imageUrl = imageData.keys.elementAt(index); // 获取图像URL
    final details = imageData[imageUrl]!; // 获取对应的 details
    final placeName = details['placeName'] ?? '';
    final name = details['name'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 5.0),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: deviceHeight * 0.86,
        ),
        width: deviceWidth * 0.92,
        child: Column(
          children: [
            // 图像部分
            DottedBorder(
              borderType: BorderType.RRect,
              dashPattern: [18, 10],
              radius: const Radius.circular(16.0),
              padding: const EdgeInsets.all(8.0),
              color: Colors.black87,
              child: GestureDetector(
                  onTap: () {
                    FullscreenImageViewer.open(
                      context: context,
                      child: FastCachedImage(
                        fadeInDuration: const Duration(milliseconds: 123),
                        url: imageUrl,
                        fit: BoxFit.contain,
                      ),
                      closeWidget:
                          const Icon(Hero_icons_outline.x_mark), // 关闭按钮
                      saveWidget:
                          const Icon(Hero_icons_outline.heart), // 如果需要保存按钮可以传入
                      onTap: () async {
                        // 只有当 value 为 false 时执行保存逻辑
                        print('准备保存图像：$imageUrl');

                        // 保存图像到相册
                        await viewModel.saveCachedImageToGallery(imageUrl);

                        // 显示成功的 Toast 消息
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
                                        "已经保存到可爱的相册中",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(milliseconds: 2350),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: FastCachedImage(
                    url: imageUrl, // 替换为你的图像 URL
                    fit: BoxFit.contain, // 设置适配模式
                    fadeInDuration:
                        const Duration(milliseconds: 210), // 设置淡入动画时长
                    errorBuilder: (context, exception, stacktrace) {
                      // 保持错误处理的行为不变，返回 ErrorWidgetWithRetry
                      return ErrorWidgetWithRetry(url: imageUrl);
                    },
                    loadingBuilder: (context, progress) {
                      // 加载过程中的显示内容
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              color: Colors.green[50], // 显示红色进度指示器
                              value:
                                  progress.progressPercentage.value, // 设置加载进度
                            ),
                          ),
                        ],
                      );
                    },
                  )),
            ),
            // 文本信息部分
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoSection(
                  placeName: placeName,
                  name: name,
                ),
                ShareButton(
                  imageUrl: imageUrl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorWidgetWithRetry extends StatelessWidget {
  final String url;

  const ErrorWidgetWithRetry({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Material(
      borderRadius: BorderRadius.circular(16.0),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ynaditiy19(url: url),
            ),
          );
          print('点击了卡片');
        },
        focusColor: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          width: deviceWidth * 0.91,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GptMarkdown(
                  '[家乡的故事日记视频]($url)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right,
                  onLinkTab: (String url, String text) async {
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),
              SizedBox(
                height: 220,
                width: 220,
                child: Lottie.asset(
                  'images/uuuvio.json',
                  frameRate: const FrameRate(120),
                  repeat: true,
                  animate: true,
                ),
              ),
              const GptMarkdown(
                '''🎬 **发现一个精彩视频！** 🎉
                点击整个的卡片即可开始浏览最新视频内容，不容错过哦！👇
                [📺 **点击这里，开启视频之旅** 🎥](https://example.com) 
                ✨ **准备好了吗？** 快来看看这个酷炫的内容吧！😎🍿
                ''',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String placeName;
  final String name;

  const InfoSection({
    Key? key,
    required this.placeName,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
      alignment: Alignment.bottomLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            placeName,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  final String imageUrl;

  const ShareButton({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Ink(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 219, 205),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: imageUrl)).then((_) {
                // 显示成功的 Toast 消息
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "已复制图像链接",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(milliseconds: 2350),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                );
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: '分享',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(250, 206, 96, 96),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Hero_icons_outline.arrow_up_on_square,
                          size: 18,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                    const Text(
                      '分享',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
