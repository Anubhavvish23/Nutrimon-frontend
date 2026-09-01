import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/recipe_rating.dart';

class RecipeRatingsNotifier extends Notifier<Map<String, RecipeRating>> {
  static const _key = 'recipe_ratings';
  bool _loaded = false;

  @override
  Map<String, RecipeRating> build() {
    if (!_loaded) {
      _loaded = true;
      _load_local();
    }
    return {};
  }

  Future<void> _load_local() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        applyFromCloud(decoded, sync_cloud: false);
      } else if (decoded is Map) {
        applyFromCloud(Map<String, dynamic>.from(decoded), sync_cloud: false);
      }
    } catch (_) {}
  }

  void applyFromCloud(
    Map<String, dynamic> raw, {
    bool sync_cloud = true,
  }) {
    final next = <String, RecipeRating>{};
    raw.forEach((slug, value) {
      if (value is Map<String, dynamic>) {
        next[slug] = RecipeRating.fromJson(value);
      } else if (value is Map) {
        next[slug] = RecipeRating.fromJson(Map<String, dynamic>.from(value));
      }
    });
    state = next;
    _persist_local();
    if (sync_cloud) {
      unawaited(_sync_cloud());
    }
  }

  Set<String> get disliked_slugs {
    return state.entries
        .where((entry) => !entry.value.liked)
        .map((entry) => entry.key)
        .toSet();
  }

  RecipeRating? ratingFor(String? slug) {
    if (slug == null || slug.isEmpty) return null;
    return state[slug];
  }

  Future<void> saveRating({
    required String slug,
    required bool liked,
    String? note,
  }) async {
    final next = Map<String, RecipeRating>.from(state);
    next[slug] = RecipeRating(
      liked: liked,
      note: note,
      rated_at: DateTime.now(),
    );
    state = next;
    await _persist_local();
    await _sync_cloud();
  }

  Future<void> _persist_local() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{};
    state.forEach((slug, rating) {
      payload[slug] = rating.toJson();
    });
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<void> _sync_cloud() async {
    final payload = <String, dynamic>{};
    state.forEach((slug, rating) {
      payload[slug] = rating.toJson();
    });
    await ApiService.saveUserProfile({'recipe_ratings': payload});
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = {};
  }
}

final recipeRatingsProvider =
    NotifierProvider<RecipeRatingsNotifier, Map<String, RecipeRating>>(
  RecipeRatingsNotifier.new,
);
