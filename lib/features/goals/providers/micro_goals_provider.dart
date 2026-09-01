import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../plans/models/recipe.dart';
import '../../streak/providers/streak_provider.dart';
import '../data/micro_goal_definitions.dart';

class MicroGoalsState {
  final Map<String, int> progress;
  final Map<String, String> daily_dates;
  final Set<String> week_meal_dates;
  final bool is_ready;

  const MicroGoalsState({
    this.progress = const {},
    this.daily_dates = const {},
    this.week_meal_dates = const {},
    this.is_ready = false,
  });

  int valueFor(String id) => progress[id] ?? 0;

  bool isDone(MicroGoalDefinition def) {
    if (def.kind == MicroGoalKind.daily) {
      return valueFor(def.id) >= def.target && daily_dates[def.id] == _todayKey();
    }
    return valueFor(def.id) >= def.target;
  }

  double ratioFor(MicroGoalDefinition def) {
    final current = displayValue(def);
    if (def.target <= 0) return 0;
    return (current / def.target).clamp(0.0, 1.0);
  }

  int displayValue(MicroGoalDefinition def) {
    if (def.kind == MicroGoalKind.daily && daily_dates[def.id] != _todayKey()) {
      return 0;
    }
    return valueFor(def.id);
  }

  int get completed_today_count {
    var count = 0;
    for (final def in microGoalDefinitions) {
      if (isDone(def)) count += 1;
    }
    return count;
  }
}

String _todayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Set<String> _currentWeekKeys() {
  final now = DateTime.now();
  final weekday = now.weekday;
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: weekday - 1));
  return {
    for (var i = 0; i < 7; i++) _dateKey(start.add(Duration(days: i))),
  };
}

class MicroGoalsNotifier extends Notifier<MicroGoalsState> {
  static const _storage_key = 'micro_goals_v1';
  bool _loaded = false;

  @override
  MicroGoalsState build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return const MicroGoalsState();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storage_key);
    if (raw == null || raw.isEmpty) {
      state = const MicroGoalsState(is_ready: true);
      await _syncStreakMilestone();
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = _stateFromMap(map);
      await _syncStreakMilestone();
    } catch (_) {
      state = const MicroGoalsState(is_ready: true);
    }
  }

  MicroGoalsState _stateFromMap(Map<String, dynamic> map) {
    final progress_raw = map['progress'];
    final dates_raw = map['daily_dates'];
    final week_raw = map['week_meal_dates'];

    final progress = <String, int>{};
    if (progress_raw is Map) {
      progress_raw.forEach((key, value) {
        progress[key.toString()] = int.tryParse(value.toString()) ?? 0;
      });
    }

    final daily_dates = <String, String>{};
    if (dates_raw is Map) {
      dates_raw.forEach((key, value) {
        daily_dates[key.toString()] = value.toString();
      });
    }

    final week_meal_dates = <String>{};
    if (week_raw is List) {
      week_meal_dates.addAll(week_raw.map((e) => e.toString()));
    }

    final week_keys = _currentWeekKeys();
    week_meal_dates.removeWhere((d) => !week_keys.contains(d));
    progress['cook_week'] = week_meal_dates.length;

    return MicroGoalsState(
      progress: progress,
      daily_dates: daily_dates,
      week_meal_dates: week_meal_dates,
      is_ready: true,
    );
  }

  Future<void> applyFromCloud(Map<String, dynamic> map) async {
    state = _stateFromMap(map);
    await _persist(sync_cloud: false);
    await _syncStreakMilestone(sync_cloud: true);
  }

  Future<void> recordEvent(String goal_id, {int amount = 1}) async {
    final def = microGoalById(goal_id);
    if (def == null) return;

    final today = _todayKey();
    final progress = Map<String, int>.from(state.progress);
    final daily_dates = Map<String, String>.from(state.daily_dates);

    if (def.kind == MicroGoalKind.daily) {
      if (daily_dates[goal_id] != today) {
        progress[goal_id] = 0;
      }
      final next = (progress[goal_id] ?? 0) + amount;
      progress[goal_id] = next > def.target ? def.target : next;
      daily_dates[goal_id] = today;
    } else {
      final next = (progress[goal_id] ?? 0) + amount;
      progress[goal_id] = next > def.target ? def.target : next;
    }

    state = MicroGoalsState(
      progress: progress,
      daily_dates: daily_dates,
      week_meal_dates: state.week_meal_dates,
      is_ready: true,
    );
    await _persist();
  }

  Future<void> recordMealCompletion(Recipe recipe) async {
    final today = _todayKey();
    await recordEvent('eat_today');

    final hour = DateTime.now().hour;
    final protein_grams = _parseProteinGrams(recipe.protein);
    final is_high_protein = protein_grams >= 15 ||
        recipe.tags.any((t) => t.label.toUpperCase().contains('PROTEIN'));
    if (hour < 10 && is_high_protein) {
      await recordEvent('protein_by_10');
    }

    final week_dates = Set<String>.from(state.week_meal_dates)..add(today);
    final week_keys = _currentWeekKeys();
    week_dates.removeWhere((d) => !week_keys.contains(d));

    final progress = Map<String, int>.from(state.progress);
    progress['cook_week'] = week_dates.length.clamp(0, 3);

    state = MicroGoalsState(
      progress: progress,
      daily_dates: state.daily_dates,
      week_meal_dates: week_dates,
      is_ready: true,
    );
    await _persist();
    await _syncStreakMilestone();
  }

  Future<void> _syncStreakMilestone({bool sync_cloud = true}) async {
    final streak = ref.read(streakProvider).current_streak;
    final progress = Map<String, int>.from(state.progress);
    final current = progress['streak_3'] ?? 0;
    final next = streak.clamp(0, 3);
    if (next == current && state.is_ready) {
      if (!sync_cloud) return;
    }
    progress['streak_3'] = next;
    state = MicroGoalsState(
      progress: progress,
      daily_dates: state.daily_dates,
      week_meal_dates: state.week_meal_dates,
      is_ready: true,
    );
    await _persist(sync_cloud: sync_cloud);
  }

  int _parseProteinGrams(String protein) {
    final match = RegExp(r'(\d+)').firstMatch(protein);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  Future<void> _persist({bool sync_cloud = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'progress': state.progress,
      'daily_dates': state.daily_dates,
      'week_meal_dates': state.week_meal_dates.toList(),
    };
    await prefs.setString(_storage_key, jsonEncode(payload));
    if (sync_cloud) {
      await ApiService.saveUserProfile({'micro_goals': payload});
    }
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storage_key);
    state = const MicroGoalsState(is_ready: true);
  }
}

final microGoalsProvider =
    NotifierProvider<MicroGoalsNotifier, MicroGoalsState>(
  MicroGoalsNotifier.new,
);
