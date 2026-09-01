import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  static const _key = 'favorite_recipe_slugs';
  bool _loaded = false;

  @override
  Set<String> build() {
    if (!_loaded) {
      _loaded = true;
      _load_local();
    }
    return <String>{};
  }

  Future<void> _load_local() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key) ?? [];
    state = values.toSet();
  }

  void applyFromCloud(Set<String> slugs) {
    state = Set<String>.from(slugs);
    _persist_local();
  }

  Future<void> toggle(String slug) async {
    final next = Set<String>.from(state);
    if (next.contains(slug)) {
      next.remove(slug);
    } else {
      next.add(slug);
    }
    state = next;
    await _persist_local();
    await ApiService.saveUserProfile({
      'favorite_recipe_slugs': next.toList(),
    });
  }

  Future<void> _persist_local() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state.toList());
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = <String>{};
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
