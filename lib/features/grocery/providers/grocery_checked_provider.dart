import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class GroceryCheckedNotifier extends Notifier<Set<String>> {
  static const _key = 'grocery_checked_keys';
  bool _loaded = false;

  @override
  Set<String> build() {
    if (!_loaded) {
      _loaded = true;
      _load();
    }
    return <String>{};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw.toSet();
  }

  Future<void> applyFromCloud(List<String> keys) async {
    state = keys.toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, keys);
  }

  Future<void> toggle(String key) async {
    final next = Set<String>.from(state);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList());
    await ApiService.saveUserProfile({'grocery_checked': next.toList()});
  }

  bool is_checked(String key) => state.contains(key);

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = <String>{};
  }
}

final groceryCheckedProvider =
    NotifierProvider<GroceryCheckedNotifier, Set<String>>(
  GroceryCheckedNotifier.new,
);
