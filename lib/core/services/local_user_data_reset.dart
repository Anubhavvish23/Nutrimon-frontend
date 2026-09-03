import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/goals/providers/micro_goals_provider.dart';
import '../../features/grocery/providers/grocery_checked_provider.dart';
import '../../features/health/providers/bmi_profile_provider.dart';
import '../../features/health/providers/health_profile_provider.dart';
import '../../features/health/providers/selected_symptoms_provider.dart';
import '../../features/health/providers/symptom_analysis_provider.dart';
import '../../features/health/providers/symptom_timeline_provider.dart';
import '../../features/plans/providers/meal_preferences_provider.dart';
import '../../features/plans/providers/recipe_ratings_provider.dart';
import '../../features/plans/providers/saved_meal_plan_provider.dart';
import '../../features/recipes/providers/favorites_provider.dart';
import '../../features/streak/providers/streak_provider.dart';
import 'cloud_profile_bootstrap.dart';

Future<void> clearLocalUserData(WidgetRef ref) async {
  ref.read(cloudProfileLoadedProvider.notifier).state = false;
  ref.read(symptomAnalysisProvider.notifier).state = null;
  ref.read(selectedSymptomsProvider.notifier).clear();
  ref.read(bmiProfileProvider.notifier).reset();
  ref.read(savedMealPlanProvider.notifier).clearLocal();

  await Future.wait([
    ref.read(healthProfileProvider.notifier).clearLocal(),
    ref.read(mealPreferencesProvider.notifier).clearLocal(),
    ref.read(streakProvider.notifier).clearLocal(),
    ref.read(favoritesProvider.notifier).clearLocal(),
    ref.read(symptomTimelineProvider.notifier).clearLocal(),
    ref.read(microGoalsProvider.notifier).clearLocal(),
    ref.read(recipeRatingsProvider.notifier).clearLocal(),
    ref.read(groceryCheckedProvider.notifier).clearLocal(),
  ]);
}
