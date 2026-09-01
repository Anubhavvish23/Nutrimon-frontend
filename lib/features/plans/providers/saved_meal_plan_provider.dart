import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/recipe.dart';

class SavedMealPlan {
  final List<Recipe> recipes;
  final String? tip;
  final List<String> activities;
  final Map<String, String> reasons;

  const SavedMealPlan({
    this.recipes = const [],
    this.tip,
    this.activities = const [],
    this.reasons = const {},
  });

  bool get has_recipes => recipes.isNotEmpty;
}

class SavedMealPlanNotifier extends Notifier<SavedMealPlan> {
  @override
  SavedMealPlan build() => const SavedMealPlan();

  void applyFromCloud(Map<String, dynamic> data) {
    final recipes_raw = data['recipes'];
    final recipes = <Recipe>[];
    if (recipes_raw is List) {
      for (final item in recipes_raw) {
        if (item is Map<String, dynamic>) {
          recipes.add(Recipe.fromApiJson(item));
        } else if (item is Map) {
          recipes.add(Recipe.fromApiJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final reasons_raw = data['reasons'];
    final reasons = <String, String>{};
    if (reasons_raw is Map) {
      reasons_raw.forEach((key, value) {
        reasons[key.toString()] = value.toString();
      });
    }

    final activities_raw = data['activities'];
    final activities = <String>[];
    if (activities_raw is List) {
      for (final item in activities_raw) {
        final text = item.toString().trim();
        if (text.isNotEmpty) activities.add(text);
      }
    }

    state = SavedMealPlan(
      recipes: recipes,
      tip: data['tip']?.toString(),
      activities: activities,
      reasons: reasons,
    );
  }

  Future<void> savePlan({
    required List<Recipe> recipes,
    String? tip,
    List<String> activities = const [],
    Map<String, String> reasons = const {},
  }) async {
    state = SavedMealPlan(
      recipes: recipes,
      tip: tip,
      activities: activities,
      reasons: reasons,
    );

    await ApiService.saveUserProfile({
      'last_meal_plan': {
        'tip': tip,
        'activities': activities,
        'reasons': reasons,
        'recipes': recipes
            .map(
              (recipe) => {
                'id': recipe.id,
                'slug': recipe.slug,
                'emoji': recipe.emoji,
                'name': recipe.name,
                'prep_time_label': recipe.time,
                'calories_label': recipe.calories,
                'protein_label': recipe.protein,
                'accent_hex':
                    '#${recipe.accent_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                'background_hex':
                    '#${recipe.background_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                'description': recipe.description,
                'ingredients': recipe.ingredients,
                'steps': recipe.steps,
                'is_veg': recipe.diet_type == 'veg',
                'meal_goal_ids': recipe.meal_goals,
                'tags': recipe.tags
                    .map(
                      (tag) => {
                        'label': tag.label,
                        'color_hex':
                            '#${tag.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      },
    });
  }

  void clearLocal() {
    state = const SavedMealPlan();
  }
}

final savedMealPlanProvider =
    NotifierProvider<SavedMealPlanNotifier, SavedMealPlan>(
  SavedMealPlanNotifier.new,
);
