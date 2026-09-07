import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import 'symptom_analysis_provider.dart';

class CustomSymptomHistoryItem {
  final String id;
  final String custom_text;
  final SymptomAnalysisResult analysis;
  final DateTime created_at;

  const CustomSymptomHistoryItem({
    required this.id,
    required this.custom_text,
    required this.analysis,
    required this.created_at,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'custom_text': custom_text,
      'created_at': created_at.toIso8601String(),
      'analysis': analysis.analysis,
      'possible_deficiencies': analysis.possible_deficiencies,
      'food_tips': analysis.food_tips,
      'meal_suggestions': analysis.meal_suggestions
          .map(
            (meal) => {
              'slug': meal.slug,
              'name': meal.name,
              'emoji': meal.emoji,
              'action_text': meal.action_text,
              'calories': meal.calories,
              'protein': meal.protein,
            },
          )
          .toList(),
      'source': analysis.source,
      'disclaimer': analysis.disclaimer,
      'analyzed_slugs': analysis.analyzed_slugs,
    };
  }

  factory CustomSymptomHistoryItem.fromJson(Map<String, dynamic> json) {
    return CustomSymptomHistoryItem(
      id: json['id']?.toString() ?? '',
      custom_text: json['custom_text']?.toString() ?? '',
      created_at:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
      analysis: SymptomAnalysisResult.fromApi(
        json,
        analyzed_slugs: _as_string_list(json['analyzed_slugs']),
        custom_text: json['custom_text']?.toString() ?? '',
      ),
    );
  }
}

class CustomSymptomHistoryNotifier
    extends Notifier<List<CustomSymptomHistoryItem>> {
  static const _storage_key = 'custom_symptom_history_v1';
  bool _loaded = false;

  @override
  List<CustomSymptomHistoryItem> build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return const [];
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storage_key);
    if (raw == null || raw.isEmpty) {
      state = const [];
      return;
    }
    state = _parse_list(jsonDecode(raw));
  }

  Future<void> applyFromCloud(List<dynamic> raw) async {
    state = _parse_list(raw);
    await _persist(sync_cloud: false);
  }

  Future<void> add_from_analysis(SymptomAnalysisResult analysis) async {
    final text = analysis.custom_text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final item = CustomSymptomHistoryItem(
      id: 'custom_${now.millisecondsSinceEpoch}',
      custom_text: text,
      analysis: analysis,
      created_at: now,
    );

    final without_same = state
        .where(
          (entry) =>
              entry.custom_text.trim().toLowerCase() != text.toLowerCase(),
        )
        .toList();
    state = [item, ...without_same].take(30).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _persist();
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storage_key);
    state = const [];
  }

  Future<void> _persist({bool sync_cloud = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = state.map((item) => item.toJson()).toList();
    await prefs.setString(_storage_key, jsonEncode(payload));
    if (sync_cloud) {
      await ApiService.saveUserProfile({
        'custom_symptom_history': payload,
      });
    }
  }

  List<CustomSymptomHistoryItem> _parse_list(dynamic raw) {
    if (raw is! List) return const [];
    final items = <CustomSymptomHistoryItem>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        items.add(CustomSymptomHistoryItem.fromJson(item));
      } else if (item is Map) {
        items.add(
          CustomSymptomHistoryItem.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    return items;
  }
}

List<String> _as_string_list(dynamic value) {
  if (value is! List) return [];
  return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
}

final customSymptomHistoryProvider = NotifierProvider<
    CustomSymptomHistoryNotifier, List<CustomSymptomHistoryItem>>(
  CustomSymptomHistoryNotifier.new,
);
