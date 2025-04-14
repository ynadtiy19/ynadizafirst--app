import 'dart:io';

import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hung/ui/animationartical/models/models.dart';
import 'package:hung/ui/animationartical/passport.dart';
import 'package:hung/ui/animationartical/passport_dialog.dart';
import 'package:hung/ui/animationartical/passport_dialog_route.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../animationartical/focus_detector.dart';
import '../../utils/hero-icons-outline_icons.dart';
import '../../webviewsite/musicsite.dart';
import '../../widgets/common/translation/translation.dart';
import 'article_viewmodel.dart';
import 'cupertino_tabbar.dart';

class ArticleView extends StackedView<ArticleViewModel> {
  const ArticleView({super.key});

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget builder(
    BuildContext context,
    ArticleViewModel viewModel,
    Widget? child,
  ) {
    return DefaultTabController(
      length: 2,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final TabController tabController = DefaultTabController.of(context);
          // 判断 twoPagesfetchData 是否为空
          if ((viewModel.twoPagesfetchDataFirst == null ||
                  viewModel.twoPagesfetchDataFirst!.isEmpty) &&
              (viewModel.twoPagesfetchDataSecond == null ||
                  viewModel.twoPagesfetchDataSecond!.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          var udata = viewModel.twoPagesfetchDataFirst!; //可以为空
          var udata1 = viewModel.twoPagesfetchDataSecond!;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: const Color.fromARGB(100, 255, 219, 205),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    NestedScrollView(
                      body: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: tabController,
                        children: [
                          // 第一个 tab 内容
                          RefreshIndicator(
                            color: Colors.black87,
                            onRefresh: () async {
                              viewModel.changeColor();
                              await viewModel.readtimefetchData();
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              // viewModel.refreshStorylyView();
                            },
                            child: ListView.builder(
                              itemCount: udata.keys.length,
                              itemBuilder: (BuildContext context, int index) {
                                String key = udata.keys.elementAt(index);
                                var article = udata[key];
                                return FocusDetector.mobile(
                                  key: ValueKey(apartments[index].host.id),
                                  builder: (context, isFocused) => ArticleCard(
                                    color: index % 2 == 0
                                        ? viewModel.uuucolor0
                                        : viewModel.uuucolor1,
                                    isFocused: isFocused,
                                    apartment: apartments[index],
                                    avatarUrl: article['avatarUrl'],
                                    isEligibleForRevenue:
                                        article['isEligibleForRevenue'],
                                    name: article['name'],
                                    title: article['title'], // 解码 'title' 字段
                                    readingTime: article['readingTime'],
                                    postImg: article['postImg'],
                                    pushid: article['uniqueSlug'],
                                  ),
                                );
                              },
                            ),
                          ),
                          // 第二个 tab 内容
                          RefreshIndicator(
                            color: Colors.brown,
                            onRefresh: () async {
                              await viewModel.freeMediumfetchData();
                              await Future.delayed(
                                  const Duration(milliseconds: 1200));
                            },
                            child: ListView.builder(
                              itemCount: udata1.keys.length,
                              itemBuilder: (BuildContext context, int index) {
                                String key = udata1.keys.elementAt(index);
                                var article = udata1[key]!;
                                return SideHustleCard(data: article);
                              },
                            ),
                          ),
                        ],
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 35),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${getGreeting()}, 伙计!',
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('EEEE, MMMM d ')
                                              .format(DateTime.now()),
                                          style: const TextStyle(
                                            fontFamily: 'GabrielaStencil',
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                20.0), // 保留这一个
                                            child: Material(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20.0), //也可考虑去掉
                                              child: viewModel
                                                          .avatarImagePathValue ==
                                                      null
                                                  ? Image.asset(
                                                      'images/uu9.jpg',
                                                      width: 60.0,
                                                      height: 60.0,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.file(
                                                      File(viewModel
                                                          .avatarImagePathValue!),
                                                      width: 60.0,
                                                      height: 60.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.8),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                KeyboardListener(
                                  focusNode: FocusNode(),
                                  onKeyEvent: (KeyEvent event) {
                                    // 检查是否是放下按钮（一般是“返回”键）
                                    if (event is KeyDownEvent &&
                                        event.logicalKey ==
                                            LogicalKeyboardKey.escape) {
                                      // 关闭输入框的焦点
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  child: TextField(
                                    focusNode: viewModel.ArticalfocusNode,
                                    controller: viewModel.textEditingController,
                                    decoration: InputDecoration(
                                      hintText: '搜索文章',
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: IconButton(
                                          icon: const Icon(
                                              color: Colors.lightGreen,
                                              Hero_icons_outline
                                                  .magnifying_glass),
                                          onPressed: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            String query = viewModel
                                                .textEditingController.text;
                                            if (query.isNotEmpty) {
                                              FocusScope.of(context).unfocus();
                                              viewModel
                                                  .fetchData(query)
                                                  .then((uuudata) {
                                                viewModel.changeColor();
                                              }).catchError((error) {
                                                print(
                                                    'Error fetching data: $error');
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                          color: Colors.lightGreen, // 聚焦时的粉橙色边框
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Material(
                                  color: viewModel.isfetching
                                      ? const Color.fromARGB(255, 230, 194, 180)
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Translation(
                                            translations:
                                                viewModel.encategories,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: InkWell(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          onTap: () async {
                                            if (viewModel.isfetching) {
                                              print('不执行逻辑');
                                              viewModel.changeisFetching();
                                            } else {
                                              await viewModel
                                                  .fetchPromoteData(true);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Tooltip(
                                              message: '获取tags',
                                              child: Icon(
                                                size: 30,
                                                Hero_icons_outline.light_bulb,
                                                color: viewModel.isfetching
                                                    ? Colors.purple
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Row(
                                        children: viewModel.categories
                                            .asMap() // 将 List 转换为一个 Map，允许获取索引
                                            .map((index, category) {
                                              return MapEntry(
                                                index,
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  child: CategoryChip(
                                                    label: category,
                                                    isSelected: viewModel
                                                            .selectedCategory ==
                                                        category,
                                                    onSelected: (isSelected) {
                                                      // 在此处传递索引
                                                      viewModel
                                                          .onCategorySelected(
                                                              isSelected,
                                                              index);
                                                    },
                                                  ),
                                                ),
                                              );
                                            })
                                            .values
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),

                    const SizedBox(height: 20),
                    // Positioned CupertinoTabBar at the bottom
                    Positioned(
                      bottom: 20.0, // Distance from the bottom of the screen
                      left: 50,
                      right: 50,
                      child: CupertinoTabBar(
                        const Color(0xFFd4d7dd),
                        const Color(0xFFf7f7f7),
                        const [
                          Text(
                            "最新文章",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.75,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "为您推荐",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.75,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        () {
                          return viewModel.twoPageschangeindex;
                        },
                        (int index) {
                          tabController.animateTo(index); //切换页面(确定)
                          viewModel.changePageByCupertionIndex(index);
                        },
                        useShadow: true,
                        innerHorizontalPadding: 40,
                        useSeparators: true, // 不使用分隔线
                        innerVerticalPadding: 8.0, // 内部垂直间距
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)), // 圆角
                        curve: Curves.linearToEaseOut, // 动画曲线
                        duration: const Duration(seconds: 1), // 动画持续时间
                        allowExpand: true, // 不允许展开
                        allowScrollable: true, // 允许滚动
                        fittedWhenScrollable: true, // 当滚动时不收缩
                        animateWhenScrollable: true, // 当滚动时启用动画
                        // animateUntilScrolled: false, // 直到滚动停止才启用动画
                        // outerHorizontalPadding: 5.0, // 外部水平间距
                        outerVerticalPadding: 20.0, // 外部垂直间距
                        outerHorizontalPadding: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  ArticleViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ArticleViewModel();
}

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  CategoryChip(
      {required this.label,
      required this.isSelected,
      required this.onSelected});

  @override
  _CategoryChipState createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _isSelected = widget.isSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: FilterChip(
        label: Text(widget.label),
        selected: _isSelected,
        onSelected: (selected) {
          setState(() {
            _isSelected = selected;
          });
          widget.onSelected(widget.label);
        },
        selectedColor: const Color.fromRGBO(253, 218, 225, 1),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(
          color: _isSelected
              ? const Color.fromRGBO(253, 218, 225, 255)
              : Colors.black,
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontWeight: _isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

final class ArticleCard extends StatefulWidget {
  final String name;
  final String readingTime;
  final String title;
  final String avatarUrl;
  final String postImg;
  final bool isEligibleForRevenue;
  final Apartment apartment;
  final bool isFocused;
  final Color color;
  final String pushid;

  ArticleCard({
    required this.name,
    required this.readingTime,
    required this.title,
    required this.avatarUrl,
    required this.apartment,
    required this.isFocused,
    required this.color,
    required this.postImg,
    required this.isEligibleForRevenue,
    required this.pushid,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard>
    with SingleTickerProviderStateMixin {
  late final PassportController _controller = PassportController();

  @override
  void initState() {
    super.initState();

    _animateFocus();
  }

  @override
  void didUpdateWidget(covariant ArticleCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocused == widget.isFocused) {
      return;
    }

    _animateFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateFocus() {
    if (widget.isFocused) {
      _controller.open();
    } else {
      _controller.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromARGB(201, 200, 0, 255),
                      offset: Offset(1, 1),
                      spreadRadius: 1,
                      blurRadius: 1),
                  BoxShadow(
                      color: Color.fromARGB(255, 255, 238, 3),
                      offset: Offset(-1, -1),
                      spreadRadius: 1,
                      blurRadius: 1),
                ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: Card(
                  color: widget.color,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    //触发效果慢一些
                    splashFactory:
                        InkSparkle.constantTurbulenceSeedSplashFactory,
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MusicWebView(pushid: widget.pushid),
                        ),
                      );
                      print(widget.pushid);
                    },
                    splashColor: Colors.amber.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: FastCachedImageProvider(
                                      widget.avatarUrl, // 网络图片的URL
                                    ),
                                    radius: 20,
                                    onBackgroundImageError:
                                        (exception, stackTrace) {
                                      // 处理加载图片时的错误
                                      print('Error loading image: $exception');
                                    },
                                    // child: const CircularProgressIndicator(
                                    //   color: Colors.green,
                                    // ), // 可选：用于加载时显示
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              //如果required this.isEligibleForRevenue,中的isEligibleForRevenue为true，则显示Icon(Hero_icons_outline.check_badge)
                              const Icon(
                                Hero_icons_outline.check_badge,
                                color: Color.fromRGBO(255, 192, 23, 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: Stack(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 450,
                                    maxHeight: 200,
                                  ),

                                  // child: AspectRatio(
                                  //   aspectRatio: 16 / 9,
                                  //   child: HoverToZoom(
                                  //     imagePath: '${widget.imageUrl}',
                                  //   ),
                                  // ),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: FastCachedImage(
                                      fadeInDuration:
                                          const Duration(milliseconds: 123),
                                      url: widget.postImg,
                                      height: 500,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator(
                                        color: Colors.green,
                                      )), // 加载中占位符
                                      errorBuilder: (context, url, error) =>
                                          const Center(
                                              child:
                                                  Icon(Icons.error)), // 加载失败占位符
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PassportDialogRoute<void>(
                                            builder: (context) {
                                              return PassportDialog(
                                                host: widget.apartment.host,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Passport(
                                        key: ValueKey(
                                            'passport_${widget.apartment.host.id}'),
                                        host: widget.apartment.host,
                                        controller: _controller,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          LayoutBuilder(builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double containerWidth = constraints.maxWidth * 0.65;
                            return Container(
                              width: containerWidth,
                              child: Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            widget.readingTime,
                            style: const TextStyle(
                              color: Colors.grey,
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
          const Positioned(
            bottom: 2,
            right: 2,
            child: FavoriteButton(),
          ),
        ],
      ),
    );
  }
}

final class SideHustleCard extends StatelessWidget {
  final dynamic data;

  const SideHustleCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        //触发效果慢一些
        splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicWebView(pushid: data['partialLink']!),
            ),
          );
          print(data['partialLink']!);
        },
        splashColor: Colors.amber.withOpacity(0.3),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Stack(
                  children: [
                    Image.network(
                      data['imageUrl']!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '为您推荐',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content section (title, read time, description, etc.)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: AutoSizeText(
                      data['title']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            data['readTime']!,
                            style: TextStyle(color: Colors.grey[600]),
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: AutoSizeText(
                            data['date']!,
                            style: TextStyle(color: Colors.grey[600]),
                            minFontSize: 12,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AutoSizeText(
                      data['description']!,
                      style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      minFontSize: 14,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (data.containsKey('author'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                            radius: 12,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: AutoSizeText(
                              data['author']!,
                              style: TextStyle(color: Colors.grey[800]),
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: AutoSizeText(
                              data['freeStatus']!,
                              style: TextStyle(color: Colors.grey[800]),
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        String i = data['partialLink']!;

                        await launchUrl(Uri.parse('https://readmedium.com/$i'));
                      },
                      child: const AutoSizeText(
                        '阅读更多',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxFontSize: 18,
                        minFontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        // Text and icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Change the shape here
          side: const BorderSide(
              color: Color.fromARGB(255, 192, 147, 147)), // Border color
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 15), // Button padding
      ),
      child: LikeButton(
        // onTap: (bool isLiked) {
        //   return Future.value(!isLiked);
        // },
        animationDuration: const Duration(milliseconds: 800),
        size: 20,
        circleColor: const CircleColor(
            start: Color(0xff00ddff), end: Color.fromARGB(255, 241, 32, 32)),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Color.fromARGB(255, 229, 164, 12),
          dotSecondaryColor: Color.fromARGB(255, 221, 218, 26),
        ),
        bubblesSize: 100,
        likeBuilder: (bool isLiked) {
          return Icon(
            applyTextScaling: true,
            Hero_icons_outline.heart,
            color:
                isLiked ? const Color.fromARGB(255, 150, 213, 42) : Colors.grey,
            size: 20,
          );
        },
        likeCount: 25,
      ),
    );
  }
}
