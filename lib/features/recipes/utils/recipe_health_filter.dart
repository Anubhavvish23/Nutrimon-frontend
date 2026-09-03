import '../../plans/models/recipe.dart';

const Map<String, List<String>> _allergy_keywords = {
  'nuts': [
    'nut',
    'almond',
    'walnut',
    'peanut',
    'cashew',
    'pistachio',
    'pecan',
    'hazelnut',
  ],
  'dairy': [
    'milk',
    'yogurt',
    'yoghurt',
    'cheese',
    'butter',
    'cream',
    'whey',
    'ghee',
    'paneer',
    'dairy',
    'curd',
    'dahi',
    'lassi',
    'buttermilk',
    'chaas',
    'cottage',
  ],
  'gluten': [
    'wheat',
    'bread',
    'flour',
    'gluten',
    'barley',
    'rye',
    'oats',
    'oat',
    'toast',
    'sourdough',
    'semolina',
    'rava',
    'maida',
    'atta',
    'thepla',
    'dalia',
    'upma',
  ],
  'eggs': ['egg', 'eggs', 'bhurji'],
  'soy': ['soy', 'soya', 'tofu', 'edamame', 'tempeh'],
  'shellfish': ['shrimp', 'prawn', 'crab', 'lobster', 'shellfish', 'mussel'],
  'fish': ['salmon', 'tuna', 'fish', 'sardine', 'anchovy'],
  'sesame': ['sesame', 'tahini', 'til'],
};

const Map<String, List<String>> _condition_blocked = {
  'diabetes': ['honey', 'sugar', 'syrup', 'jaggery', 'sweetened', 'chocolate'],
  'hypertension': ['bacon', 'sausage', 'processed meat', 'pickle', 'papad'],
  'heart disease': ['bacon', 'sausage', 'processed meat', 'fried', 'deep-fried'],
  'kidney disease': ['bacon', 'sausage', 'processed meat', 'pickle'],
  'pcos': ['syrup', 'sweetened', 'chocolate', 'pastry'],
  'thyroid': ['soy', 'soya', 'tofu', 'edamame'],
  'asthma': ['fried', 'deep-fried', 'processed meat'],
};

bool _is_letter(String ch) {
  if (ch.isEmpty) return false;
  final code = ch.codeUnitAt(0);
  return (code >= 97 && code <= 122) || (code >= 48 && code <= 57);
}

bool _contains_word(String blob, String word) {
  if (word.isEmpty) return false;
  var idx = 0;
  while (idx < blob.length) {
    final pos = blob.indexOf(word, idx);
    if (pos < 0) return false;
    final before_ok = pos == 0 || !_is_letter(blob.substring(pos - 1, pos));
    final end = pos + word.length;
    final after_ok = end >= blob.length || !_is_letter(blob.substring(end, end + 1));
    if (before_ok && after_ok) return true;
    idx = pos + 1;
  }
  return false;
}

String _recipe_blob(Recipe recipe) {
  return [
    recipe.name,
    recipe.description,
    recipe.ingredients.join(' '),
    recipe.steps.join(' '),
  ].join(' ').toLowerCase();
}

bool text_conflicts_with_allergies(String text, List<String> allergies) {
  if (allergies.isEmpty) return false;
  final blob = text.toLowerCase();
  for (final allergy in allergies) {
    final key = allergy.trim().toLowerCase();
    if (key.isEmpty) continue;
    if (_contains_word(blob, key)) return true;
    for (final keyword in _allergy_keywords[key] ?? const []) {
      if (_contains_word(blob, keyword)) return true;
    }
  }
  return false;
}

bool recipe_conflicts_with_allergies(
  Recipe recipe,
  List<String> allergies,
) {
  return text_conflicts_with_allergies(_recipe_blob(recipe), allergies);
}

bool recipe_conflicts_with_conditions(
  Recipe recipe,
  List<String> conditions,
) {
  if (conditions.isEmpty) return false;
  final blob = _recipe_blob(recipe);
  for (final condition in conditions) {
    final key = condition.trim().toLowerCase();
    if (key.isEmpty || key == 'none') continue;
    for (final term in _condition_blocked[key] ?? const []) {
      if (_contains_word(blob, term)) return true;
    }
  }
  return false;
}

bool recipe_matches_health_profile(
  Recipe recipe, {
  List<String> allergies = const [],
  List<String> conditions = const [],
}) {
  if (recipe_conflicts_with_allergies(recipe, allergies)) return false;
  if (recipe_conflicts_with_conditions(recipe, conditions)) return false;
  return true;
}

List<Recipe> filter_recipes_for_health(
  List<Recipe> recipes, {
  List<String> allergies = const [],
  List<String> conditions = const [],
}) {
  return recipes
      .where(
        (recipe) => recipe_matches_health_profile(
          recipe,
          allergies: allergies,
          conditions: conditions,
        ),
      )
      .toList();
}
