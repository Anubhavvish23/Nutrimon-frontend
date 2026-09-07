import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/nav.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../plans/providers/meal_preferences_provider.dart';
import '../models/bmi_profile.dart';
import '../providers/bmi_profile_provider.dart';
import '../widgets/value_stepper_picker.dart';

class BMICalculatorScreen extends ConsumerStatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  ConsumerState<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends ConsumerState<BMICalculatorScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _cardController;
  late Animation<Offset> _cardAnimation;

  // Answers
  String? _gender;
  int _age = 25;
  double _height = 170;
  double _weight = 70;

  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _showResult = false;
  bool _saving = false;

  bool get _from_onboarding {
    return GoRouterState.of(context).uri.queryParameters['from'] ==
        'onboarding';
  }

  static const List<String> _step_titles = [
    'Which team are you on? 👤',
    'How young are you? ✨',
    'How tall are you? 📏',
    'What do you weigh? ⚖️',
  ];

  static const List<String> _step_hints = [
    'Pick what feels right',
    'Tap +/− or pick a quick age',
    'Tap +/− or pick a quick height',
    'Almost there — last one!',
  ];

  double get _bmi {
    final h = _height / 100;
    return _weight / (h * h);
  }

  String get _bmiLabel => bmiLabelFor(_bmi);

  Color get _bmiColor => bmiColorFor(_bmi);

  void _animateProgress(int step) {
    final target = (step + 1) / _totalSteps;
    _progressController.animateTo(
      target,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goToNext() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _animateProgress(_currentStep);
      return;
    }
    if (_gender == null || _saving) return;
    setState(() => _saving = true);
    await ref.read(bmiProfileProvider.notifier).saveFromCalculator(
          gender: _gender!,
          age: _age,
          height_cm: _height,
          weight_kg: _weight,
        );
    if (!mounted) return;
    _cardController.forward();
    setState(() {
      _saving = false;
      _showResult = true;
      _currentStep = _totalSteps;
    });
    _progressController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  void _finish_bmi() {
    if (_from_onboarding && context.canPop()) {
      context.pop();
      return;
    }
    go_back_home(context);
  }

  void _goBack() {
    if (_showResult) {
      _finish_bmi();
      return;
    }
    if (_currentStep == 0) {
      pop_or_home(context);
      return;
    }
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _animateProgress(_currentStep - 1);
  }

  @override
  void initState() {
    super.initState();
    final prefs_gender = ref.read(mealPreferencesProvider).gender;
    if (prefs_gender != null && prefs_gender.isNotEmpty) {
      _gender = prefs_gender;
    }

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 0.25,
    );

    _progressAnimation = _progressController;

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cardAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step_title = _showResult ? 'Your BMI' : _step_titles[_currentStep];
    final app = context.app;
    final on_surface = context.on_surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: _goBack,
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
                        color: on_surface,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step_title,
                      style: TextStyle(
                        color: on_surface,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!_showResult) _buildProgressBar(),
              const SizedBox(height: 24),

              // Questions or Result
              Expanded(
                child: _showResult
                    ? _buildResult()
                    : PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildGenderStep(),
                          _buildAgeStep(),
                          _buildHeightStep(),
                          _buildWeightStep(),
                        ],
                      ),
              ),

              // Next button
              if (!_showResult) ...[
                _buildNextButton(),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final app = context.app;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            color: app.border,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1DB954),
                        _bmiColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _step_hints[_currentStep],
            key: ValueKey(_currentStep),
            style: TextStyle(
              color: app.text_muted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // Step 1 — Gender
  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildGenderCard('Male', '👨')),
            const SizedBox(width: 10),
            Expanded(child: _buildGenderCard('Female', '👩')),
            const SizedBox(width: 10),
            Expanded(child: _buildGenderCard('Other', '🧑')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard(String label, String emoji) {
    final isSelected = _gender == label;
    final app = context.app;
    final on_surface = context.on_surface;
    return GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? app.accent.withValues(alpha: 0.15)
              : app.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? app.accent : app.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? on_surface : app.text_muted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return ValueStepperPicker(
      value: _age,
      min: 10,
      max: 100,
      step: 1,
      unit: ' yrs',
      emoji: '✨',
      accent: const Color(0xFF1DB954),
      quick_values: const [18, 22, 25, 30, 35, 40, 45, 50],
      on_changed: (val) => setState(() => _age = val.round()),
    );
  }

  Widget _buildHeightStep() {
    return ValueStepperPicker(
      value: _height.round(),
      min: 100,
      max: 250,
      step: 1,
      unit: ' cm',
      emoji: '📏',
      accent: const Color(0xFF0A84FF),
      quick_values: const [150, 160, 165, 170, 175, 180, 185, 190],
      on_changed: (val) => setState(() => _height = val.toDouble()),
    );
  }

  Widget _buildWeightStep() {
    return ValueStepperPicker(
      value: _weight.round(),
      min: 30,
      max: 200,
      step: 1,
      unit: ' kg',
      emoji: '⚖️',
      accent: const Color(0xFFFF9500),
      quick_values: const [50, 55, 60, 65, 70, 75, 80, 90],
      on_changed: (val) => setState(() => _weight = val.toDouble()),
    );
  }

  Widget _buildResult() {
    return SlideTransition(
      position: _cardAnimation,
      child: FadeTransition(
        opacity: _cardController,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // BMI Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _bmiColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _bmiColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _bmiColor.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: TextStyle(
                        color: _bmiColor,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _bmiLabel,
                      style: TextStyle(
                        color: _bmiColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BMI sectioned bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 25,
                              child: Container(
                                  height: 10,
                                  color: const Color(0xFF0A84FF))),
                          const SizedBox(width: 2),
                          Expanded(
                              flex: 25,
                              child: Container(
                                  height: 10,
                                  color: const Color(0xFF1DB954))),
                          const SizedBox(width: 2),
                          Expanded(
                              flex: 25,
                              child: Container(
                                  height: 10,
                                  color: const Color(0xFFFF9500))),
                          const SizedBox(width: 2),
                          Expanded(
                              flex: 25,
                              child: Container(
                                  height: 10,
                                  color: const Color(0xFFFF375F))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Expanded(
                            child: Text('Under',
                                style: TextStyle(
                                    color: Color(0xFF0A84FF),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Normal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFF1DB954),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Over',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFFF9500),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            child: Text('Obese',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Color(0xFFFF375F),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _buildStatCard(
                    '👤',
                    _gender ?? '—',
                    const Color(0xFFBF5AF2),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '🎂',
                    '$_age',
                    const Color(0xFF0A84FF),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatCard(
                    '📏',
                    '${_height.toInt()}',
                    const Color(0xFF1DB954),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '⚖️',
                    '${_weight.toInt()}',
                    const Color(0xFFFF9500),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: _finish_bmi,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.app.accent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _from_onboarding ? 'Continue' : 'Back to Home',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showResult = false;
                    _currentStep = 0;
                    _gender = null;
                    _age = 25;
                    _height = 170;
                    _weight = 70;
                  });
                  _pageController.jumpToPage(0);
                  _progressController.animateTo(0.25,
                      duration: const Duration(milliseconds: 400));
                  _cardController.reset();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.app.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.app.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: context.app.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recalculate',
                        style: TextStyle(
                          color: context.on_surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, Color color) {
    final on_surface = context.on_surface;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: on_surface,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final canProceed =
        !_saving && (_currentStep == 0 ? _gender != null : true);
    final app = context.app;
    return GestureDetector(
      onTap: canProceed ? _goToNext : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: canProceed ? app.accent : app.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canProceed ? app.accent : app.border,
          ),
          boxShadow: canProceed
              ? [
                  BoxShadow(
                    color: app.accent.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _saving
                  ? 'Calculating...'
                  : (_currentStep == _totalSteps - 1 ? 'Calculate BMI' : 'Next'),
              style: TextStyle(
                color: canProceed ? Colors.white : app.text_muted,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}