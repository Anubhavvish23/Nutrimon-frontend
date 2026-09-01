import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/catalog/catalog_api_parse.dart';
import '../../../core/services/api_service.dart';
import '../models/did_you_know_fact.dart';

final didYouKnowFactsProvider =
    FutureProvider<List<DidYouKnowFact>>((ref) async {
  final result = await ApiService.fetchDidYouKnowFacts();
  return parseCatalogList(
    result: result,
    entity_label: 'facts',
    list_key: 'facts',
    from_json: DidYouKnowFact.fromJson,
    keep_item: (fact) => fact.fact.isNotEmpty,
  );
});
