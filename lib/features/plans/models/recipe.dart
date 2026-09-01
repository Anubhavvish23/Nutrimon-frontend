import 'package:flutter/material.dart';

class RecipeTag {
  final String label;
  final Color color;

  const RecipeTag({required this.label, required this.color});
}

class Recipe {
  final String? id;
  final String? slug;
  final String emoji;
  final String name;
  final String time;
  final String calories;
  final String protein;
  final Color accent_color;
  final Color background_color;
  final List<RecipeTag> tags;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String diet_type;
  final List<String> meal_goals;

  const Recipe({
    this.id,
    this.slug,
    required this.emoji,
    required this.name,
    required this.time,
    required this.calories,
    required this.protein,
    required this.accent_color,
    required this.background_color,
    required this.tags,
    required this.description,
    required this.ingredients,
    required this.steps,
    this.diet_type = 'veg',
    this.meal_goals = const ['stay_healthy'],
  });

  factory Recipe.fromApiJson(Map<String, dynamic> json) {
    final tags_raw = json['tags'] as List? ?? [];
    final tags = tags_raw
        .whereType<Map>()
        .map(
          (tag) => RecipeTag(
            label: tag['label']?.toString() ?? '',
            color: colorFromHex(tag['color_hex']?.toString() ?? '#1DB954'),
          ),
        )
        .toList();

    final is_veg = json['is_veg'] == true;
    final meal_goals_raw = json['meal_goal_ids'];
    final meal_goals = meal_goals_raw is List
        ? meal_goals_raw.map((e) => e.toString()).toList()
        : <String>[];

    return Recipe(
      id: json['id']?.toString(),
      slug: json['slug']?.toString(),
      emoji: json['emoji']?.toString() ?? '🍽️',
      name: json['name']?.toString() ?? '',
      time: json['prep_time_label']?.toString() ?? '',
      calories: json['calories_label']?.toString() ?? '',
      protein: json['protein_label']?.toString() ?? '',
      accent_color: colorFromHex(json['accent_hex']?.toString() ?? '#1DB954'),
      background_color:
          colorFromHex(json['background_hex']?.toString() ?? '#0D2A1A'),
      tags: tags,
      description: json['description']?.toString() ?? '',
      ingredients: (json['ingredients'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      steps:
          (json['steps'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      diet_type: is_veg ? 'veg' : 'non_veg',
      meal_goals:
          meal_goals.isNotEmpty ? meal_goals : const ['stay_healthy'],
    );
  }

  static Color colorFromHex(String hex) {
    var value = hex.replaceFirst('#', '').trim();
    if (value.length == 6) {
      value = 'FF$value';
    }
    return Color(int.parse(value, radix: 16));
  }

  bool get is_veg => diet_type == 'veg';

  bool matchesGoals(Set<String> selected_goals) {
    if (selected_goals.isEmpty) return true;
    return meal_goals.any(selected_goals.contains);
  }
}
