import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class AppStartup {
  static bool _started = false;
  static final Completer<void> _ready = Completer<void>();

  static Future<void> get ready => _ready.future;

  static void begin() {
    if (_started) return;
    _started = true;
    unawaited(_run());
  }

  static Future<void> _run() async {
    try {
      await _clear_retired_keys();
    } catch (e) {
      debugPrint('Retired key cleanup failed: $e');
    }

    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('App startup init failed: $e');
    } finally {
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    }
  }

  static Future<void> _clear_retired_keys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fridge_last_picks');
  }
}
