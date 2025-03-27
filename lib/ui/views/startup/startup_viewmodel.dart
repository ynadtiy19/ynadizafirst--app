import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/authentication_service.dart';

class StartupViewModel extends BaseViewModel {
  final authenticationService = locator<AuthenticationService>();
  final _navigationService = locator<NavigationService>();
  final _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  late String _email;
  String get email => _email;
  late String _username;
  String get username => _username;
  late String _password;
  String get password => _password;

  setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      debugPrint('Email: $_email');
      debugPrint('Username: $_username');
      debugPrint('Password: $_password');
      if (_email.isNotEmpty && _username.isNotEmpty && _password.isNotEmpty) {
        bool i = await authenticationService.updateUserData(
            _email, username, password);
        if (i) {
          final prefs = await SharedPreferences.getInstance();
          Map<String, String> userInfo = {
            'email': _email,
            'username': username,
            'password': password,
          };
          // 将 Map 转换为 JSON 字符串
          String jsonUserInfo = jsonEncode(userInfo);

          // 将 JSON 字符串存储到 SharedPreferences
          await prefs.setString('userinfo', jsonUserInfo);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('注册成功!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          runStartupLogic();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('网络错误!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("Username or password cannot be empty.");
      }
      // 这里可以调用 API 或处理注册逻辑
      notifyListeners();
    }
  }

  Future runStartupLogic() async {
    _navigationService.replaceWithHomeView();

    notifyListeners();
  }
}
