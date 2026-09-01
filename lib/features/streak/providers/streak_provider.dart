import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/streak_data.dart';

class StreakNotifier extends Notifier<StreakData> {
  static const _current_key = 'streak_current';
  static const _longest_key = 'streak_longest';
  static const _last_date_key = 'streak_last_meal_date';
  static const _broken_pending_key = 'streak_broken_pending';
  static const _broken_from_key = 'streak_broken_from';

  bool _loaded = false;

  @override
  StreakData build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return const StreakData();
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _todayKey() => _dateKey(DateTime.now());

  String _yesterdayKey() =>
      _dateKey(DateTime.now().subtract(const Duration(days: 1)));

  bool _isYesterday(String date_key) => date_key == _yesterdayKey();

  bool _isToday(String date_key) => date_key == _todayKey();

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    var current = prefs.getInt(_current_key) ?? 0;
    final longest = prefs.getInt(_longest_key) ?? 0;
    final last_date = prefs.getString(_last_date_key);
    final today = _todayKey();
    var broken_pending = prefs.getBool(_broken_pending_key) ?? false;
    var broken_from = prefs.getInt(_broken_from_key) ?? 0;

    if (last_date != null &&
        current > 0 &&
        !_isToday(last_date) &&
        !_isYesterday(last_date)) {
      broken_from = current;
      broken_pending = true;
      current = 0;
      await prefs.setInt(_current_key, 0);
      await prefs.setBool(_broken_pending_key, true);
      await prefs.setInt(_broken_from_key, broken_from);
      await _syncCloud(
        current_streak: 0,
        longest_streak: longest,
        last_meal_date: last_date,
      );
    }

    state = StreakData(
      current_streak: current,
      longest_streak: longest,
      last_meal_date: last_date,
      logged_today: last_date == today,
      streak_just_broken: broken_pending,
      broken_from_streak: broken_from,
    );
  }

  Future<void> applyFromCloud({
    required int current_streak,
    required int longest_streak,
    String? last_meal_date,
  }) async {
    var current = current_streak;
    final today = _todayKey();
    final prefs = await SharedPreferences.getInstance();
    var broken_pending = prefs.getBool(_broken_pending_key) ?? false;
    var broken_from = prefs.getInt(_broken_from_key) ?? 0;

    if (last_meal_date != null &&
        last_meal_date.isNotEmpty &&
        current > 0 &&
        !_isToday(last_meal_date) &&
        !_isYesterday(last_meal_date)) {
      broken_from = current;
      broken_pending = true;
      current = 0;
      await prefs.setBool(_broken_pending_key, true);
      await prefs.setInt(_broken_from_key, broken_from);
    }

    state = StreakData(
      current_streak: current,
      longest_streak: longest_streak,
      last_meal_date: last_meal_date,
      logged_today: last_meal_date == today,
      streak_just_broken: broken_pending,
      broken_from_streak: broken_from,
    );

    await prefs.setInt(_current_key, current);
    await prefs.setInt(_longest_key, longest_streak);
    if (last_meal_date != null && last_meal_date.isNotEmpty) {
      await prefs.setString(_last_date_key, last_meal_date);
    }

    if (current != current_streak) {
      await _syncCloud(
        current_streak: current,
        longest_streak: longest_streak,
        last_meal_date: last_meal_date,
      );
    }
  }

  Future<void> acknowledgeStreakBroken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_broken_pending_key, false);
    await prefs.setInt(_broken_from_key, 0);
    state = state.copyWith(
      streak_just_broken: false,
      broken_from_streak: 0,
    );
  }

  Future<bool> recordMealCompletion() async {
    await _ensureLoaded();
    final today = _todayKey();
    if (state.last_meal_date == today) {
      return false;
    }

    var new_streak = 1;
    if (state.last_meal_date != null && _isYesterday(state.last_meal_date!)) {
      new_streak = state.current_streak + 1;
    }

    final new_longest =
        new_streak > state.longest_streak ? new_streak : state.longest_streak;

    state = StreakData(
      current_streak: new_streak,
      longest_streak: new_longest,
      last_meal_date: today,
      logged_today: true,
      streak_just_broken: false,
      broken_from_streak: 0,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_current_key, new_streak);
    await prefs.setInt(_longest_key, new_longest);
    await prefs.setString(_last_date_key, today);
    await prefs.setBool(_broken_pending_key, false);
    await prefs.setInt(_broken_from_key, 0);
    await _syncCloud(
      current_streak: new_streak,
      longest_streak: new_longest,
      last_meal_date: today,
    );
    return true;
  }

  Future<void> resetStreak() async {
    await _ensureLoaded();
    if (state.current_streak == 0 && !state.logged_today) return;

    final longest = state.longest_streak;
    final last_date = state.last_meal_date;
    final broken_from = state.current_streak;

    state = StreakData(
      current_streak: 0,
      longest_streak: longest,
      last_meal_date: last_date,
      logged_today: false,
      streak_just_broken: broken_from > 0,
      broken_from_streak: broken_from,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_current_key, 0);
    if (broken_from > 0) {
      await prefs.setBool(_broken_pending_key, true);
      await prefs.setInt(_broken_from_key, broken_from);
    }
    await _syncCloud(
      current_streak: 0,
      longest_streak: longest,
      last_meal_date: last_date,
    );
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_current_key);
    await prefs.remove(_longest_key);
    await prefs.remove(_last_date_key);
    await prefs.remove(_broken_pending_key);
    await prefs.remove(_broken_from_key);
    state = const StreakData();
  }

  Future<void> _syncCloud({
    required int current_streak,
    required int longest_streak,
    String? last_meal_date,
  }) async {
    await ApiService.saveUserProfile({
      'streak_current': current_streak,
      'streak_longest': longest_streak,
      if (last_meal_date != null) 'streak_last_meal_date': last_meal_date,
    });
  }

  Future<void> _ensureLoaded() async {
    if (state.last_meal_date == null &&
        state.current_streak == 0 &&
        !_loaded) {
      await _loadFromStorage();
    }
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakData>(
  StreakNotifier.new,
);
