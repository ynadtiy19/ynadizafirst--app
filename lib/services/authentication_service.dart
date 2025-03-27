import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class AuthenticationService with ListenableServiceMixin {
  PostService() {
    listenToReactiveValues([isLoggedIn]);
  }

  late bool isLoggedIn = false;
  get isLoggedInValue => isLoggedIn;

  void changeIsLoggedIn(bool value) {
    isLoggedIn = value;
    notifyListeners();
  }

  // URL for fetching the user data
  final String url =
      'https://getpantry.cloud/apiv1/pantry/2fbe822d-f24a-4c50-9218-636436f98e40/basket/ynadtiyuser';

  Future<bool> loginCheck() async {
    final prefs = await SharedPreferences.getInstance();
    // ⚡ 先判断用户是否已登录
    String? jsonUserInfo = prefs.getString('userinfo');

    if (jsonUserInfo != null) {
      Map<String, dynamic> userInfo = jsonDecode(jsonUserInfo);
      String username = userInfo['username'];
      String password = userInfo['password'];
      return await userLoggedIn(username, password);
    } else {
      return false;
    }
  }

  // Function to check if the user is logged in based on username and password
  Future<bool> userLoggedIn(String username, String password) async {
    try {
      // Send a GET request to the URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Decode the JSON response
        Map<String, dynamic> data = json.decode(response.body);
        print(data);

        // Check if the username exists in the users map
        if (data['users'] != null && data['users'][username] != null) {
          // Get the user's password from the response
          String storedPassword = data['users'][username]['password'];

          // Compare the stored password with the provided password
          if (storedPassword == password) {
            changeIsLoggedIn(true);
            return true; // Login success
          } else {
            changeIsLoggedIn(false);
            return false; // Password doesn't match
          }
        } else {
          changeIsLoggedIn(false);
          return false; // Username not found
        }
      } else {
        changeIsLoggedIn(false);
        return false; // Request failed (non-200 response)
      }
    } catch (e) {
      changeIsLoggedIn(false);
      print('Error: $e');
      return false; // Error in fetching or processing data
    }
  }

  Future<bool> updateUserData(
      String _email, String _username, String _password) async {
    // 获取当前日期并格式化为"2025-03-17T09:28:00Z"
    String currentDate = DateTime.now().toUtc().toIso8601String();

    // 构建请求体
    Map<String, dynamic> requestBody = {
      "users": {
        _username: {
          "username": _username,
          "password": _password,
          "email": _email,
          "registerDate": currentDate,
          "status": "active",
        }
      }
    };

    // 发送 PUT 请求
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    // 处理响应
    if (response.statusCode == 200) {
      print('User data updated successfully');
      return true;
    } else {
      print('Failed to update user data: ${response.statusCode}');
      return false;
    }
  }
}
