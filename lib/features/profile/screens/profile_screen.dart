import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_brand.dart';
import '../../../core/services/local_user_data_reset.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/premium/premium_card.dart';
import '../../../core/skeleton/skeleton.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/terms_and_conditions_sheet.dart';
import '../../health/models/bmi_profile.dart';
import '../../health/providers/bmi_profile_provider.dart';
import '../../plans/data/meal_goal_options.dart';
import '../../plans/data/activity_options.dart';
import '../../plans/providers/meal_preferences_provider.dart';
import '../providers/current_user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user_async = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientBackground(
        child: SafeArea(
          child: user_async.when(
            loading: () => const ProfileScreenSkeleton(),
            error: (_, __) => Center(
              child: Text(
                'Failed to load profile',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            data: (user) => _ProfileContent(
              name: user.name,
              email: user.email,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final String name;
  final String email;

  const _ProfileContent({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = context.app;
    final bmi_profile = ref.watch(bmiProfileProvider);
    final meal_prefs = ref.watch(mealPreferencesProvider);
    final theme_mode = ref.watch(themeModeProvider);
    final is_dark = theme_mode == ThemeMode.dark;

    final bmi_subtitle = bmi_profile.is_calculated
        ? 'BMI ${bmi_profile.bmi.toStringAsFixed(1)} · ${bmiLabelFor(bmi_profile.bmi)}'
        : 'Complete Health Check';
    final meal_prefs_subtitle = meal_prefs.has_completed_setup
        ? '${meal_prefs.diet_label} · ${mealGoalsSummary(meal_prefs.meal_goals)} · ${activitiesSummary(meal_prefs.activities)}'
        : 'Diet, goals & activities for your plan';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: SkeletonResponsive.horizontalPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: app.accent,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(email, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          const PremiumSectionLabel('YOUR PLAN'),
          PremiumSettingsTile(
            icon: Icons.monitor_weight_outlined,
            icon_color: app.accent,
            title: 'Health Parameters',
            subtitle: bmi_subtitle,
            on_tap: () => context.go('/health-check'),
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.restaurant_menu_outlined,
            icon_color: const Color(0xFFFF9500),
            title: 'Meal preferences',
            subtitle: meal_prefs_subtitle,
            on_tap: () async {
              final saved = await context.push<bool>('/meal-preferences');
              if (saved == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Meal preferences updated'),
                    backgroundColor: app.accent,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.shopping_bag_outlined,
            icon_color: app.accent,
            title: 'Grocery list',
            subtitle: 'Ingredients from your meal plan',
            on_tap: () => context.push('/grocery-list'),
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.favorite_outline,
            icon_color: const Color(0xFFFF375F),
            title: 'Liked recipes',
            subtitle: 'Meals you saved',
            on_tap: () => context.go('/recipes?favorites=true'),
          ),
          const SizedBox(height: 24),
          const PremiumSectionLabel('TOOLS'),
          PremiumSettingsTile(
            icon: Icons.kitchen_outlined,
            icon_color: const Color(0xFFFF9500),
            title: 'Fridge Roulette',
            subtitle: 'Spin a breakfast from what you have',
            on_tap: () => context.push('/fridge-roulette'),
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.timeline_outlined,
            icon_color: const Color(0xFFBF5AF2),
            title: 'Symptom timeline',
            subtitle: '2-hour feel check-ins',
            on_tap: () => context.push('/health/symptoms-timeline'),
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.flag_outlined,
            icon_color: const Color(0xFF0A84FF),
            title: 'Micro-goals',
            subtitle: 'Tiny morning wins',
            on_tap: () => context.push('/micro-goals'),
          ),
          const SizedBox(height: 24),
          const PremiumSectionLabel('APP'),
          PremiumSettingsTile(
            icon: is_dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            icon_color: const Color(0xFFBF5AF2),
            title: 'Appearance',
            subtitle: is_dark ? 'Dark mode' : 'Light mode',
            on_tap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(
                    is_dark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.description_outlined,
            icon_color: const Color(0xFF888888),
            title: 'Terms & Conditions',
            subtitle: 'AI disclaimer and usage terms',
            on_tap: () => showTermsAndConditionsSheet(context),
          ),
          const SizedBox(height: 12),
          PremiumSettingsTile(
            icon: Icons.mail_outline,
            icon_color: const Color(0xFF0A84FF),
            title: 'Contact us',
            subtitle: AppBrand.support_email,
            on_tap: () => _showContactSheet(context),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${AppBrand.name} v${AppBrand.version}',
              style: TextStyle(color: app.text_muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            on_tap: () async {
              await clearLocalUserData(ref);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            padding: const EdgeInsets.symmetric(vertical: 16),
            border_color: const Color(0xFFFF375F).withOpacity(0.35),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Color(0xFFFF375F), size: 20),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFFF375F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    final app = context.app;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheet_context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact us',
              style: Theme.of(sheet_context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              AppBrand.support_email,
              style: TextStyle(color: app.accent, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'We usually reply within 24 hours.',
              style: Theme.of(sheet_context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: AppBrand.support_email),
                      );
                      if (sheet_context.mounted) {
                        Navigator.pop(sheet_context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Email copied'),
                            backgroundColor: app.accent,
                          ),
                        );
                      }
                    },
                    child: const Text('Copy email'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final uri = Uri(
                        scheme: 'mailto',
                        path: AppBrand.support_email,
                        query: 'subject=NutriMorning support',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: const Text('Send email'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
