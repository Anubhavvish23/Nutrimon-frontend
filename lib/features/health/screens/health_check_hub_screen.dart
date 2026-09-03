import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/premium/premium_card.dart';
import '../providers/bmi_profile_provider.dart';
import '../providers/health_profile_provider.dart';

class HealthCheckHubScreen extends ConsumerWidget {
  const HealthCheckHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = context.app;
    final bmi_profile = ref.watch(bmiProfileProvider);
    final health_profile = ref.watch(healthProfileProvider);

    final bmi_subtitle = bmi_profile.is_calculated
        ? 'BMI ${bmi_profile.bmi.toStringAsFixed(1)}'
        : 'Not completed';

    final sleep_subtitle = health_profile.has_sleep
        ? '${health_profile.sleep_hours!.toStringAsFixed(1)} hrs / night'
        : 'Not set';

    final conditions_subtitle = health_profile.has_conditions
        ? '${health_profile.allergies.length + health_profile.conditions.length} noted'
        : 'None added';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => pop_or_home(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: app.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: app.border),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Health Check',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a card to update your health info',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PremiumSettingsTile(
                icon: Icons.monitor_weight_outlined,
                icon_color: const Color(0xFF1DB954),
                title: 'BMI',
                subtitle: bmi_subtitle,
                on_tap: () => context.push('/bmi'),
              ),
              const SizedBox(height: 12),
              PremiumSettingsTile(
                icon: Icons.bedtime_outlined,
                icon_color: const Color(0xFF0A84FF),
                title: 'Sleep cycle',
                subtitle: sleep_subtitle,
                on_tap: () => context.push('/health/sleep'),
              ),
              const SizedBox(height: 12),
              PremiumSettingsTile(
                icon: Icons.health_and_safety_outlined,
                icon_color: const Color(0xFFFF9500),
                title: 'Allergies & conditions',
                subtitle: conditions_subtitle,
                on_tap: () => context.push('/health/allergies'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
