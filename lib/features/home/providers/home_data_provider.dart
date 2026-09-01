import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/bmi_profile_provider.dart';
import '../../plans/providers/saved_meal_plan_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../models/home_data.dart';

String homeGreetingForHour(int hour) {
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String homeSubtitleForHour(int hour) {
  if (hour < 11) return "Let's start with a healthy breakfast";
  if (hour < 16) return 'Time for a balanced midday meal';
  if (hour < 21) return 'Evening meals matter too — eat well';
  return "Rest well and plan tomorrow's meal";
}

String homePlanLabelForHour(int hour) {
  if (hour < 11) return 'Your breakfast';
  if (hour < 16) return 'Your lunch';
  if (hour < 21) return 'Your dinner';
  return 'Tomorrow\'s plan';
}

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final streak = ref.watch(streakProvider);
  final hour = DateTime.now().hour;

  return HomeData(
    greeting: homeGreetingForHour(hour),
    streak_days: streak.current_streak,
  );
});

final plansDataProvider = FutureProvider<PlansData>((ref) async {
  final bmi = ref.watch(bmiProfileProvider);
  final saved = ref.watch(savedMealPlanProvider);
  return PlansData(
    bmi: bmi.display_bmi,
    meal_count: saved.recipes.isNotEmpty ? saved.recipes.length : 4,
  );
});
