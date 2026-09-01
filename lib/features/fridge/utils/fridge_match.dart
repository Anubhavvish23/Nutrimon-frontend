import 'dart:math';

import '../../plans/models/recipe.dart';
import '../data/fridge_ingredients.dart';

class FridgeMatchResult {
  final Recipe recipe;
  final int match_count;
  final int score;
  final List<String> matched_labels;
  final String? reason;
  final String? source;

  const FridgeMatchResult({
    required this.recipe,
    required this.match_count,
    required this.score,
    required this.matched_labels,
    this.reason,
    this.source,
  });

  factory FridgeMatchResult.fromApi(Map<String, dynamic> data) {
    final recipe_raw = data['recipe'];
    final recipe = recipe_raw is Map<String, dynamic>
        ? Recipe.fromApiJson(recipe_raw)
        : Recipe.fromApiJson(Map<String, dynamic>.from(recipe_raw as Map));

    final matched_raw = data['matched_ingredients'];
    final matched_labels = <String>[];
    if (matched_raw is List) {
      for (final item in matched_raw) {
        final label = item.toString().trim();
        if (label.isNotEmpty) matched_labels.add(label);
      }
    }

    return FridgeMatchResult(
      recipe: recipe,
      match_count: matched_labels.length,
      score: 0,
      matched_labels: matched_labels,
      reason: data['reason']?.toString(),
      source: data['source']?.toString(),
    );
  }
}

String _normalize(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').trim();
}

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
    final after_ok =
        end >= blob.length || !_is_letter(blob.substring(end, end + 1));
    if (before_ok && after_ok) return true;
    idx = pos + 1;
  }
  return false;
}

bool _line_has_any(String line, List<String> terms) {
  final haystack = _normalize(line);
  for (final term in terms) {
    if (_contains_word(haystack, term)) return true;
  }
  return false;
}

int _pick_strength_in_line(String line, FridgeIngredient pick) {
  final haystack = _normalize(line);

  switch (pick.id) {
    case 'eggs':
      if (_line_has_any(line, ['egg whites', 'eggs']) ||
          (_contains_word(haystack, 'egg') &&
              !haystack.contains('eggplant'))) {
        return 100;
      }
      return 0;
    case 'avocado':
      return _contains_word(haystack, 'avocado') ? 100 : 0;
    case 'bread':
      if (_line_has_any(line, ['bread', 'toast', 'sourdough', 'thepla'])) {
        return 100;
      }
      return 0;
    case 'yogurt':
      if (_line_has_any(line, ['yogurt', 'yoghurt', 'curd', 'dahi'])) {
        return 100;
      }
      return 0;
    case 'banana':
      return _contains_word(haystack, 'banana') ? 100 : 0;
    case 'berries':
      if (_line_has_any(
        line,
        ['berries', 'berry', 'strawberry', 'blueberry', 'mixed berries'],
      )) {
        return 100;
      }
      return 0;
    case 'oats':
      if (_line_has_any(line, ['oats', 'oatmeal', 'rolled oats', 'cooked oats'])) {
        return 100;
      }
      return 0;
    case 'milk':
      if (_line_has_any(line, ['almond milk', 'oat milk', 'soy milk'])) {
        return 55;
      }
      if (_contains_word(haystack, 'milk') &&
          !_line_has_any(line, ['buttermilk', 'coconut milk'])) {
        return 100;
      }
      return 0;
    case 'spinach':
      return _contains_word(haystack, 'spinach') ? 100 : 0;
    case 'tomato':
      return _contains_word(haystack, 'tomato') ? 100 : 0;
    case 'cheese':
      if (_line_has_any(line, ['cheese', 'feta', 'parmesan', 'paneer'])) {
        return 100;
      }
      return 0;
    case 'peanut_butter':
      if (haystack.contains('peanut butter') || haystack.contains('peanut')) {
        return 100;
      }
      return 0;
    case 'honey':
      return _contains_word(haystack, 'honey') ? 100 : 0;
    case 'chia':
      return _contains_word(haystack, 'chia') ? 100 : 0;
    case 'apple':
      return _contains_word(haystack, 'apple') ? 100 : 0;
    case 'almond':
      if (_line_has_any(line, ['almonds', 'chopped almonds', 'almond ']) &&
          !haystack.contains('almond milk')) {
        return 100;
      }
      return 0;
    case 'butter':
      if (haystack.contains('peanut butter')) return 0;
      return _contains_word(haystack, 'butter') ? 100 : 0;
    case 'lemon':
      return _contains_word(haystack, 'lemon') ? 100 : 0;
    case 'chicken':
      return _contains_word(haystack, 'chicken') ? 100 : 0;
    case 'salmon':
      if (_line_has_any(line, ['salmon', 'fish'])) return 100;
      return 0;
    case 'paneer':
      return _contains_word(haystack, 'paneer') ? 100 : 0;
    case 'poha':
      return _contains_word(haystack, 'poha') ? 100 : 0;
    case 'besan':
      return _contains_word(haystack, 'besan') ? 100 : 0;
    case 'moong':
      if (_line_has_any(line, ['moong', 'sprouted moong', 'moong dal'])) {
        return 100;
      }
      return 0;
    default:
      for (final keyword in pick.keywords) {
        if (_contains_word(haystack, keyword.toLowerCase())) return 100;
      }
      return 0;
  }
}

