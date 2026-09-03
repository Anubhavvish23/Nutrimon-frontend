import 'package:flutter_test/flutter_test.dart';
import 'package:nutrimorning_app/features/fridge/utils/fridge_match.dart';
import 'package:nutrimorning_app/features/recipes/data/recipe_catalog.dart';

void main() {
  final catalog = recipeCatalogByName.values.toList();

  test('banana and milk prefers banana peanut shake', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'banana', 'milk'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, 'Banana Peanut Shake');
  });

  test('banana and milk does not return berry smoothie', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'banana', 'milk'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, isNot('Berry Smoothie'));
  });

  test('eggs and butter prefers scrambled eggs', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'eggs', 'butter'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, 'Scrambled Eggs');
  });

  test('berries and yogurt prefers greek yogurt bowl', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'berries', 'yogurt'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, 'Greek Yogurt Bowl');
  });

  test('oats and milk prefers oatmeal bowl', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'oats', 'milk'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, 'Oatmeal Bowl');
  });

  test('paneer and bread prefers paneer bhurji', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'paneer', 'bread'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, 'Paneer Bhurji on Grilled Bread');
  });

  test('poha and peanut butter returns vegetable poha', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'poha', 'peanut_butter'},
    );
    expect(result, isNotNull);
    expect(result!.recipe.name, 'Vegetable Poha');
  });

  test('banana egg cheese does not mix all three', () {
    final result = spinFridgeRoulette(
      recipes: catalog,
      selected_ids: {'banana', 'eggs', 'cheese'},
    );
    expect(result, isNotNull);
    expect(result!.matched_labels, isNot(contains('Banana')));
    expect(
      result!.recipe.name.toLowerCase(),
      isNot(contains('banana')),
    );
  });
}
