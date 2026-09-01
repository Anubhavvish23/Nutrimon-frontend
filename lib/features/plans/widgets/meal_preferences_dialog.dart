import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/activity_options.dart';
import '../data/meal_goal_options.dart';
import '../providers/meal_preferences_provider.dart';

Future<bool?> showMealPreferencesDialog(
  BuildContext context, {
  bool barrier_dismissible = false,
  int initial_step = 0,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrier_dismissible,
    barrierLabel: 'meal_preferences',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondary_animation) {
      return _MealPreferencesOverlay(
        show_close: barrier_dismissible,
        barrier_dismissible: barrier_dismissible,
        animation: animation,
        initial_step: initial_step,
      );
    },
    transitionBuilder: (context, animation, secondary_animation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _MealPreferencesOverlay extends StatelessWidget {
  final bool show_close;
  final bool barrier_dismissible;
  final Animation<double> animation;
  final int initial_step;

  const _MealPreferencesOverlay({
    required this.show_close,
    required this.barrier_dismissible,
    required this.animation,
    required this.initial_step,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: barrier_dismissible
                ? () => Navigator.of(context).pop()
                : null,
            behavior: HitTestBehavior.opaque,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),
          ),
          FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: Center(
                child: _MealPreferencesDialogContent(
                  show_close: show_close,
                  initial_step: initial_step,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealPreferencesDialogContent extends ConsumerStatefulWidget {
  final bool show_close;
  final int initial_step;

  const _MealPreferencesDialogContent({
    required this.show_close,
    required this.initial_step,
  });

  @override
  ConsumerState<_MealPreferencesDialogContent> createState() =>
      _MealPreferencesDialogContentState();
}

class _MealPreferencesDialogContentState
    extends ConsumerState<_MealPreferencesDialogContent> {
  late final PageController _page_controller;
  late String? _diet_type;
  late Set<String> _selected_goals;
  late String? _gender;
  late Set<String> _selected_activities;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(mealPreferencesProvider);
    _diet_type = prefs.diet_type;
    _selected_goals = Set<String>.from(prefs.meal_goals);
    _gender = prefs.gender;
    _selected_activities = Set<String>.from(prefs.activities);
    _page_controller = PageController(initialPage: widget.initial_step);
  }

  @override
  void dispose() {
    _page_controller.dispose();
    super.dispose();
  }

  void _goToGoals() {
    if (_diet_type == null) return;
    _page_controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _goToLifestyle() {
    if (_selected_goals.isEmpty) return;
    _page_controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    if (_diet_type == null ||
        _selected_goals.isEmpty ||
        _gender == null ||
        _selected_activities.isEmpty) {
      return;
    }
    await ref.read(mealPreferencesProvider.notifier).saveAll(
          diet_type: _diet_type!,
          meal_goals: _selected_goals,
          gender: _gender!,
          activities: _selected_activities,
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  void _toggleGoal(String goal_id) {
    setState(() {
      if (_selected_goals.contains(goal_id)) {
        _selected_goals.remove(goal_id);
      } else {
        _selected_goals.add(goal_id);
      }
    });
  }

  void _toggleActivity(String activity_id) {
    setState(() {
      if (activity_id == 'none') {
        _selected_activities
          ..clear()
          ..add('none');
        return;
      }
      _selected_activities.remove('none');
      if (_selected_activities.contains(activity_id)) {
        _selected_activities.remove(activity_id);
      } else {
        _selected_activities.add(activity_id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: PageView(
                controller: _page_controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDietStep(),
                  _buildGoalsStep(),
                  _buildLifestyleStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Meal preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (widget.show_close)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Color(0xFF666666)),
            ),
        ],
      ),
    );
  }

  Widget _buildDietStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diet type',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose veg or non-veg for your plan',
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dietCard(
                  emoji: '🥗',
                  title: 'Vegetarian',
                  subtitle: 'Plant-based & egg-free',
                  color: const Color(0xFF1DB954),
                  selected: _diet_type == 'veg',
                  onTap: () => setState(() => _diet_type = 'veg'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dietCard(
                  emoji: '🍗',
                  title: 'Non-vegetarian',
                  subtitle: 'Includes eggs & more',
                  color: const Color(0xFFFF9500),
                  selected: _diet_type == 'non_veg',
                  onTap: () => setState(() => _diet_type = 'non_veg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: 'Next',
            enabled: _diet_type != null,
            onTap: _goToGoals,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your goals',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select all that apply — we\'ll personalize your meals',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final card_width = (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: mealGoalOptions.map((option) {
                        final selected = _selected_goals.contains(option.id);
                        return SizedBox(
                          width: card_width,
                          child: _goalChip(
                            option: option,
                            selected: selected,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: _secondaryButton(
                  label: 'Back',
                  onTap: () => _page_controller.previousPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _primaryButton(
                  label: 'Next',
                  enabled: _selected_goals.isNotEmpty,
                  onTap: _goToLifestyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLifestyleStep() {
    final can_save =
        _gender != null && _selected_activities.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gender',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: genderOptions.map((option) {
                    final selected = _gender == option;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: option == genderOptions.last ? 0 : 8,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _gender = option),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF1DB954).withOpacity(0.18)
                                  : const Color(0xFF242424),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF1DB954)
                                    : const Color(0xFF333333),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              option,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFFAAAAAA),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Activities & sports',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select what you do regularly — we match fuel to it',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final card_width = (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: activityOptions.map((option) {
                        final selected =
                            _selected_activities.contains(option.id);
                        return SizedBox(
                          width: card_width,
                          child: GestureDetector(
                            onTap: () => _toggleActivity(option.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? option.color.withOpacity(0.18)
                                    : const Color(0xFF242424),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? option.color
                                      : const Color(0xFF333333),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(option.emoji,
                                          style: const TextStyle(fontSize: 20)),
                                      const Spacer(),
                                      if (selected)
                                        Icon(Icons.check_circle,
                                            color: option.color, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    option.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: _secondaryButton(
                  label: 'Back',
                  onTap: () => _page_controller.previousPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _primaryButton(
                  label: 'Save',
                  enabled: can_save,
                  onTap: _finish,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dietCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                if (selected) Icon(Icons.check_circle, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalChip({required MealGoalOption option, required bool selected}) {
    return GestureDetector(
      onTap: () => _toggleGoal(option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withOpacity(0.18)
              : const Color(0xFF242424),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? option.color : const Color(0xFF333333),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 22)),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle, color: option.color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              option.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option.subtitle,
              style: const TextStyle(color: Color(0xFF777777), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? Colors.white : const Color(0xFF666666),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
