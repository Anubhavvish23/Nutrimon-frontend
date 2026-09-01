import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

class FridgeLastPicksNotifier extends Notifier<List<String>> {
  static const _key = 'fridge_last_picks';

  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    state = raw;
  }

  Future<void> applyFromCloud(List<String> ids) async {
    state = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }

  Future<void> save_picks(List<String> ids) async {
    state = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
    await ApiService.saveUserProfile({'fridge_last_picks': ids});
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = [];
  }
}

final fridgeLastPicksProvider =
    NotifierProvider<FridgeLastPicksNotifier, List<String>>(
  FridgeLastPicksNotifier.new,
);
