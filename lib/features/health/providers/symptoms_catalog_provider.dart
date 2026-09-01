import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/catalog/catalog_api_parse.dart';
import '../../../core/services/api_service.dart';
import '../models/symptom_catalog_item.dart';

final symptomsCatalogProvider =
    FutureProvider<List<SymptomCatalogItem>>((ref) async {
  final result = await ApiService.fetchSymptomsCatalog();
  return parseCatalogList(
    result: result,
    entity_label: 'symptoms',
    list_key: 'symptoms',
    from_json: SymptomCatalogItem.fromJson,
    keep_item: (item) => item.name.isNotEmpty,
  );
});
