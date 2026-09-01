import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
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
      await Future.wait([
        Firebase.initializeApp(),
        GoogleFonts.pendingFonts([GoogleFonts.plusJakartaSans()]),
      ]);
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('App startup init failed: $e');
    } finally {
      if (!_ready.isCompleted) {
        _ready.complete();
      }
    }
  }
}
