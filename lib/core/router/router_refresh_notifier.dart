import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/plans/providers/meal_preferences_provider.dart';
import '../providers/onboarding_bmi_gate_provider.dart';
import '../services/cloud_profile_bootstrap.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
    _ref.listen(mealPreferencesProvider, (_, __) => notifyListeners());
    _ref.listen(cloudProfileLoadedProvider, (_, __) => notifyListeners());
    _ref.listen(onboardingBmiInProgressProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier(ref);
});
