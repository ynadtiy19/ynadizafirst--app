import 'package:flutter/material.dart';
import 'package:hung/app/app.bottomsheets.dart';
import 'package:hung/app/app.dialogs.dart';
import 'package:hung/app/app.locator.dart';
import 'package:hung/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:zenith_snack_bar/zenith_snack_bar.dart';

import '../../../services/atchatclient_service.dart';
import '../../../services/authentication_service.dart';
import '../../../services/image_repository_service.dart';

class HomeViewModel extends ReactiveViewModel {
  final _dialogService = locator<DialogService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final ImageRepository = locator<ImageRepositoryService>();
  final homeviewchatclientPlugin = locator<AtchatclientService>();
  final homeauthenticationPlugin = locator<AuthenticationService>();

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [ImageRepository, homeviewchatclientPlugin];

  late ZenithSnackBarController beautifulcontroller =
      ZenithSnackBarController();
  ZenithSnackBarController get beautifulcontrollerValue => beautifulcontroller;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  String get counterLabel => 'Counter is: $_counter';
  final int _counter = 0;

  int _uuuindex = 0;
  int get uuuindex => _uuuindex;

  bool get uonboarded => homeviewchatclientPlugin.uonboarded;
  get username => homeviewchatclientPlugin.recievemessageValue;

  String? previousValue;
  get previousValueValue => previousValue;

  void onPreviousValueChange(String value) {
    previousValue = value;
    print('更改值 :$previousValue');
    rebuildUi(); // 通知视图更新,get到上面
  }

  @override
  HomeViewModel(BuildContext context) {
    print('开始初始化 HomeViewModel');
    homeviewchatclientPlugin.atauthenticateUser(context);
    homeauthenticationPlugin.loginCheck();
  }

  bool get isBottomNavVisibleValue => ImageRepository.isBottomNavVisibleValue;

  void onTabChange(int index) {
    _uuuindex = index; // 将选中的索引值发送到BehaviorSubject中
    print('uuu :$index');
    rebuildUi(); // 通知视图更新,get到上面
  }

  void showDialog() {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: 'Stacked Rocks!',
      description: 'Give stacked $_counter stars on Github',
    );
  }

  void showBottomSheet() {
    _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: ksHomeBottomSheetTitle,
      description: ksHomeBottomSheetDescription,
    );
  }

  @override
  void dispose() {
    beautifulcontroller.dispose();
    super.dispose();
  }
}
