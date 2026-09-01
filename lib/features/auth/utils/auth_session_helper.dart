import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/cloud_profile_bootstrap.dart';
import '../../../core/services/cloud_profile_sync.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/services/local_user_data_reset.dart';
import '../../../core/services/phone_auth_service.dart';
import '../providers/auth_provider.dart';

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

  await clearLocalUserData(ref);
  await ref.read(authProvider.notifier).login(
        token,
        refresh_token: refresh_token,
        name: (name != null && name.isNotEmpty)
            ? name
            : fallback_name ?? 'Nutri User',
        email: (email != null && email.isNotEmpty)
            ? email
            : fallback_email ?? '',
      );

  await loadCloudUserProfile(ref.read);
  ref.read(cloudProfileLoadedProvider.notifier).state = true;
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
  final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
      ? user.displayName!.trim()
      : (phone.isNotEmpty ? phone : 'Nutri User');

  await clearLocalUserData(ref);
  await ref.read(authProvider.notifier).login(
        token,
        name: name,
        email: user.email ?? phone,
      );

  await loadCloudUserProfile(ref.read);
  ref.read(cloudProfileLoadedProvider.notifier).state = true;
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
