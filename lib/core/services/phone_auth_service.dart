import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verification_id;
  static int? _resend_token;

  static String normalize_phone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+')) return trimmed;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return '+$digits';
  }

  static Future<void> send_otp(String phone) async {
    final completer = Completer<void>();
    final normalized = normalize_phone(phone);

    await _auth.verifyPhoneNumber(
      phoneNumber: normalized,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resend_token,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(error.message ?? 'Could not send OTP'),
          );
        }
      },
      codeSent: (verification_id, force_resending_token) {
        _verification_id = verification_id;
        _resend_token = force_resending_token;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verification_id) {
        _verification_id = verification_id;
      },
    );

    return completer.future;
  }

  static Future<User> verify_otp(String code) async {
    final verification_id = _verification_id;
    if (verification_id == null || verification_id.isEmpty) {
      throw Exception('Send OTP first');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verification_id,
      smsCode: code.trim(),
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw Exception('Phone sign-in failed');
    }
    return user;
  }

  static User? current_user() => _auth.currentUser;

  static Future<String?> fresh_id_token() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(true);
  }
}
