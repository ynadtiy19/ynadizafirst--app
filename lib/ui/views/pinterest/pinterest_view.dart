import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:high_q_paginated_drop_down/high_q_paginated_drop_down.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:stacked/stacked.dart';

import '../../utils/hero-icons-outline_icons.dart';
import '../../widgets/common/fullscreen/fullscreen_image_viewer.dart';
import 'pinterest_viewmodel.dart';

class PinterestView extends StackedView<PinterestViewModel> {
  const PinterestView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PinterestViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 255, 219, 205),
      body: Column(
        children: [
          AnimatedCrossFade(
            secondChild: const SizedBox.shrink(),
            firstChild: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: Text(
                'Pinterest',
                style: GoogleFonts.sacramento().copyWith(
                  color: const Color.fromARGB(255, 5, 5, 2),
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Hero_icons_outline.archive_box_x_mark),
                  onPressed: () {
                    viewModel.deleteGalleryImage(context);
                  },
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      Hero_icons_outline.magnifying_glass,
                      color: Colors.lightGreenAccent,
                    ),
                    onPressed: () {
                      _ushowSearchBar(context, viewModel);
                    },
                  ),
                ),
              ],
            ),
            crossFadeState: viewModel.isappbarVisible
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: viewModel.appbarscrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.imageUrls.length,
              itemBuilder: (context, index) {
                final imageId = viewModel.imageUrls[index];
                final deviceWidth = MediaQuery.of(context).size.width;
                final segmentsForImage = PinterestViewModel.segments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: ImageGridItem(
                    imageId: imageId,
                    index: index,
                    deviceWidth: deviceWidth,
                    segmentsForImage: segmentsForImage,
                    onTitleTap: viewModel.translatetitleText,
                    onTitleDoubleTap: viewModel.changetoBack,
                    onImageSave: viewModel.saveCachedImageToGallery,
                    viewModel: viewModel,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _ushowSearchBar(BuildContext context, PinterestViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // 允许空白区域的点击
          onTap: () {
            FocusScope.of(context).unfocus(); // 收起键盘
            Navigator.of(context).pop(); // 点击空白区域关闭对话框
          },
          child: Align(
            alignment: Alignment.topCenter, // 对齐到顶部
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0), // 距离顶部的距离
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    color: Colors.transparent,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        HighQPaginatedDropdown<Scenery>.paginated(
                          key: viewModel.dropdownFormFieldKey,
                          controller: viewModel.dropdownValue1,
                          requestItemCount: 25,
                          width: 10,
                          loadingWidget: const CircularProgressIndicator(
                            color: Colors.green,
                          ),
                          backgroundDecoration: (child) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    15.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                labelText: '关键词搜索',
                              ),
                              child: child,
                            );
                          },
                          hintText: const Text(
                            '输入关键词搜索',
                            style: TextStyle(color: Colors.black),
                          ),
                          paginatedRequest: (
                            int page,
                            String? searchText,
                          ) async {
                            String query = searchText ??
                                'winter'; //searchText存在但是为空，就会返回winter
                            print('开始翻译：$query');
                            var q = await viewModel.translateText(query);
                            print('q: $q');
                            final List<Map<String, dynamic>> prompts =
                                await viewModel.fetchPinterestPromoteData(q);

                            if (prompts.isNotEmpty) {
                              return prompts.map((item) {
                                final scenery = Scenery.fromJson(item);
                                return MenuItemModel<Scenery>(
                                  value: scenery,
                                  label: scenery.keyword,
                                  child: Text(
                                    scenery.keyword,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList();
                            } else {
                              return [];
                            }
                          },
                          padding: const EdgeInsets.all(8),
                          onChanged: (Scenery? value) {
                            if (value != null) {
                              viewModel.changedquery(value.keyword);
                            } else {
                              // 处理 value 为 null 的情况，例如打印日志或使用默认值
                              debugPrint('value is null');
                            }
                          },
                          hasTrailingClearIcon: true,
                          trailingIcon: const Icon(
                            Hero_icons_outline.arrow_down_circle,
                            color: Colors.green,
                          ),
                          searchHintText: 'Pinterest关键词',
                          trailingClearIcon: const Icon(
                            Hero_icons_outline.trash,
                            color: Colors.green,
                          ),
                          searchDelayDuration: const Duration(seconds: 4),
                          leadingIcon: IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus(); // 收起键盘
                              Navigator.of(context).pop(); // 关闭弹窗
                              viewModel.fetchAndParseData(
                                  viewModel.uquery); // 执行搜索逻辑
                              print('搜索');
                            },
                            icon: const Icon(
                              Hero_icons_outline.globe_alt,
                              color: Colors.green,
                            ),
                          ),
                          spaceBetweenDropDownAndItemsDialog: 10,
                          isEnabled: true,
                          onTapWhileDisableDropDown: () {
                            print('搜索栏已经放下 ');
                          },
                          //dropDownMaxHeight: 150,
                          isDialogExpanded: true,
                          paddingValueWhileIsDialogExpanded: 16, //更改大小
                          noRecordText: const Text('No records found'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  PinterestViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PinterestViewModel();
}

class ImageGridItem extends StatelessWidget {
  final Map<String, dynamic> imageId;
  final int index;
  final double deviceWidth;
  final List<Segment>? segmentsForImage;
  final Function(int, String) onTitleTap;
  final Function(int) onTitleDoubleTap;
  final Function(String) onImageSave;
  final PinterestViewModel viewModel;

  const ImageGridItem({
    Key? key,
    required this.imageId,
    required this.index,
    required this.deviceWidth,
    this.segmentsForImage,
    required this.onTitleTap,
    required this.onTitleDoubleTap,
    required this.onImageSave,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String url = imageId['url'] as String;
    final String originalUrl = imageId['original'] as String;
    final String title = imageId['title'] as String;

    return Material(
      color: const Color.fromARGB(255, 221, 233, 233), // 设置Material背景颜色
      borderRadius: BorderRadius.circular(15.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0), // 使 InkWell 的点击效果也有圆角
        splashColor: const Color.fromARGB(255, 230, 194, 180), // 点击水波纹颜色
        highlightColor: const Color.fromARGB(255, 196, 208, 208), // 点击高亮颜色
        focusColor: const Color.fromARGB(255, 200, 165, 206), // 聚焦颜色
        onLongPress: () {
          // 点击事件
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 标题和描述
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: GestureDetector(
                        onTap: () => onTitleTap(index, title),
                        onDoubleTap: () => onTitleDoubleTap(index),
                        child: AutoSizeText(
                          title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Hero_icons_outline.check_badge,
                    color: Color.fromRGBO(255, 192, 23, 1),
                  ),
                ],
              ),
              PrimerProgressBar(
                barStyle: SegmentedBarStyle(
                  backgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.all(4.0),
                  gap: 1.0,
                ),
                segments: segmentsForImage ?? [],
                showLegend: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetector(
                  onTap: () {
                    FullscreenImageViewer.open(
                      context: context,
                      child: FastCachedImage(
                        fadeInDuration: const Duration(milliseconds: 123),
                        url: url,
                        fit: BoxFit.contain,
                      ),
                      closeWidget:
                          const Icon(Hero_icons_outline.x_mark), // 关闭按钮
                      saveWidget:
                          const Icon(Hero_icons_outline.heart), // 如果需要保存按钮可以传入
                      onTap: () async {
                        // 只有当 value 为 false 时执行保存逻辑
                        print(originalUrl);
                        await onImageSave(url);
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
                                Text(
                                  "Pin图已经保存到相册中.",
                                  style: TextStyle(color: Colors.white),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double containerWidth = constraints.maxWidth;
                        final double containerHeight = containerWidth * 0.85;

                        return Container(
                          height: containerHeight.clamp(
                            containerWidth * 0.6,
                            containerWidth * 1.2,
                          ), // 限制高度
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.transparent,
                          ),
                          child: FastCachedImage(
                            url: url,
                            fit: BoxFit.contain, // 使用 BoxFit.contain 填充图像
                            fadeInDuration: const Duration(seconds: 1),
                            errorBuilder: (context, exception, stacktrace) {
                              return const Center(
                                  child: Icon(Icons.error)); // 错误时显示图标
                            },
                            loadingBuilder: (context, progress) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                  value: progress
                                      .progressPercentage.value, // 显示下载进度
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 1.5,
                color: Colors.brown.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
