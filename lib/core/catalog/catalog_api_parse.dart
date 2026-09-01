class CatalogLoadException implements Exception {
  final String message;

  CatalogLoadException(this.message);

  @override
  String toString() => message;
}

List<T> parseCatalogList<T>({
  required Map<String, dynamic> result,
  required String entity_label,
  required String list_key,
  required T Function(Map<String, dynamic> json) from_json,
  bool Function(T item)? keep_item,
}) {
  if (result['success'] != true) {
    throw CatalogLoadException(
      result['error']?.toString() ?? 'Failed to load $entity_label',
    );
  }

  final data = result['data'] as Map<String, dynamic>?;
  final raw = data?[list_key];
  if (raw is! List || raw.isEmpty) {
    throw CatalogLoadException('No $entity_label returned from server');
  }

  final items = raw
      .whereType<Map>()
      .map((e) => from_json(Map<String, dynamic>.from(e)))
      .toList();

  if (keep_item != null) {
    return items.where(keep_item).toList();
  }

  if (items.isEmpty) {
    throw CatalogLoadException('No $entity_label returned from server');
  }

  return items;
}
