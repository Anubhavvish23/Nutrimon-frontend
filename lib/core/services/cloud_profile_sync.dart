import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../storage/user_storage.dart';
import '../../features/health/providers/bmi_profile_provider.dart';
import '../../features/health/providers/health_profile_provider.dart';
import '../../features/health/providers/custom_symptom_history_provider.dart';
import '../../features/health/providers/selected_symptoms_provider.dart';
import '../../features/health/providers/symptom_analysis_provider.dart';
import '../../features/health/providers/symptom_timeline_provider.dart';
import '../../features/goals/providers/micro_goals_provider.dart';
import '../../features/grocery/providers/grocery_checked_provider.dart';
import '../../features/plans/providers/meal_preferences_provider.dart';
import '../../features/plans/providers/saved_meal_plan_provider.dart';
import '../../features/recipes/providers/favorites_provider.dart';
import '../../features/plans/providers/recipe_ratings_provider.dart';
import '../../features/streak/providers/streak_provider.dart';
import '../../features/auth/providers/terms_acceptance_provider.dart';

Future<void> loadCloudUserProfile(
  T Function<T>(ProviderListenable<T> provider) read,
) async {
  final result = await ApiService.fetchUserProfile();
  if (result['success'] != true) return;

  final data = result['data'] as Map<String, dynamic>?;
  final profile = data?['profile'];
  if (profile is! Map<String, dynamic>) return;

  final profile_name = profile['name']?.toString().trim() ?? '';
  if (profile_name.isNotEmpty) {
    final profile_email = profile['email']?.toString().trim() ?? '';
    final stored_email = await UserStorage.getEmail();
    await UserStorage.saveUser(
      name: profile_name,
      email: profile_email.isNotEmpty
          ? profile_email
          : (stored_email ?? ''),
    );
  }

  final has_bmi = profile['has_bmi'] == true;
  if (has_bmi) {
    read(bmiProfileProvider.notifier).applyCloudProfile(
          gender: profile['gender']?.toString(),
          age: _asInt(profile['age'], 25),
          height_cm: _asDouble(profile['height_cm'], 170),
          weight_kg: _asDouble(profile['weight_kg'], 70),
        );
  }

  final sleep = profile['sleep_hours'];
  final allergies = _asStringList(profile['allergies']);
  final conditions = _asStringList(profile['conditions']);
  await read(healthProfileProvider.notifier).applyCloudProfile(
        sleep_hours: sleep == null ? null : _asDouble(sleep, 7),
        allergies: allergies,
        conditions: conditions,
      );

  final symptom_slugs = _asStringList(profile['symptom_slugs']);
  read(selectedSymptomsProvider.notifier).replaceAll(symptom_slugs.toSet());

  final diet = profile['diet_type']?.toString();
  final goals = _asStringList(profile['meal_goals']).toSet();
  final gender = profile['gender']?.toString();
  final activities = _asStringList(profile['activities']).toSet();
  if (diet != null && diet.isNotEmpty) {
    await read(mealPreferencesProvider.notifier).applyFromCloud(
          diet_type: diet,
          meal_goals: goals.isEmpty ? {'stay_healthy'} : goals,
          gender: gender,
          activities: activities,
        );
  }

  await read(streakProvider.notifier).applyFromCloud(
        current_streak: _asInt(profile['streak_current'], 0),
        longest_streak: _asInt(profile['streak_longest'], 0),
        last_meal_date: profile['streak_last_meal_date']?.toString(),
      );

  read(favoritesProvider.notifier).applyFromCloud(
        _asStringList(profile['favorite_recipe_slugs']).toSet(),
      );

  final last_plan = profile['last_meal_plan'];
  if (last_plan is Map<String, dynamic>) {
    read(savedMealPlanProvider.notifier).applyFromCloud(last_plan);
  } else if (last_plan is Map) {
    read(savedMealPlanProvider.notifier).applyFromCloud(
          Map<String, dynamic>.from(last_plan),
        );
  }

  final last_analysis = profile['last_symptom_analysis'];
  if (last_analysis is Map<String, dynamic>) {
    read(symptomAnalysisProvider.notifier).state =
        SymptomAnalysisResult.fromApi(last_analysis);
  } else if (last_analysis is Map) {
    read(symptomAnalysisProvider.notifier).state =
        SymptomAnalysisResult.fromApi(Map<String, dynamic>.from(last_analysis));
  }

  final timeline = profile['symptom_timeline'];
  if (timeline is List) {
    await read(symptomTimelineProvider.notifier).applyFromCloud(timeline);
  }

  final micro_goals = profile['micro_goals'];
  if (micro_goals is Map<String, dynamic>) {
    await read(microGoalsProvider.notifier).applyFromCloud(micro_goals);
  } else if (micro_goals is Map) {
    await read(microGoalsProvider.notifier).applyFromCloud(
          Map<String, dynamic>.from(micro_goals),
        );
  }

  final recipe_ratings = profile['recipe_ratings'];
  if (recipe_ratings is Map<String, dynamic>) {
    read(recipeRatingsProvider.notifier).applyFromCloud(
      recipe_ratings,
      sync_cloud: false,
    );
  } else if (recipe_ratings is Map) {
    read(recipeRatingsProvider.notifier).applyFromCloud(
      Map<String, dynamic>.from(recipe_ratings),
      sync_cloud: false,
    );
  }

  final grocery_checked = _asStringList(profile['grocery_checked']);
  await read(groceryCheckedProvider.notifier).applyFromCloud(grocery_checked);

  final custom_history = profile['custom_symptom_history'];
  if (custom_history is List) {
    await read(customSymptomHistoryProvider.notifier).applyFromCloud(
      custom_history,
    );
  }

  await read(termsAcceptedProvider.notifier).applyFromCloud(
        terms_accepted_at: profile['terms_accepted_at']?.toString(),
        terms_version: profile['terms_version']?.toString(),
      );
}

int _asInt(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, double fallback) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
}
