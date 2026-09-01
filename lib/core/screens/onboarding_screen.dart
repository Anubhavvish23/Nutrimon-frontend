import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/plans/data/activity_options.dart';
import '../../features/plans/data/meal_goal_options.dart';
import '../../features/plans/providers/meal_preferences_provider.dart';
import '../config/app_brand.dart';
import '../widgets/app_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _page_controller = PageController();
  int _current_page = 0;
  String? _diet_type;
  final Set<String> _selected_goals = {};
  String? _gender;
  final Set<String> _selected_activities = {};

  @override
  void dispose() {
    _page_controller.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _page_controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _continueToLifestyleStep() {
    if (_diet_type == null || _selected_goals.isEmpty) return;
    _goToPage(2);
  }

  void _continueToBmiStep() {
    if (_gender == null || _selected_activities.isEmpty) return;
    _goToPage(3);
  }

  Future<void> _finishOnboarding() async {
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
    if (!mounted) return;
    context.go('/home');
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
    final can_continue_prefs =
        _diet_type != null && _selected_goals.isNotEmpty;
    final can_continue_lifestyle =
        _gender != null && _selected_activities.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildPageIndicator(),
            Expanded(
              child: PageView(
                controller: _page_controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _current_page = index),
                children: [
                  _buildWelcomePage(),
                  _buildPreferencesPage(can_continue_prefs),
                  _buildLifestylePage(can_continue_lifestyle),
                  _buildBmiPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final active = index == _current_page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withOpacity(0.35),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: const AppLogo(size: 120),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to ${AppBrand.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Personalized morning meals based on your diet, activity, and health.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _primaryButton(
            label: 'Get started',
            enabled: true,
            onTap: () => _goToPage(1),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage(bool can_continue) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set up your plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We use this to pick breakfasts you will actually enjoy.',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
                const SizedBox(height: 24),
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
                  'Meal goals',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select all that apply',
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
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: _primaryButton(
            label: 'Continue',
            enabled: can_continue,
            onTap: can_continue ? _continueToLifestyleStep : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLifestylePage(bool can_continue) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gender and activities help us match fuel to your lifestyle.',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
                const SizedBox(height: 24),
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
                        child: _chipTile(
                          label: option,
                          selected: selected,
                          color: const Color(0xFF1DB954),
                          onTap: () => setState(() => _gender = option),
                        ),
                      ),
                    );
                  }).toList(),
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
                  'Select everything you do regularly',
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
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: _primaryButton(
            label: 'Continue',
            enabled: can_continue,
            onTap: can_continue ? _continueToBmiStep : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBmiPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📊', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 24),
          const Text(
            'Know your BMI?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Optional — helps tailor portion sizes on your Plans tab.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _primaryButton(
            label: 'Calculate BMI',
            enabled: true,
            onTap: () async {
              await context.push('/bmi');
              if (mounted) await _finishOnboarding();
            },
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => _finishOnboarding(),
            child: const Text(
              'Skip for now',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? Colors.white : const Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _chipTile({
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFF2A2A2A),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFAAAAAA),
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
