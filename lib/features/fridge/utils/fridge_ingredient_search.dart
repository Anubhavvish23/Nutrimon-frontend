import '../../recipes/utils/recipe_health_filter.dart';
import '../data/fridge_ingredients.dart';

bool ingredient_is_allergen(FridgeIngredient item, List<String> allergies) {
  if (allergies.isEmpty) return false;
  final blob = [item.label, item.id.replaceAll('_', ' '), ...item.keywords]
      .join(' ');
  return text_conflicts_with_allergies(blob, allergies);
}

List<FridgeIngredient> allergy_safe_ingredients(List<String> allergies) {
  if (allergies.isEmpty) {
    return List<FridgeIngredient>.from(fridgeIngredientOptions);
  }
  return fridgeIngredientOptions
      .where((item) => !ingredient_is_allergen(item, allergies))
      .toList();
}

List<FridgeIngredient> search_fridge_ingredients(
  String query, {
  List<String> allergies = const [],
}) {
  final options = allergy_safe_ingredients(allergies);
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return options;
  }

  return options.where((item) {
    if (item.label.toLowerCase().contains(trimmed)) return true;
    if (item.id.replaceAll('_', ' ').contains(trimmed)) return true;
    for (final keyword in item.keywords) {
      if (keyword.contains(trimmed) || trimmed.contains(keyword)) {
        return true;
      }
    }
    return false;
  }).toList();
}
