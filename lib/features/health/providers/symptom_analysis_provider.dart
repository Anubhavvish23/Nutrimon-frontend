import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealSuggestionItem {
  final String slug;
  final String name;
  final String emoji;
  final String action_text;
  final String calories;
  final String protein;

  const MealSuggestionItem({
    required this.slug,
    required this.name,
    required this.emoji,
    required this.action_text,
    this.calories = '',
    this.protein = '',
  });

  factory MealSuggestionItem.fromJson(Map<String, dynamic> json) {
    return MealSuggestionItem(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🍽️',
      action_text: json['action_text']?.toString() ?? '',
      calories: json['calories']?.toString() ?? '',
      protein: json['protein']?.toString() ?? '',
    );
  }
}

class SymptomAnalysisResult {
  final String analysis;
  final List<String> possible_deficiencies;
  final List<String> food_tips;
  final List<MealSuggestionItem> meal_suggestions;
  final String source;
  final String disclaimer;
  final List<String> analyzed_slugs;
  final String custom_text;

  const SymptomAnalysisResult({
    required this.analysis,
    this.possible_deficiencies = const [],
    this.food_tips = const [],
    this.meal_suggestions = const [],
    this.source = '',
    this.disclaimer = '',
    this.analyzed_slugs = const [],
    this.custom_text = '',
  });

  factory SymptomAnalysisResult.fromApi(
    Map<String, dynamic> data, {
    List<String> analyzed_slugs = const [],
    String custom_text = '',
  }) {
    final meals_raw = data['meal_suggestions'];
    final meals = <MealSuggestionItem>[];
    if (meals_raw is List) {
      for (final item in meals_raw) {
        if (item is Map<String, dynamic>) {
          meals.add(MealSuggestionItem.fromJson(item));
        } else if (item is Map) {
          meals.add(MealSuggestionItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return SymptomAnalysisResult(
      analysis: data['analysis']?.toString() ?? '',
      possible_deficiencies: _asStringList(data['possible_deficiencies']),
      food_tips: _asStringList(data['food_tips']),
      meal_suggestions: meals,
      source: data['source']?.toString() ?? '',
      disclaimer: data['disclaimer']?.toString() ?? '',
      analyzed_slugs: analyzed_slugs.isNotEmpty
          ? analyzed_slugs
          : _asStringList(data['analyzed_slugs']),
      custom_text: custom_text.isNotEmpty
          ? custom_text
          : (data['custom_text']?.toString() ?? ''),
    );
  }
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
}

final symptomAnalysisProvider =
    StateProvider<SymptomAnalysisResult?>((ref) => null);

final mealPlanNeedsRefreshProvider = StateProvider<int>((ref) => 0);
