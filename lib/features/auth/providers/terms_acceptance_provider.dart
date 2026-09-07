import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../data/terms_and_conditions.dart';

class TermsAcceptanceNotifier extends Notifier<bool> {
  static const _accepted_key = 'terms_accepted';
  static const _version_key = 'terms_accepted_version';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_accepted_key) ?? false;
    final saved_version = prefs.getString(_version_key) ?? '';
    state = accepted && saved_version == TermsAndConditions.version;
  }

  Future<bool> is_current_version_accepted() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_accepted_key) ?? false;
    final saved_version = prefs.getString(_version_key) ?? '';
    return accepted && saved_version == TermsAndConditions.version;
  }

  Future<void> mark_accepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accepted_key, true);
    await prefs.setString(_version_key, TermsAndConditions.version);
    state = true;
    try {
      await ApiService.saveUserProfile({
        'terms_accepted_at': DateTime.now().toUtc().toIso8601String(),
        'terms_version': TermsAndConditions.version,
      });
    } catch (_) {}
  }

  Future<void> applyFromCloud({
    String? terms_accepted_at,
    String? terms_version,
  }) async {
    if (terms_accepted_at == null || terms_accepted_at.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accepted_key, true);
    await prefs.setString(_version_key, TermsAndConditions.version);
    state = true;
    if (terms_version != TermsAndConditions.version) {
      try {
        await ApiService.saveUserProfile({
          'terms_accepted_at': terms_accepted_at,
          'terms_version': TermsAndConditions.version,
        });
      } catch (_) {}
    }
  }

  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accepted_key);
    await prefs.remove(_version_key);
    state = false;
  }
}

final termsAcceptedProvider =
    NotifierProvider<TermsAcceptanceNotifier, bool>(
  TermsAcceptanceNotifier.new,
);
