import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hung/ui/common/app_colors.dart';
import 'package:side_rail/side_rail.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/hero-icons-outline_icons.dart';
import 'sider_bar_page_model.dart';

class SiderBarPage extends StackedView<SiderBarPageModel> {
  const SiderBarPage({super.key});

  @override
  Widget builder(
    BuildContext context,
    SiderBarPageModel viewModel,
    Widget? child,
  ) {
    bool isExpanded = false;
    return Scaffold(
      backgroundColor: kcRiceYellowColor,
      body: Row(
        children: [
          SideRail(
            selectedTextStyle: const TextStyle(color: Colors.white),
            isExpanded: !isExpanded,
            selectedIndex: SiderBarPageModel.selectedIndex,
            onTap: (index) {
              viewModel.SideRailRouteTo(context, index);
            },
            expandedWidth: 304,
            backgroundColor: kcRiceYellowColor,
            unselectedColor: Colors.black,
            tileActiveColor: Color(kcHotPinkWithTealColor.value),
            logoPadding: 20,
            margin: const EdgeInsets.all(3),
            logo: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(2), //控制外部边距
                      padding: const EdgeInsets.all(2), //控制内部边距
                      decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(15)),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber,
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(201, 200, 0, 255),
                                offset: Offset(10, 10),
                                spreadRadius: 2,
                                blurRadius: 20),
                            BoxShadow(
                                color: Color.fromARGB(255, 255, 238, 3),
                                offset: Offset(-10, -10),
                                spreadRadius: 2,
                                blurRadius: 20),
                          ]),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          await viewModel.initializeAndSelectImage();
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45.toDouble() + 2,
                              child: CircleAvatar(
                                radius: 45.toDouble(),
                                backgroundImage: viewModel
                                            .avatarImagePathValue !=
                                        null
                                    ? FileImage(File(
                                            viewModel.avatarImagePathValue!))
                                        as ImageProvider
                                    : const AssetImage('images/uu4.jpg'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Special.ldeyu",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: 18),
                          ),
                          Text(
                            "GoogleGDE&Dev",
                          ),
                        ])
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Material(
                      // 确保有Material组件
                      color: Colors.transparent, // Material的颜色应该是透明的
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => launchUrl(
                          Uri.parse(
                            'https://github.com/ynadtiy19',
                          ),
                        ),
                        child: Ink(
                          color: Colors.transparent, // 在这里设置颜色
                          child: const Text(
                            'MineSpecial',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.41),
                          ),
                        ),
                      ),
                    ),
                    const Icon(
                      Hero_icons_outline.cake,
                      color: Colors.amber,
                    ),
                    const Icon(Hero_icons_outline.envelope_open,
                        color: kcwaterGreenwithTeal),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => launchUrl(
                        Uri.parse(
                          'https://ko-fi.com/ynadtiy19',
                        ),
                      ),
                      child: const Text(
                        'SupportMe',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.41),
                      ),
                    ),
                    const Icon(Hero_icons_outline.shopping_bag,
                        color: Colors.pinkAccent),
                  ],
                ),
              ],
            ),
            footer: null,
            navItems: const [
              NavDestinationItem(
                  isSectionHeader: false,
                  radius: 20,
                  trailing: Icon(
                    Hero_icons_outline.arrow_top_right_on_square,
                    size: 21,
                  ),
                  icon: Icon(
                    Hero_icons_outline.chat_bubble_bottom_center_text,
                    size: 21,
                  ),
                  title: Text("Chating")),
              NavDestinationItem(
                  isSectionHeader: false,
                  radius: 20,
                  trailing: Icon(
                    Hero_icons_outline.arrow_top_right_on_square,
                    size: 21,
                  ),
                  icon: Icon(
                    Hero_icons_outline.viewfinder_circle,
                    size: 21,
                  ),
                  title: Text("Reals")),
              NavDestinationItem(
                  isSectionHeader: false,
                  radius: 20,
                  trailing: Icon(
                    Hero_icons_outline.arrow_top_right_on_square,
                    size: 21,
                  ),
                  icon: Icon(
                    Hero_icons_outline.credit_card,
                    size: 21,
                  ),
                  title: Text("Shoping")),
              NavDestinationItem(
                  isSectionHeader: false,
                  radius: 20,
                  trailing: Icon(
                    Hero_icons_outline.arrow_top_right_on_square,
                    size: 21,
                  ),
                  icon: Icon(
                    Hero_icons_outline.arrow_up_on_square,
                    size: 21,
                  ),
                  title: Text("About Me")),
            ],
          ),
        ],
      ),
    );
  }

  @override
  SiderBarPageModel viewModelBuilder(
    BuildContext context,
  ) =>
      SiderBarPageModel();
}
