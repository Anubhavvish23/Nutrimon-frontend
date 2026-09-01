import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/fridge/screens/fridge_roulette_screen.dart';
import '../../features/goals/screens/micro_goals_board_screen.dart';
import '../../features/health/screens/health_screen.dart';
import '../../features/health/screens/symptom_timeline_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/grocery/screens/grocery_list_screen.dart';
import '../../features/plans/screens/plans_screen.dart';
import '../../features/plans/screens/meal_preferences_screen.dart';
import '../../features/health/screens/bmi_calculator_screen.dart';
import '../../features/health/screens/health_check_hub_screen.dart';
import '../../features/health/screens/sleep_cycle_screen.dart';
import '../../features/health/screens/health_conditions_screen.dart';
import '../../features/recipes/screens/recipes_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/meals/screens/meal_timer_screen.dart';
import '../../features/plans/models/recipe.dart';
import '../errors/app_error_kind.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/error/app_error_screen.dart';
import '../widgets/main_shell.dart';
import '../services/cloud_profile_bootstrap.dart';
import '../../features/plans/providers/meal_preferences_provider.dart';
import 'app_page_transitions.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(cloudProfileBootstrapProvider);
  final authState = ref.watch(authProvider);
  final meal_prefs = ref.watch(mealPreferencesProvider);

  return GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) {
      return AppErrorScreen(
        kind: AppErrorKind.notFound,
        message: state.error?.toString(),
        show_back_button: true,
        on_retry: () => context.go('/home'),
        on_back: () => context.go('/home'),
      );
    },
    redirect: (context, state) {
      final isLoading = authState == AuthStatus.loading;
      final isAuthed = authState == AuthStatus.authenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' ||
          location == '/signup' ||
          location == '/forgot-password';
      final isOnboarding = location == '/onboarding';
      final isSplash = location == '/splash';
      final prefs_ready = meal_prefs.is_ready;
      final needs_onboarding =
          isAuthed && prefs_ready && !meal_prefs.has_completed_setup;

      if (isLoading) return '/splash';
      if (isAuthed && !prefs_ready && !isSplash) return '/splash';
      if (isAuthed && needs_onboarding && !isOnboarding) return '/onboarding';
      if (isAuthed && !needs_onboarding && isOnboarding) return '/home';
      if (isAuthed && isAuthRoute) {
        return needs_onboarding ? '/onboarding' : '/home';
      }
      if (!isAuthed && !isAuthRoute && !isSplash) return '/signup';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => AppPageTransitions.slide(
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => AppPageTransitions.slide(
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => AppPageTransitions.fade(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => AppPageTransitions.none(
              state: state,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/plans',
            pageBuilder: (context, state) => AppPageTransitions.none(
              state: state,
              child: const PlansScreen(),
            ),
          ),
          GoRoute(
            path: '/health',
            pageBuilder: (context, state) => AppPageTransitions.none(
              state: state,
              child: const HealthScreen(),
            ),
          ),
          GoRoute(
            path: '/health-check',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const HealthCheckHubScreen(),
            ),
          ),
          GoRoute(
            path: '/bmi',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const BMICalculatorScreen(),
            ),
          ),
          GoRoute(
            path: '/health/sleep',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const SleepCycleScreen(),
            ),
          ),
          GoRoute(
            path: '/health/allergies',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const HealthConditionsScreen(),
            ),
          ),
          GoRoute(
            path: '/recipes',
            pageBuilder: (context, state) => AppPageTransitions.none(
              state: state,
              child: RecipesScreen(
                initial_favorites:
                    state.uri.queryParameters['favorites'] == 'true',
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => AppPageTransitions.none(
              state: state,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/meal-preferences',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const MealPreferencesScreen(),
            ),
          ),
          GoRoute(
            path: '/meal-timer',
            pageBuilder: (context, state) => AppPageTransitions.slideUp(
              state: state,
              child: MealTimerScreen(recipe: state.extra as Recipe),
            ),
          ),
          GoRoute(
            path: '/fridge-roulette',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const FridgeRouletteScreen(),
            ),
          ),
          GoRoute(
            path: '/health/symptoms-timeline',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const SymptomTimelineScreen(),
            ),
          ),
          GoRoute(
            path: '/micro-goals',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const MicroGoalsBoardScreen(),
            ),
          ),
          GoRoute(
            path: '/grocery-list',
            pageBuilder: (context, state) => AppPageTransitions.slide(
              state: state,
              child: const GroceryListScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
