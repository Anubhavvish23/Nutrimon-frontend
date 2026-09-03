import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_update_config.dart';

class AppUpdateInfo {
  final String latest_version;
  final int build_number;
  final String apk_url;
  final String message;
  final bool force_update;

  const AppUpdateInfo({
    required this.latest_version,
    required this.build_number,
    required this.apk_url,
    required this.message,
    required this.force_update,
  });

  factory AppUpdateInfo.from_json(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latest_version: json['latest_version']?.toString() ?? '',
      build_number: int.tryParse(json['build_number']?.toString() ?? '') ?? 0,
      apk_url: json['apk_url']?.toString() ?? '',
      message: json['message']?.toString() ?? 'A new version is available.',
      force_update: json['force_update'] == true,
    );
  }
}

class AppUpdateService {
  static const _dismissed_build_key = 'dismissed_update_build';

  static Future<AppUpdateInfo?> check_for_update() async {
    final package = await PackageInfo.fromPlatform();
    final current_build = int.tryParse(package.buildNumber.trim()) ?? 0;

    if (current_build <= 0) {
      debugPrint('Update check skipped: unknown local build '
          '"${package.buildNumber}"');
      return null;
    }

    final remote = await _fetch_remote();
    if (remote == null) return null;

    if (remote.build_number <= 0) {
      debugPrint('Update check skipped: invalid remote build number');
      return null;
    }
    if (remote.build_number <= current_build) return null;

    if (!is_newer_version(remote.latest_version, package.version)) {
      debugPrint('Update check skipped: remote version '
          '"${remote.latest_version}" is not newer than "${package.version}"');
      return null;
    }

    if (!remote.force_update) {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getInt(_dismissed_build_key) ?? 0;
      if (dismissed >= remote.build_number) return null;
    }

    return remote;
  }

  static bool is_newer_version(String remote_version, String current_version) {
    final remote = _parse_version(remote_version);
    final current = _parse_version(current_version);
    if (remote.isEmpty || current.isEmpty) return true;

    final length = remote.length > current.length ? remote.length : current.length;
    for (var i = 0; i < length; i++) {
      final remote_part = i < remote.length ? remote[i] : 0;
      final current_part = i < current.length ? current[i] : 0;
      if (remote_part != current_part) return remote_part > current_part;
    }
    return false;
  }

  static List<int> _parse_version(String value) {
    final trimmed = value.split('+').first.trim();
    if (trimmed.isEmpty) return const [];

    final parts = trimmed.split('.');
    final numbers = <int>[];
    for (final part in parts) {
      final digits = RegExp(r'\d+').firstMatch(part)?.group(0);
      if (digits == null) return const [];
      numbers.add(int.parse(digits));
    }
    return numbers;
  }

  static Future<void> dismiss_update(int build_number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dismissed_build_key, build_number);
  }

  static Future<String> current_version_label() async {
    final package = await PackageInfo.fromPlatform();
    return '${package.version} (${package.buildNumber})';
  }

  static String resolve_apk_url(String apk_url) {
    if (apk_url.startsWith('http://') || apk_url.startsWith('https://')) {
      return apk_url;
    }
    final base = AppUpdateConfig.site_base_url.replaceAll(RegExp(r'/$'), '');
    final path = apk_url.startsWith('/') ? apk_url : '/$apk_url';
    return '$base$path';
  }

  static Future<AppUpdateInfo?> _fetch_remote() async {
    try {
      final response = await http
          .get(
            Uri.parse(AppUpdateConfig.version_check_url),
            headers: {'Cache-Control': 'no-cache'},
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return AppUpdateInfo.from_json(decoded);
    } catch (_) {
      return null;
    }
  }
}
