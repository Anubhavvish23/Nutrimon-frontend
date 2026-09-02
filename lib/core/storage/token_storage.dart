import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _key = 'auth_token';
  static const _refresh_key = 'auth_refresh_token';
  static const _expires_key = 'auth_token_expires_at';

  static DateTime? jwt_expiry(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is! Map) return null;
      final exp = payload['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          (exp * 1000).round(),
          isUtc: true,
        );
      }
    } catch (_) {}
    return null;
  }

  static Future<void> _persist_expiry(SharedPreferences prefs, String token) async {
    final expiry = jwt_expiry(token);
    if (expiry == null) {
      await prefs.remove(_expires_key);
      return;
    }
    await prefs.setInt(_expires_key, expiry.millisecondsSinceEpoch);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
    await _persist_expiry(prefs, token);
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
    await _persist_expiry(prefs, access_token);
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

  static Future<bool> is_expiring_soon({
    Duration window = const Duration(minutes: 5),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    var millis = prefs.getInt(_expires_key);
    if (millis == null) {
      final token = prefs.getString(_key);
      if (token == null || token.isEmpty) return false;
      final expiry = jwt_expiry(token);
      if (expiry == null) return true;
      millis = expiry.millisecondsSinceEpoch;
      await prefs.setInt(_expires_key, millis);
    }
    final expiry = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    return DateTime.now().toUtc().isAfter(expiry.subtract(window));
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_refresh_key);
    await prefs.remove(_expires_key);
  }
}
