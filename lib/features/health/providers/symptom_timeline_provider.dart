import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../goals/providers/micro_goals_provider.dart';
import '../models/symptom_timeline_entry.dart';
import 'symptom_analysis_provider.dart';

class SymptomTimelineState {
  final List<SymptomTimelineEntry> entries;
  final bool is_ready;

  const SymptomTimelineState({
    this.entries = const [],
    this.is_ready = false,
  });

  List<SymptomTimelineEntry> get pending =>
      entries.where((e) => e.is_pending).toList();

  List<SymptomTimelineEntry> get completed =>
      entries.where((e) => !e.is_pending).toList();
}

class SymptomTimelineNotifier extends Notifier<SymptomTimelineState> {
  static const _storage_key = 'symptom_timeline_v1';
  bool _loaded = false;

  @override
  SymptomTimelineState build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return const SymptomTimelineState();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storage_key);
    if (raw == null || raw.isEmpty) {
      state = const SymptomTimelineState(is_ready: true);
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      final entries = <SymptomTimelineEntry>[];
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            entries.add(SymptomTimelineEntry.fromJson(item));
          } else if (item is Map) {
            entries.add(
              SymptomTimelineEntry.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
      state = SymptomTimelineState(entries: entries, is_ready: true);
    } catch (_) {
      state = const SymptomTimelineState(is_ready: true);
    }
  }

  Future<void> applyFromCloud(List<dynamic> raw) async {
    final entries = <SymptomTimelineEntry>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        entries.add(SymptomTimelineEntry.fromJson(item));
      } else if (item is Map) {
        entries.add(
          SymptomTimelineEntry.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    entries.sort((a, b) => b.analyzed_at.compareTo(a.analyzed_at));
    state = SymptomTimelineState(entries: entries, is_ready: true);
    await _persist(sync_cloud: false);
  }

  Future<void> addFromAnalysis(SymptomAnalysisResult analysis) async {
    final now = DateTime.now();
    final preview = analysis.analysis.length > 140
        ? '${analysis.analysis.substring(0, 140)}…'
        : analysis.analysis;
    final entry = SymptomTimelineEntry(
      id: 'sym_${now.millisecondsSinceEpoch}',
      analyzed_at: now,
      checkin_due_at: now.add(const Duration(hours: 2)),
      symptom_slugs: analysis.analyzed_slugs,
      custom_text: analysis.custom_text,
      analysis_preview: preview,
      suggested_meals:
          analysis.meal_suggestions.map((m) => m.name).take(3).toList(),
    );

    final same_pending = state.entries.where((entry) {
      if (!entry.is_pending) return false;
      if (analysis.custom_text.trim().isNotEmpty) {
        return entry.custom_text.trim().toLowerCase() ==
            analysis.custom_text.trim().toLowerCase();
      }
      if (analysis.analyzed_slugs.isEmpty) return false;
      final left = [...entry.symptom_slugs]..sort();
      final right = [...analysis.analyzed_slugs]..sort();
      return left.join('|') == right.join('|');
    }).map((entry) => entry.id).toSet();

    final kept = state.entries
        .where((entry) => !same_pending.contains(entry.id))
        .toList();
    final next = [entry, ...kept].take(40).toList();
    state = SymptomTimelineState(entries: next, is_ready: true);
    await _persist();
  }

  Future<void> submitCheckIn({
    required String entry_id,
    required int feeling_score,
    String note = '',
  }) async {
    final score = feeling_score.clamp(1, 5);
    final next = state.entries.map((entry) {
      if (entry.id != entry_id) return entry;
      return entry.copyWith(
        feeling_score: score,
        note: note.trim().isEmpty ? null : note.trim(),
        checked_in_at: DateTime.now(),
      );
    }).toList();

    state = SymptomTimelineState(entries: next, is_ready: true);
    await _persist();
    await ref.read(microGoalsProvider.notifier).recordEvent('feel_check');
  }

  Future<void> _persist({bool sync_cloud = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = state.entries.map((e) => e.toJson()).toList();
    await prefs.setString(_storage_key, jsonEncode(payload));
    if (sync_cloud) {
      await ApiService.saveUserProfile({
        'symptom_timeline': payload,
      });
    }
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storage_key);
    state = const SymptomTimelineState(is_ready: true);
  }
}

final symptomTimelineProvider =
    NotifierProvider<SymptomTimelineNotifier, SymptomTimelineState>(
  SymptomTimelineNotifier.new,
);
