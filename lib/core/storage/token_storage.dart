import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'auth_token';
  static const _refresh_key = 'auth_refresh_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  static Future<void> saveRefreshToken(String refresh_token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refresh_key, refresh_token);
  }

  static Future<void> saveTokens({
    required String access_token,
    String? refresh_token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, access_token);
    if (refresh_token != null && refresh_token.isNotEmpty) {
      await prefs.setString(_refresh_key, refresh_token);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refresh_key);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_refresh_key);
  }
}
