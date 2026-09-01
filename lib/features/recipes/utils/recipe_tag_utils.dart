import '../../plans/models/recipe.dart';

String _normalize_tag_label(String label) {
  return label.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

List<RecipeTag> visible_recipe_tags(List<RecipeTag> tags, {int? limit}) {
  if (tags.isEmpty) return tags;

  final keep = List<bool>.filled(tags.length, true);
  final normalized = tags.map((tag) => _normalize_tag_label(tag.label)).toList();

  for (var i = 0; i < tags.length; i++) {
    if (!keep[i]) continue;
    for (var j = 0; j < tags.length; j++) {
      if (i == j || !keep[i]) continue;
      final left = normalized[i];
      final right = normalized[j];
      if (left == right) {
        keep[i] = false;
        break;
      }
      if (right.contains(left) && right.length > left.length) {
        keep[i] = false;
        break;
      }
      if (left.contains(right) && left.length > right.length) {
        keep[j] = false;
      }
    }
  }

  final out = <RecipeTag>[];
  for (var i = 0; i < tags.length; i++) {
    if (keep[i]) out.add(tags[i]);
  }

  if (limit != null && out.length > limit) {
    return out.take(limit).toList();
  }
  return out;
}
