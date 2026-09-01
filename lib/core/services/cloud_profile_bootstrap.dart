import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/plans/providers/meal_preferences_provider.dart';
import 'cloud_profile_sync.dart';

final cloudProfileLoadedProvider = StateProvider<bool>((ref) => false);

final cloudProfileBootstrapProvider = Provider<void>((ref) {
  final auth = ref.watch(authProvider);

  if (auth == AuthStatus.unauthenticated) {
    Future.microtask(() {
      ref.read(cloudProfileLoadedProvider.notifier).state = false;
    });
    return;
  }

  if (auth != AuthStatus.authenticated) return;
  if (ref.read(cloudProfileLoadedProvider)) return;

  Future.microtask(() async {
    for (var i = 0; i < 40; i++) {
      if (ref.read(authProvider) != AuthStatus.authenticated) return;
      if (ref.read(mealPreferencesProvider).is_ready) break;
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (!ref.read(mealPreferencesProvider).is_ready) return;
    if (ref.read(cloudProfileLoadedProvider)) return;

    await loadCloudUserProfile(ref.read);

    if (ref.read(authProvider) == AuthStatus.authenticated) {
      ref.read(cloudProfileLoadedProvider.notifier).state = true;
    }
  });
});
