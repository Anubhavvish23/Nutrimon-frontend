import '../data/fridge_ingredients.dart';

List<FridgeIngredient> search_fridge_ingredients(String query) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return List<FridgeIngredient>.from(fridgeIngredientOptions);
  }

  return fridgeIngredientOptions.where((item) {
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
