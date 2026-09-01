import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _name_key = 'user_name';
  static const _email_key = 'user_email';

  static Future<void> saveUser({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_name_key, name);
    await prefs.setString(_email_key, email);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_name_key);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email_key);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_name_key);
    await prefs.remove(_email_key);
  }
}
