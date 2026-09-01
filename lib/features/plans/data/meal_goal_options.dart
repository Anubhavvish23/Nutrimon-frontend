import 'package:flutter/material.dart';

class MealGoalOption {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;

  const MealGoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}

const List<MealGoalOption> mealGoalOptions = [
  MealGoalOption(
    id: 'gain_weight',
    title: 'Gain weight',
    subtitle: 'Higher-calorie morning meals',
    emoji: '📈',
    color: Color(0xFFFF9500),
  ),
  MealGoalOption(
    id: 'build_muscle',
    title: 'Build muscle',
    subtitle: 'Protein-packed breakfasts',
    emoji: '💪',
    color: Color(0xFFFF375F),
  ),
  MealGoalOption(
    id: 'stay_healthy',
    title: 'Stay healthy',
    subtitle: 'Balanced everyday nutrition',
    emoji: '🌿',
    color: Color(0xFF1DB954),
  ),
  MealGoalOption(
    id: 'detox',
    title: 'Detox body',
    subtitle: 'Light, cleansing recipes',
    emoji: '🍃',
    color: Color(0xFF0A84FF),
  ),
];

String mealGoalsSummary(Set<String> meal_goals) {
  if (meal_goals.isEmpty) return 'Set your goals';
  final labels = mealGoalOptions
      .where((option) => meal_goals.contains(option.id))
      .map((option) => option.title)
      .toList();
  if (labels.length <= 2) return labels.join(' · ');
  return '${labels.take(2).join(' · ')} +${labels.length - 2}';
}