Map<String, int> _recipe_fridge_profile(Recipe recipe) {
  final profile = <String, int>{};
  final lines = <String>[
    recipe.name,
    recipe.description,
    ...recipe.ingredients,
    ...recipe.steps,
  ];

  for (final option in fridgeIngredientOptions) {
    var best = 0;
    for (final line in lines) {
      best = max(best, _pick_strength_in_line(line, option));
    }
    if (best > 0) profile[option.id] = best;
  }
  return profile;
}

bool _name_mentions(Recipe recipe, FridgeIngredient pick) {
  final name = _normalize(recipe.name);
  switch (pick.id) {
    case 'banana':
      return _contains_word(name, 'banana');
    case 'berries':
      return _line_has_any(name, ['berry', 'berries']);
    case 'eggs':
      return _contains_word(name, 'egg');
    case 'oats':
      return _line_has_any(name, ['oat', 'oats']);
    case 'milk':
      return _contains_word(name, 'milk');
    case 'peanut_butter':
      return name.contains('peanut');
    case 'paneer':
      return _contains_word(name, 'paneer');
    case 'poha':
      return _contains_word(name, 'poha');
    case 'besan':
      return _contains_word(name, 'besan') || _contains_word(name, 'chilla');
    case 'moong':
      return _contains_word(name, 'moong');
    default:
      for (final keyword in pick.keywords) {
        if (_contains_word(name, keyword.toLowerCase())) return true;
      }
      return false;
  }
}

const _min_match_strength = 50;

int _score_recipe(
  Recipe recipe,
  List<FridgeIngredient> picks,
  Set<String> selected_ids,
  Map<String, int> profile,
) {
  var score = 0;

  for (final pick in picks) {
    final strength = profile[pick.id] ?? 0;
    score += strength;
    if (_name_mentions(recipe, pick)) score += 90;
    if (recipe.ingredients.take(3).any(
          (line) => _pick_strength_in_line(line, pick) >= _min_match_strength,
        )) {
      score += 35;
    }
  }

  final selected_in_name = picks.any((pick) => _name_mentions(recipe, pick));

  for (final option in fridgeIngredientOptions) {
    if (selected_ids.contains(option.id)) continue;
    final strength = profile[option.id] ?? 0;
    if (strength <= 0) continue;

    if (_name_mentions(recipe, option)) {
      score -= selected_in_name ? 35 : 150;
    } else if (strength >= 90) {
      score -= 70;
    } else if (strength >= _min_match_strength) {
      score -= 35;
    }
  }

  final extra_strong = profile.entries.where(
    (entry) =>
        !selected_ids.contains(entry.key) &&
        entry.value >= _min_match_strength,
  ).length;
  score -= extra_strong * 30;

  return score;
}

List<FridgeMatchResult> matchRecipesToFridge({
  required List<Recipe> recipes,
  required Set<String> selected_ids,
  bool? prefer_veg,
}) {
  if (selected_ids.isEmpty || recipes.isEmpty) return [];

  final picks = fridgeIngredientOptions
      .where((item) => selected_ids.contains(item.id))
      .toList();

  final results = <FridgeMatchResult>[];
  for (final recipe in recipes) {
    if (prefer_veg == true && !recipe.is_veg) continue;

    final profile = _recipe_fridge_profile(recipe);
    final matched_labels = <String>[];

    for (final pick in picks) {
      final strength = profile[pick.id] ?? 0;
      if (strength >= _min_match_strength) {
        matched_labels.add(pick.label);
      }
    }

    if (matched_labels.length != picks.length) continue;

    final score = _score_recipe(recipe, picks, selected_ids, profile);
    results.add(
      FridgeMatchResult(
        recipe: recipe,
        match_count: matched_labels.length,
        score: score,
        matched_labels: matched_labels,
      ),
    );
  }

  results.sort((a, b) {
    if (b.score != a.score) return b.score.compareTo(a.score);
    if (b.match_count != a.match_count) {
      return b.match_count.compareTo(a.match_count);
    }
    return a.recipe.name.compareTo(b.recipe.name);
  });
  return results;
}

FridgeMatchResult? spinFridgeRoulette({
  required List<Recipe> recipes,
  required Set<String> selected_ids,
  bool? prefer_veg,
  Random? random,
}) {
  final matches = matchRecipesToFridge(
    recipes: recipes,
    selected_ids: selected_ids,
    prefer_veg: prefer_veg,
  );
  if (matches.isEmpty) return null;

  final top_score = matches.first.score;
  final top = matches.where((m) => m.score == top_score).toList();
  if (top.length == 1) return top.first;

  final rng = random ?? Random();
  return top[rng.nextInt(top.length)];
}
