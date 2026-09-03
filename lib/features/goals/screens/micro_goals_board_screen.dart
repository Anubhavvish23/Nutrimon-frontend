import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/skeleton/skeleton.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/premium/premium_card.dart';
import '../data/micro_goal_definitions.dart';
import '../providers/micro_goals_provider.dart';

class MicroGoalsBoardScreen extends ConsumerWidget {
  const MicroGoalsBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(microGoalsProvider);
    final done = goals.completed_today_count;
    final app = context.app;
    final on_surface = context.on_surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SkeletonResponsive.horizontalPadding(context),
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => pop_or_home(context),
                      icon: Icon(Icons.arrow_back_ios_new, size: 18, color: on_surface),
                    ),
                    Expanded(
                      child: Text(
                        'Micro-goals',
                        style: TextStyle(
                          color: on_surface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$done/${microGoalDefinitions.length}',
                      style: const TextStyle(
                        color: Color(0xFF1DB954),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: SkeletonResponsive.horizontalPadding(context),
                  ),
                  children: [
                    Text(
                      'Tiny wins beat perfect weeks. Knock out a few each morning.',
                      style: TextStyle(
                        color: app.text_muted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...microGoalDefinitions.map((def) {
                      final current = goals.displayValue(def);
                      final ratio = goals.ratioFor(def);
                      final done_goal = goals.isDone(def);
                      final color = Color(def.color.value);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PremiumCard(
                          border_color: done_goal
                              ? color.withOpacity(0.55)
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(def.emoji,
                                      style: const TextStyle(fontSize: 28)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          def.title,
                                          style: TextStyle(
                                            color: on_surface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          def.subtitle,
                                          style: TextStyle(
                                            color: app.text_muted,
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    done_goal
                                        ? 'Done'
                                        : '$current/${def.target}',
                                    style: TextStyle(
                                      color: done_goal
                                          ? color
                                          : const Color(0xFFB0B0B0),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: app.border,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    PremiumCard(
                      on_tap: () => context.push('/fridge-roulette'),
                      child: Row(
                        children: [
                          const Text('🧊', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Open Fridge Roulette',
                              style: TextStyle(
                                color: on_surface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: app.text_muted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    PremiumCard(
                      on_tap: () => context.push('/health/symptoms-timeline'),
                      child: Row(
                        children: [
                          const Text('📈', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Open Symptom timeline',
                              style: TextStyle(
                                color: on_surface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: app.text_muted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
