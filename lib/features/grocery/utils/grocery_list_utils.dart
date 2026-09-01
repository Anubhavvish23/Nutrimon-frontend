import '../../plans/models/recipe.dart';

const pantry_staples = <String>{
  'salt',
  'pepper',
  'black pepper',
  'water',
  'ice',
  'oil',
  'ghee',
  'turmeric',
  'cumin',
  'mustard seeds',
  'curry leaves',
  'asafoetida',
  'baking powder',
  'sugar',
  'chaat masala',
};

class GroceryItem {
  final String label;
  final List<String> recipe_names;
  bool checked;

  GroceryItem({
    required this.label,
    required this.recipe_names,
    this.checked = false,
  });
}

String _normalize_ingredient(String line) {
  return line.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').trim();
}

bool _is_pantry_staple(String line) {
  final normalized = _normalize_ingredient(line);
  for (final staple in pantry_staples) {
    if (normalized == staple || normalized.endsWith(' $staple')) {
      return true;
    }
  }
  return false;
}

String grocery_item_key(String line) {
  return _normalize_ingredient(line).replaceAll(RegExp(r'\s+'), ' ');
}

List<GroceryItem> build_grocery_list(List<Recipe> recipes) {
  final grouped = <String, GroceryItem>{};

  for (final recipe in recipes) {
    for (final line in recipe.ingredients) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || _is_pantry_staple(trimmed)) continue;

      final key = grocery_item_key(trimmed);
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = GroceryItem(
          label: trimmed,
          recipe_names: [recipe.name],
        );
      } else if (!existing.recipe_names.contains(recipe.name)) {
        existing.recipe_names.add(recipe.name);
      }
    }
  }

  final items = grouped.values.toList()
    ..sort((a, b) => a.label.compareTo(b.label));
  return items;
}

String grocery_list_text(List<GroceryItem> items) {
  final lines = <String>['NutriMorning Grocery List', ''];
  for (final item in items) {
    final prefix = item.checked ? '[x]' : '[ ]';
    lines.add('$prefix ${item.label}');
  }
  return lines.join('\n');
}
