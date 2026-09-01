import '../../plans/models/recipe.dart';
import 'recipe_tag_utils.dart';

Map<String, dynamic> recipeToCardMap(Recipe recipe) {
  final tags = visible_recipe_tags(recipe.tags, limit: 2);
  return {
    'slug': recipe.slug ?? recipe.name,
    'emoji': recipe.emoji,
    'name': recipe.name,
    'time': recipe.time,
    'cal': recipe.calories,
    'protein': recipe.protein,
    'tags': tags
        .map(
          (tag) => {
            'label': tag.label,
            'color': tag.color,
          },
        )
        .toList(),    'bg': recipe.background_color,
    'border': recipe.accent_color,
    'circle': recipe.accent_color,
    'is_veg': recipe.is_veg,
  };
}
