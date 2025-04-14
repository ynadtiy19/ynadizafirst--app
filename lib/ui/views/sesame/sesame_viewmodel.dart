import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class SesameViewModel extends BaseViewModel {
  final String tokenKey = "id_token";
  final String tokenTimestampKey = "token_timestamp";
  final int tokenExpirySeconds = 1200;

  Future<String> fetchIdToken() async {
    final url = Uri.parse("https://mydiumtify.globeapp.dev/sesameai");
    //https://mydiumtify.globeapp.dev/sesamethirty

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data["id_token"] ?? "";
      } else {
        throw Exception("请求失败，状态码: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("请求 id_token 出错: $e");
    }
  }

  Future<void> storeIdToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setInt(
      tokenTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<String> getValidIdToken() async {
    final prefs = await SharedPreferences.getInstance();

    // 判断是否包含 tokenKey 和 tokenTimestampKey
    final hasToken = prefs.containsKey(tokenKey);
    final hasTimestamp = prefs.containsKey(tokenTimestampKey);

    final storedToken = hasToken ? prefs.getString(tokenKey) : null;
    final storedTimestamp =
        hasTimestamp ? prefs.getInt(tokenTimestampKey) ?? 0 : 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (storedToken != null &&
        (currentTime - storedTimestamp) < tokenExpirySeconds * 1000) {
      return storedToken;
    } else {
      final newToken = await fetchIdToken();
      await storeIdToken(newToken);
      return newToken;
    }
  }
}
