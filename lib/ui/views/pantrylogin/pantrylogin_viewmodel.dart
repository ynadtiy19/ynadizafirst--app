import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hung/app/app.router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';
import '../../../services/authentication_service.dart';

class PantryloginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final authenticationService = locator<AuthenticationService>();
  get uuuauthenticationService => authenticationService;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  get usernameController => _usernameController;
  get passwordController => _passwordController;

  Future<void> handleLogin(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // You can handle the login logic here
    // For example, call an API, validate the input, etc.
    if (username.isNotEmpty && password.isNotEmpty) {
      print("Username: $username");
      print("Password: $password");
      final i = await authenticationService.userLoggedIn(username, password);
      if (i) {
        final prefs = await SharedPreferences.getInstance();
        Map<String, String> userInfo = {
          'username': username,
          'password': password,
        };
        // 将 Map 转换为 JSON 字符串
        String jsonUserInfo = jsonEncode(userInfo);

        // 将 JSON 字符串存储到 SharedPreferences
        await prefs.setString('userinfo', jsonUserInfo);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登入成功!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        runPantryLogic();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('验证失败!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print("Username or password cannot be empty.");
    }
    print("登入之后: ${authenticationService.isLoggedInValue}");
  }

  Future runPantryLogic() async {
    if (authenticationService.isLoggedInValue) {
      _navigationService.replaceWithHomeView();
    }
    notifyListeners();
  }

  Future runPantryregisterLogic() async {
    _navigationService.navigateToStartupView(); //默认包含返回按钮
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
