import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../models/health_profile.dart';

class HealthProfileNotifier extends Notifier<HealthProfile> {
  static const _sleep_key = 'health_sleep_hours';
  static const _allergies_key = 'health_allergies';
  static const _conditions_key = 'health_conditions';
  bool _loaded = false;

  @override
  HealthProfile build() {
    if (!_loaded) {
      _loaded = true;
      _loadFromStorage();
    }
    return const HealthProfile();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final sleep = prefs.getDouble(_sleep_key);
    final allergies = _decodeList(prefs.getString(_allergies_key));
    final conditions = _decodeList(prefs.getString(_conditions_key));

    state = HealthProfile(
      sleep_hours: sleep,
      allergies: allergies,
      conditions: conditions,
    );
  }

  Future<void> applyCloudProfile({
    double? sleep_hours,
    required List<String> allergies,
    required List<String> conditions,
  }) async {
    state = HealthProfile(
      sleep_hours: sleep_hours,
      allergies: allergies,
      conditions: conditions,
    );
    final prefs = await SharedPreferences.getInstance();
    if (sleep_hours != null) {
      await prefs.setDouble(_sleep_key, sleep_hours);
    }
    await prefs.setString(_allergies_key, jsonEncode(allergies));
    await prefs.setString(_conditions_key, jsonEncode(conditions));
  }

  List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<void> saveSleepHours(double hours) async {
    state = HealthProfile(
      sleep_hours: hours,
      allergies: state.allergies,
      conditions: state.conditions,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sleep_key, hours);
    await ApiService.saveUserProfile({'sleep_hours': hours});
  }

  Future<void> saveAllergiesAndConditions({
    required List<String> allergies,
    required List<String> conditions,
  }) async {
    state = HealthProfile(
      sleep_hours: state.sleep_hours,
      allergies: allergies,
      conditions: conditions,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_allergies_key, jsonEncode(allergies));
    await prefs.setString(_conditions_key, jsonEncode(conditions));
    await ApiService.saveUserProfile({
      'allergies': allergies,
      'conditions': conditions,
    });
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sleep_key);
    await prefs.remove(_allergies_key);
    await prefs.remove(_conditions_key);
    state = const HealthProfile();
  }
}

final healthProfileProvider =
    NotifierProvider<HealthProfileNotifier, HealthProfile>(
  HealthProfileNotifier.new,
);
