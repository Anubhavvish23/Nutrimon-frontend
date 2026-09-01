import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cloud_profile_bootstrap.dart';
import '../../../core/services/cloud_profile_sync.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/services/local_user_data_reset.dart';
import '../../../core/services/phone_auth_service.dart';
import '../../profile/providers/current_user_provider.dart';
import '../providers/auth_provider.dart';

String resolve_display_name({String? name, String? email}) {
  final trimmed_name = name?.trim() ?? '';
  if (trimmed_name.isNotEmpty) return trimmed_name;

  final trimmed_email = email?.trim() ?? '';
  final at = trimmed_email.indexOf('@');
  if (at > 0) return trimmed_email.substring(0, at);

  return 'Nutri User';
}

Future<void> completeAuthSession(
  WidgetRef ref,
  Map<String, dynamic> data, {
  String? fallback_name,
  String? fallback_email,
}) async {
  final token = data['access_token'] as String;
  final refresh_token = data['refresh_token'] as String?;
  final user = data['user'] as Map<String, dynamic>?;
  final name = (user?['name'] as String?)?.trim();
  final email = (user?['email'] as String?)?.trim();
  final resolved_email = (email != null && email.isNotEmpty)
      ? email
      : fallback_email ?? '';
  final resolved_name = resolve_display_name(
    name: name ?? fallback_name,
    email: resolved_email,
  );

  await clearLocalUserData(ref);
  await ref.read(authProvider.notifier).login(
        token,
        refresh_token: refresh_token,
        name: resolved_name,
        email: resolved_email,
      );

  try {
    await ApiService.saveUserProfile({'name': resolved_name});
  } catch (_) {}

  await loadCloudUserProfile(ref.read);
  ref.read(cloudProfileLoadedProvider.notifier).state = true;
  ref.invalidate(currentUserProvider);
}

Future<void> completeFirebaseDirectSession(WidgetRef ref) async {
  final user = PhoneAuthService.current_user();
  if (user == null) {
    throw Exception('Not signed in');
  }

  final token = await user.getIdToken();
  if (token == null || token.isEmpty) {
    throw Exception('Could not get auth token');
  }

  final phone = user.phoneNumber ?? '';
  final resolved_email = user.email ?? phone;
  final name = resolve_display_name(
    name: user.displayName,
    email: resolved_email,
  );

  await clearLocalUserData(ref);
  await ref.read(authProvider.notifier).login(
        token,
        name: name,
        email: resolved_email,
      );

  await loadCloudUserProfile(ref.read);
  ref.read(cloudProfileLoadedProvider.notifier).state = true;
  ref.invalidate(currentUserProvider);
}

Future<void> handleGoogleSignIn(WidgetRef ref) async {
  final google_result = await GoogleAuthService.signIn();
  final api_result = await ApiService.loginWithGoogle(
    id_token: google_result.id_token!,
    access_token: google_result.access_token,
    name: google_result.display_name,
  );

  if (!api_result['success']) {
    throw Exception(api_result['error'] as String? ?? 'Google sign-in failed');
  }

  await completeAuthSession(
    ref,
    api_result['data'] as Map<String, dynamic>,
    fallback_name: google_result.display_name,
    fallback_email: google_result.email,
  );
}
