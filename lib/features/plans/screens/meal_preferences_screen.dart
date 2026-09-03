import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/nav.dart';
import '../data/activity_options.dart';
import '../data/meal_goal_options.dart';
import '../providers/meal_preferences_provider.dart';

class MealPreferencesScreen extends ConsumerStatefulWidget {
  const MealPreferencesScreen({super.key});

  @override
  ConsumerState<MealPreferencesScreen> createState() =>
      _MealPreferencesScreenState();
}

class _MealPreferencesScreenState extends ConsumerState<MealPreferencesScreen> {
  String? _diet_type;
  late Set<String> _selected_goals;
  String? _gender;
  late Set<String> _selected_activities;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(mealPreferencesProvider);
    _diet_type = prefs.diet_type;
    _selected_goals = Set<String>.from(prefs.meal_goals);
    _gender = prefs.gender;
    _selected_activities = Set<String>.from(prefs.activities);
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

  Future<void> _save() async {
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
    if (mounted) pop_or_home(context);
  }

  @override
  Widget build(BuildContext context) {
    final can_save = _diet_type != null &&
        _selected_goals.isNotEmpty &&
        _gender != null &&
        _selected_activities.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => pop_or_home(context),
        ),
        title: const Text(
          'Meal preferences',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Diet type',
              style: TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dietTile(
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
                  child: _dietTile(
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
            const SizedBox(height: 28),
            const Text(
              'Gender',
              style: TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF1DB954)
                                : const Color(0xFF2A2A2A),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text(
              'Meal goals',
              style: TextStyle(
                color: Color(0xFFAAAAAA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select all that match what you want from breakfast',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
            const SizedBox(height: 16),
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
                      child: _goalTile(
                        option: option,
                        selected: selected,
                        onTap: () => _toggleGoal(option.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),
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
              'We fuel your plan based on how you move',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
            const SizedBox(height: 16),
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
                      child: _activityTile(
                        option: option,
                        selected: selected,
                        onTap: () => _toggleActivity(option.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: GestureDetector(
            onTap: can_save ? _save : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: can_save
                    ? const Color(0xFF1DB954)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Save preferences',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: can_save ? Colors.white : const Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dietTile({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : const Color(0xFF2A2A2A),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const Spacer(),
                if (selected) Icon(Icons.check_circle, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalTile({
    required MealGoalOption option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? option.color : const Color(0xFF2A2A2A),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle, color: option.color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              option.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.subtitle,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityTile({
    required ActivityOption option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? option.color : const Color(0xFF2A2A2A),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_circle, color: option.color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              option.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              option.subtitle,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
