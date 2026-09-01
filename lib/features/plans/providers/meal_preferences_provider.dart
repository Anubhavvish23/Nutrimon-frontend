import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class MealPreferencesState {
  final String? diet_type;
  final Set<String> meal_goals;
  final String? gender;
  final Set<String> activities;
  final bool has_selected_diet;
  final bool has_selected_goals;
  final bool has_selected_gender;
  final bool has_selected_activities;
  final bool is_ready;

  const MealPreferencesState({
    this.diet_type,
    this.meal_goals = const {},
    this.gender,
    this.activities = const {},
    this.has_selected_diet = false,
    this.has_selected_goals = false,
    this.has_selected_gender = false,
    this.has_selected_activities = false,
    this.is_ready = false,
  });

  bool get is_veg => diet_type == 'veg';
  String get diet_label => is_veg ? 'Vegetarian' : 'Non-veg';
  bool get has_completed_setup =>
      has_selected_diet &&
      diet_type != null &&
      has_selected_goals &&
      meal_goals.isNotEmpty &&
      has_selected_gender &&
      gender != null &&
      gender!.isNotEmpty &&
      has_selected_activities &&
      activities.isNotEmpty;
}

class MealPreferencesNotifier extends Notifier<MealPreferencesState> {
  static const _diet_key = 'diet_type';
  static const _diet_selected_key = 'diet_has_selected';
  static const _goals_key = 'meal_goals';
  static const _goals_selected_key = 'meal_goals_has_selected';
  static const _gender_key = 'meal_gender';
  static const _gender_selected_key = 'meal_gender_has_selected';
  static const _activities_key = 'meal_activities';
  static const _activities_selected_key = 'meal_activities_has_selected';
  bool _loaded = false;

  @override
  MealPreferencesState build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return const MealPreferencesState();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final diet = prefs.getString(_diet_key);
    final has_diet = prefs.getBool(_diet_selected_key) ?? false;
    final goals = prefs.getStringList(_goals_key) ?? [];
    final has_goals = prefs.getBool(_goals_selected_key) ?? false;
    final gender = prefs.getString(_gender_key);
    final has_gender = prefs.getBool(_gender_selected_key) ?? false;
    final activities = prefs.getStringList(_activities_key) ?? [];
    final has_activities = prefs.getBool(_activities_selected_key) ?? false;

    state = MealPreferencesState(
      diet_type: diet,
      meal_goals: goals.toSet(),
      gender: gender,
      activities: activities.toSet(),
      has_selected_diet: has_diet && diet != null,
      has_selected_goals: has_goals && goals.isNotEmpty,
      has_selected_gender: has_gender && gender != null && gender.isNotEmpty,
      has_selected_activities: has_activities && activities.isNotEmpty,
      is_ready: true,
    );
  }

  MealPreferencesState _copy({
    String? diet_type,
    Set<String>? meal_goals,
    String? gender,
    Set<String>? activities,
    bool? has_selected_diet,
    bool? has_selected_goals,
    bool? has_selected_gender,
    bool? has_selected_activities,
  }) {
    return MealPreferencesState(
      diet_type: diet_type ?? state.diet_type,
      meal_goals: meal_goals ?? state.meal_goals,
      gender: gender ?? state.gender,
      activities: activities ?? state.activities,
      has_selected_diet: has_selected_diet ?? state.has_selected_diet,
      has_selected_goals: has_selected_goals ?? state.has_selected_goals,
      has_selected_gender: has_selected_gender ?? state.has_selected_gender,
      has_selected_activities:
          has_selected_activities ?? state.has_selected_activities,
      is_ready: true,
    );
  }

  Map<String, dynamic> _profile_payload({
    String? diet_type,
    Set<String>? meal_goals,
    String? gender,
    Set<String>? activities,
  }) {
    final next_diet = diet_type ?? state.diet_type;
    final next_goals = meal_goals ?? state.meal_goals;
    final next_gender = gender ?? state.gender;
    final next_activities = activities ?? state.activities;
    return {
      if (next_diet != null) 'diet_type': next_diet,
      if (next_goals.isNotEmpty) 'meal_goals': next_goals.toList(),
      if (next_gender != null && next_gender.isNotEmpty) 'gender': next_gender,
      if (next_activities.isNotEmpty) 'activities': next_activities.toList(),
    };
  }

  Future<void> setDietType(String diet_type) async {
    state = _copy(diet_type: diet_type, has_selected_diet: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_diet_key, diet_type);
    await prefs.setBool(_diet_selected_key, true);
    await ApiService.saveUserProfile(_profile_payload(diet_type: diet_type));
  }

  Future<void> setMealGoals(Set<String> meal_goals) async {
    state = _copy(
      meal_goals: meal_goals,
      has_selected_goals: meal_goals.isNotEmpty,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_goals_key, meal_goals.toList());
    await prefs.setBool(_goals_selected_key, meal_goals.isNotEmpty);
    await ApiService.saveUserProfile(_profile_payload(meal_goals: meal_goals));
  }

  Future<void> applyFromCloud({
    required String diet_type,
    required Set<String> meal_goals,
    String? gender,
    Set<String>? activities,
  }) async {
    final next_activities = activities ?? const <String>{};
    final has_gender = gender != null && gender.isNotEmpty;
    final has_activities = next_activities.isNotEmpty;
    state = MealPreferencesState(
      diet_type: diet_type,
      meal_goals: meal_goals,
      gender: gender,
      activities: next_activities,
      has_selected_diet: true,
      has_selected_goals: meal_goals.isNotEmpty,
      has_selected_gender: has_gender,
      has_selected_activities: has_activities,
      is_ready: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_diet_key, diet_type);
    await prefs.setBool(_diet_selected_key, true);
    await prefs.setStringList(_goals_key, meal_goals.toList());
    await prefs.setBool(_goals_selected_key, meal_goals.isNotEmpty);
    if (has_gender) {
      await prefs.setString(_gender_key, gender!);
      await prefs.setBool(_gender_selected_key, true);
    }
    if (has_activities) {
      await prefs.setStringList(_activities_key, next_activities.toList());
      await prefs.setBool(_activities_selected_key, true);
    }
  }

  Future<void> saveAll({
    required String diet_type,
    required Set<String> meal_goals,
    required String gender,
    required Set<String> activities,
  }) async {
    await applyFromCloud(
      diet_type: diet_type,
      meal_goals: meal_goals,
      gender: gender,
      activities: activities,
    );
    await ApiService.saveUserProfile({
      'diet_type': diet_type,
      'meal_goals': meal_goals.toList(),
      'gender': gender,
      'activities': activities.toList(),
    });
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_diet_key);
    await prefs.remove(_diet_selected_key);
    await prefs.remove(_goals_key);
    await prefs.remove(_goals_selected_key);
    await prefs.remove(_gender_key);
    await prefs.remove(_gender_selected_key);
    await prefs.remove(_activities_key);
    await prefs.remove(_activities_selected_key);
    state = const MealPreferencesState(is_ready: true);
  }
}

final mealPreferencesProvider =
    NotifierProvider<MealPreferencesNotifier, MealPreferencesState>(
  MealPreferencesNotifier.new,
);
