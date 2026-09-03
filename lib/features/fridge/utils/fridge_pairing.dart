String _pairing_key(String value) {
  final key = value.trim().toLowerCase().replaceAll('_', ' ');
  switch (key) {
    case 'eggs':
      return 'egg';
    case 'almonds':
      return 'almond';
    default:
      return key;
  }
}

const _sweet_keys = {
  'banana',
  'berries',
  'apple',
  'honey',
  'peanut butter',
  'chia',
  'almond',
  'coconut',
};

const _savory_keys = {
  'egg',
  'cheese',
  'tomato',
  'spinach',
  'chicken',
  'salmon',
  'paneer',
  'poha',
  'besan',
  'onion',
  'potato',
  'capsicum',
  'lemon',
};

bool ingredients_clash(String left, String right) {
  final a = _pairing_key(left);
  final b = _pairing_key(right);
  if (a == b) return false;
  return (_sweet_keys.contains(a) && _savory_keys.contains(b)) ||
      (_savory_keys.contains(a) && _sweet_keys.contains(b));
}

bool set_is_compatible(Iterable<String> values) {
  final list = values.toList();
  for (var i = 0; i < list.length; i++) {
    for (var j = i + 1; j < list.length; j++) {
      if (ingredients_clash(list[i], list[j])) return false;
    }
  }
  return true;
}

List<String> select_compatible_ingredients(List<String> values) {
  if (values.length <= 1) return List<String>.from(values);
  if (set_is_compatible(values)) return List<String>.from(values);

  for (var size = values.length - 1; size >= 1; size--) {
    final found = _first_compatible_subset(values, size);
    if (found.isNotEmpty) return found;
  }
  return [values.first];
}

List<String> _first_compatible_subset(List<String> values, int size) {
  final current = <String>[];
  List<String>? found;

  void walk(int start) {
    if (found != null) return;
    if (current.length == size) {
      if (set_is_compatible(current)) {
        found = List<String>.from(current);
      }
      return;
    }
    final remaining = size - current.length;
    for (var i = start; i <= values.length - remaining; i++) {
      current.add(values[i]);
      walk(i + 1);
      current.removeLast();
      if (found != null) return;
    }
  }

  walk(0);
  return found ?? const [];
}

Set<String> select_compatible_ids(Set<String> selected_ids) {
  final chosen = select_compatible_ingredients(selected_ids.toList());
  return chosen.toSet();
}
