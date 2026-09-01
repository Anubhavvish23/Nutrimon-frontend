import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/catalog/catalog_api_parse.dart';
import '../../../core/services/api_service.dart';
import '../../plans/models/recipe.dart';

final recipesCatalogProvider = FutureProvider<List<Recipe>>((ref) async {
  final result = await ApiService.fetchRecipes();
  return parseCatalogList(
    result: result,
    entity_label: 'recipes',
    list_key: 'recipes',
    from_json: Recipe.fromApiJson,
    keep_item: (recipe) => recipe.name.isNotEmpty,
  );
});
