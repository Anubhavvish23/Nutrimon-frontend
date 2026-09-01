import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/skeleton/skeleton.dart';
import '../../../core/theme/recipe_surface_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/premium/premium_card.dart';
import '../../health/models/bmi_profile.dart';
import '../../health/providers/bmi_profile_provider.dart';
import '../../health/providers/health_profile_provider.dart';
import '../../health/providers/selected_symptoms_provider.dart';
import '../../health/providers/symptom_analysis_provider.dart';
import '../../home/providers/home_data_provider.dart';
import '../../recipes/data/recipe_catalog.dart';
import '../../recipes/providers/recipes_catalog_provider.dart';
import '../../recipes/utils/recipe_tag_utils.dart';
import '../models/recipe.dart';
import '../providers/meal_preferences_provider.dart';
import '../providers/recipe_ratings_provider.dart';
import '../providers/saved_meal_plan_provider.dart';
import '../widgets/meal_preferences_dialog.dart';
import '../widgets/recipe_sheet_content.dart';

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen>
    with TickerProviderStateMixin {
  int _selectedDay = DateTime.now().weekday - 1;
  late AnimationController _bmiController;
  late AnimationController _staggerController;
  late ScrollController _scrollController;
  final GlobalKey _bmi_section_key = GlobalKey();
  final GlobalKey _meals_section_key = GlobalKey();
  final Random _random = Random();
  double? _last_animated_bmi;
  bool _initial_bmi_animated = false;
  String? _last_scrolled_section;
  bool _preferences_prompt_scheduled = false;
  String? _meals_prefs_key;
  bool _generating_plan = false;
  int? _swapping_index;
  String? _ai_tip;
  List<String> _activities = [];
  Map<String, String> _ai_reasons = {};
  int _applied_meal_refresh = 0;

  List<Recipe> _meals = [];

  final List<Map<String, dynamic>> _days = [
    {'label': 'MON', 'food': '🥚'},
    {'label': 'TUE', 'food': '🥑'},
    {'label': 'WED', 'food': '🥣'},
    {'label': 'THU', 'food': '🍌'},
    {'label': 'FRI', 'food': '🥞'},
    {'label': 'SAT', 'food': '🧇'},
    {'label': 'SUN', 'food': '🍓'},
  ];

  void _animateBmiBar(double bmi) {
    final target = bmiProgressFor(bmi);
    if (_last_animated_bmi == bmi) return;
    _last_animated_bmi = bmi;
    _bmiController.animateTo(
      target,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
    );
  }

  void _runStagger() {
    _staggerController.reset();
    _staggerController.forward();
  }

  String _prefsKey(MealPreferencesState prefs) {
    final bmi = ref.read(bmiProfileProvider);
    final health = ref.read(healthProfileProvider);
    final symptoms = ref.read(selectedSymptomsProvider);
    final analysis = ref.read(symptomAnalysisProvider);
    return [
      prefs.diet_type,
      prefs.meal_goals.join(','),
      prefs.gender ?? '',
      prefs.activities.join(','),
      bmi.is_calculated ? bmi.bmi.toStringAsFixed(1) : 'no-bmi',
      health.allergies.join(','),
      health.conditions.join(','),
      symptoms.join(','),
      analysis?.food_tips.join('|') ?? '',
    ].join('::');
  }

  List<Recipe>? _recipeCatalog() {
    return ref.read(recipesCatalogProvider).value;
  }

  Set<String> _plan_exclude_slugs({Set<String>? extra_slugs}) {
    final slugs = <String>{
      ...ref.read(recipeRatingsProvider.notifier).disliked_slugs,
      ..._meals.map((meal) => meal.slug ?? '').where((slug) => slug.isNotEmpty),
      if (extra_slugs != null) ...extra_slugs,
    };
    return slugs;
  }

  void _applyLocalFallback(
    MealPreferencesState prefs, {
    Set<String>? exclude_names,
    List<String> allergies = const [],
    List<String> conditions = const [],
  }) {
    setState(() {
      _meals = pickRandomMealsForPreferences(
        diet_type: prefs.diet_type!,
        meal_goals: prefs.meal_goals,
        random: _random,
        exclude_names: exclude_names,
        catalog: _recipeCatalog(),
        allergies: allergies,
        conditions: conditions,
      );
      _ai_tip = _meals.isEmpty
          ? 'No recipes match your allergies and health profile.'
          : null;
      _activities = [];
      _ai_reasons = {};
    });
    _runStagger();
  }

  Future<void> _generateAiMeals({
    bool force = false,
    Set<String>? exclude_names,
  }) async {
    final prefs = ref.read(mealPreferencesProvider);
    if (prefs.diet_type == null || _generating_plan) return;

    final key = _prefsKey(prefs);
    if (!force && _meals_prefs_key == key && _meals.isNotEmpty) return;
    _meals_prefs_key = key;

    setState(() => _generating_plan = true);

    final bmi = ref.read(bmiProfileProvider);
    final health = ref.read(healthProfileProvider);
    final symptoms = ref.read(selectedSymptomsProvider);
    final analysis = ref.read(symptomAnalysisProvider);
    final exclude_slugs = _plan_exclude_slugs(
      extra_slugs: exclude_names == null
          ? null
          : _meals
              .where((meal) => exclude_names.contains(meal.name))
              .map((meal) => meal.slug ?? '')
              .where((slug) => slug.isNotEmpty)
              .toSet(),
    ).toList();

    final result = await ApiService.generateMealPlan({
      if (bmi.is_calculated) 'bmi': bmi.bmi,
      if (bmi.is_calculated) 'bmi_label': bmiLabelFor(bmi.bmi),
      if ((prefs.gender ?? bmi.gender) != null)
        'gender': prefs.gender ?? bmi.gender,
      'age': bmi.age,
      if (health.sleep_hours != null) 'sleep_hours': health.sleep_hours,
      'symptom_slugs': symptoms.toList(),
      'diet_type': prefs.diet_type,
      'meal_goals': prefs.meal_goals.toList(),
      'activities': prefs.activities.toList(),
      'allergies': health.allergies,
      'conditions': health.conditions,
      if (analysis != null && analysis.food_tips.isNotEmpty)
        'food_tips': analysis.food_tips,
      if (analysis != null && analysis.possible_deficiencies.isNotEmpty)
        'possible_deficiencies': analysis.possible_deficiencies,
      if (exclude_slugs.isNotEmpty) 'exclude_slugs': exclude_slugs,
      'count': 4,
    });

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      final recipes_raw = data['recipes'];
      final recipes = <Recipe>[];
      if (recipes_raw is List) {
        for (final item in recipes_raw) {
          if (item is Map<String, dynamic>) {
            recipes.add(Recipe.fromApiJson(item));
          } else if (item is Map) {
            recipes.add(Recipe.fromApiJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      final reasons_raw = data['reasons'];
      final reasons = <String, String>{};
      if (reasons_raw is Map) {
        reasons_raw.forEach((key, value) {
          reasons[key.toString()] = value.toString();
        });
      }

      final activities_raw = data['activities'];
      final activities = <String>[];
      if (activities_raw is List) {
        for (final item in activities_raw) {
          final text = item.toString().trim();
          if (text.isNotEmpty) activities.add(text);
        }
      }

      if (recipes.isNotEmpty || data['source'] == 'filtered_empty') {
        setState(() {
          _meals = recipes;
          _ai_tip = data['tip']?.toString();
          _activities = activities;
          _ai_reasons = reasons;
          _generating_plan = false;
        });
        if (recipes.isNotEmpty) {
          unawaited(
            ref.read(savedMealPlanProvider.notifier).savePlan(
                  recipes: recipes,
                  tip: data['tip']?.toString(),
                  reasons: reasons,
                  activities: activities,
                ),
          );
        }
        _runStagger();
        return;
      }
    }

    _applyLocalFallback(
      prefs,
      exclude_names: exclude_names,
      allergies: health.allergies,
      conditions: health.conditions,
    );
    setState(() => _generating_plan = false);
  }

  Future<void> _recreateMeals() async {
    final prefs = ref.read(mealPreferencesProvider);
    if (prefs.diet_type == null) return;
    final current_names = _meals.map((meal) => meal.name).toSet();
    await _generateAiMeals(force: true, exclude_names: current_names);
  }

  Future<void> _swapMeal(int index) async {
    if (_generating_plan || _swapping_index != null) return;
    if (index < 0 || index >= _meals.length) return;

    final prefs = ref.read(mealPreferencesProvider);
    if (prefs.diet_type == null) return;

    setState(() => _swapping_index = index);

    final bmi = ref.read(bmiProfileProvider);
    final health = ref.read(healthProfileProvider);
    final symptoms = ref.read(selectedSymptomsProvider);
    final analysis = ref.read(symptomAnalysisProvider);
    final exclude_slugs = _plan_exclude_slugs().toList();

    final result = await ApiService.generateMealPlan({
      if (bmi.is_calculated) 'bmi': bmi.bmi,
      if (bmi.is_calculated) 'bmi_label': bmiLabelFor(bmi.bmi),
      if ((prefs.gender ?? bmi.gender) != null)
        'gender': prefs.gender ?? bmi.gender,
      'age': bmi.age,
      if (health.sleep_hours != null) 'sleep_hours': health.sleep_hours,
      'symptom_slugs': symptoms.toList(),
      'diet_type': prefs.diet_type,
      'meal_goals': prefs.meal_goals.toList(),
      'activities': prefs.activities.toList(),
      'allergies': health.allergies,
      'conditions': health.conditions,
      if (analysis != null && analysis.food_tips.isNotEmpty)
        'food_tips': analysis.food_tips,
      if (analysis != null && analysis.possible_deficiencies.isNotEmpty)
        'possible_deficiencies': analysis.possible_deficiencies,
      'exclude_slugs': exclude_slugs,
      'count': 1,
    });

    if (!mounted) return;

    Recipe? replacement;
    Map<String, String> updated_reasons = Map<String, String>.from(_ai_reasons);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      final recipes_raw = data['recipes'];
      if (recipes_raw is List && recipes_raw.isNotEmpty) {
        final item = recipes_raw.first;
        if (item is Map<String, dynamic>) {
          replacement = Recipe.fromApiJson(item);
        } else if (item is Map) {
          replacement = Recipe.fromApiJson(Map<String, dynamic>.from(item));
        }
      }

      final reasons_raw = data['reasons'];
      if (reasons_raw is Map && replacement?.slug != null) {
        final reason = reasons_raw[replacement!.slug!]?.toString();
        if (reason != null && reason.isNotEmpty) {
          updated_reasons[replacement.slug!] = reason;
        }
      }
    }

    if (replacement == null) {
      final exclude_names = _meals.map((meal) => meal.name).toSet();
      final picks = pickRandomMealsForPreferences(
        diet_type: prefs.diet_type!,
        meal_goals: prefs.meal_goals,
        random: _random,
        exclude_names: exclude_names,
        catalog: _recipeCatalog(),
        allergies: health.allergies,
        conditions: health.conditions,
        count: 1,
      );
      if (picks.isNotEmpty) {
        replacement = picks.first;
      }
    }

    if (!mounted) return;

    if (replacement != null) {
      final old_slug = _meals[index].slug;
      final next_meals = List<Recipe>.from(_meals);
      next_meals[index] = replacement;
      if (old_slug != null) {
        updated_reasons.remove(old_slug);
      }

      setState(() {
        _meals = next_meals;
        _ai_reasons = updated_reasons;
        _swapping_index = null;
      });

      await ref.read(savedMealPlanProvider.notifier).savePlan(
            recipes: next_meals,
            tip: _ai_tip,
            reasons: updated_reasons,
            activities: _activities,
          );
      return;
    }

    if (!mounted) return;
    setState(() => _swapping_index = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not find a replacement meal'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _syncMealsToPreferences(MealPreferencesState prefs) {
    if (prefs.diet_type == null) return;
    final saved = ref.read(savedMealPlanProvider);
    if (_meals.isEmpty && saved.has_recipes) {
      setState(() {
        _meals = saved.recipes;
        _ai_tip = saved.tip;
        _activities = saved.activities;
        _ai_reasons = saved.reasons;
        _meals_prefs_key = _prefsKey(prefs);
      });
      _runStagger();
      return;
    }
    unawaited(_generateAiMeals());
  }

  Future<void> _refreshMealPlan() async {
    final prefs = ref.read(mealPreferencesProvider);
    if (prefs.diet_type == null) return;
    _meals_prefs_key = null;
    await _generateAiMeals(force: true);
  }

  Future<void> _onRefresh() async {
    ref.invalidate(plansDataProvider);
    ref.invalidate(recipesCatalogProvider);
    await Future.wait([
      ref.read(plansDataProvider.future),
      ref.read(recipesCatalogProvider.future),
    ]);
    if (!mounted) return;
    final prefs = ref.read(mealPreferencesProvider);
    if (prefs.has_completed_setup) {
      await _refreshMealPlan();
    }
  }

  Future<void> _handlePreferencesFlow() async {
    final prefs = ref.read(mealPreferencesProvider);
    if (!prefs.is_ready) return;

    if (prefs.has_completed_setup) {
      _syncMealsToPreferences(prefs);
      return;
    }

    final initial_step = prefs.has_selected_diet ? 1 : 0;
    final saved = await showMealPreferencesDialog(
      context,
      initial_step: initial_step,
    );
    if (!mounted || saved != true) return;
    _syncMealsToPreferences(ref.read(mealPreferencesProvider));
  }

  Future<void> _openPreferencesPicker({bool dismissible = true}) async {
    final saved = await showMealPreferencesDialog(
      context,
      barrier_dismissible: dismissible,
    );
    if (!mounted || saved != true) return;
    _syncMealsToPreferences(ref.read(mealPreferencesProvider));
  }

  void _scrollToSection(String section) {
    final key = section == 'bmi'
        ? _bmi_section_key
        : section == 'meals'
            ? _meals_section_key
            : null;
    if (key?.currentContext == null) return;

    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _bmiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _staggerController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final section = GoRouterState.of(context).uri.queryParameters['section'];
    if (section != null && section != _last_scrolled_section) {
      _last_scrolled_section = section;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToSection(section);
      });
    }
  }

  @override
  void dispose() {
    _bmiController.dispose();
    _staggerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BmiProfile>(bmiProfileProvider, (previous, next) {
      if (next.is_calculated &&
          (previous == null ||
              !previous.is_calculated ||
              previous.bmi != next.bmi)) {
        _animateBmiBar(next.bmi);
      }
    });

    ref.listen<MealPreferencesState>(mealPreferencesProvider, (previous, next) {
      if (!next.is_ready || !next.has_completed_setup) return;
      if (previous == null || _prefsKey(previous) != _prefsKey(next)) {
        _syncMealsToPreferences(next);
      }
    });

    ref.listen<int>(mealPlanNeedsRefreshProvider, (previous, next) {
      if (next == _applied_meal_refresh) return;
      _applied_meal_refresh = next;
      final prefs = ref.read(mealPreferencesProvider);
      if (!prefs.has_completed_setup) return;
      unawaited(_generateAiMeals(force: true));
    });

    final pending_refresh = ref.watch(mealPlanNeedsRefreshProvider);
    if (pending_refresh != _applied_meal_refresh) {
      final prefs = ref.read(mealPreferencesProvider);
      if (prefs.has_completed_setup) {
        _applied_meal_refresh = pending_refresh;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_generateAiMeals(force: true));
        });
      }
    }

    final profile = ref.watch(bmiProfileProvider);
    final bmi = profile.display_bmi;

    if (!_initial_bmi_animated) {
      _initial_bmi_animated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animateBmiBar(bmi);
      });
    }

    final plans_async = ref.watch(plansDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: context.app.accent,
          backgroundColor: context.app.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SkeletonAsyncBuilder(
                async_value: plans_async,
                skeleton: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: const PlansListSkeleton(),
                  ),
                ),
                builder: (_) => _buildContent(bmi),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double bmi) {
    final meal_prefs = ref.watch(mealPreferencesProvider);
    final app = context.app;
    final on_surface = context.on_surface;

    if (meal_prefs.is_ready && !_preferences_prompt_scheduled) {
      _preferences_prompt_scheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handlePreferencesFlow();
      });
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 20),
                KeyedSubtree(
                  key: _bmi_section_key,
                  child: _buildBMICard(bmi),
                ),
                const SizedBox(height: 24),
                _buildDaySelector(),
                const SizedBox(height: 24),
                KeyedSubtree(
                  key: _meals_section_key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMealPlanHeader(),
                      if (_generating_plan) ...[
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1DB954),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Building your personalized plan...',
                              style: TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_ai_tip != null && _ai_tip!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          _ai_tip!,
                          style: TextStyle(
                            color: app.text_muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (_activities.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Stay active',
                          style: TextStyle(
                            color: on_surface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._activities.map(
                          (activity) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.directions_walk_outlined,
                                  color: app.accent,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activity,
                                    style: TextStyle(
                                      color: app.text_muted,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildMealCard(_meals[index], index);
                  },
                  childCount: _meals.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildViewAllButton(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
    );
  }

  Widget _buildHeader() {
    final meal_prefs = ref.watch(mealPreferencesProvider);
    final app = context.app;

    return Row(
      children: [
        const Text('🌿', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Breakfast Plans',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (meal_prefs.has_completed_setup)
          GestureDetector(
            onTap: _openPreferencesPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: app.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: app.border),
              ),
              child: const Text('🥣', style: TextStyle(fontSize: 18)),
            ),
          ),
      ],
    );
  }

  Widget _buildMealPlanHeader() {
    final app = context.app;
    return Row(
      children: [
        Expanded(child: _buildSectionTitle('TODAY\'S MEAL PLAN')),
        GestureDetector(
          onTap: _generating_plan ? null : _recreateMeals,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: app.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: app.border),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh, color: app.accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Recreate',
                  style: TextStyle(
                    color: app.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBMICard(double bmi) {
    final bmi_color = bmiColorFor(bmi);
    final bmi_label = bmiLabelFor(bmi);

    final app = context.app;
    final on_surface = Theme.of(context).colorScheme.onSurface;

    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BMI',
                style: TextStyle(
                  color: app.text_muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: bmi_color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bmi_color.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: TextStyle(
                  color: on_surface,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  bmi_label,
                  style: TextStyle(
                    color: bmi_color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _bmiController,
            builder: (context, child) {
              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 25,
                              child: Container(
                                height: 10,
                                color: const Color(0xFF0A84FF),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 25,
                              child: Container(
                                height: 10,
                                color: const Color(0xFF1DB954),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 25,
                              child: Container(
                                height: 10,
                                color: const Color(0xFFFF9500),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 25,
                              child: Container(
                                height: 10,
                                color: const Color(0xFFFF375F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment(
                            (_bmiController.value * 2) - 1,
                            0,
                          ),
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: bmi_color,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: bmi_color.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Expanded(
                        child: Text('Underweight',
                            style: TextStyle(
                                color: Color(0xFF0A84FF),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Text('Normal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF1DB954),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Text('Overweight',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFFF9500),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: Text('Obese',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Color(0xFFFF375F),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final app = context.app;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('YOUR WEEK'),
        const SizedBox(height: 4),
        Text(
          'Same plan all week · highlight your focus day',
          style: TextStyle(color: app.text_muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_days.length, (i) {
              final is_selected = i == _selectedDay;
              final day = _days[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: is_selected
                        ? app.accent.withOpacity(0.12)
                        : app.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: is_selected ? app.accent : app.border,
                      width: is_selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day['food'] as String,
                        style: TextStyle(fontSize: is_selected ? 18 : 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        day['label'] as String,
                        style: TextStyle(
                          color: is_selected ? app.accent : app.text_muted,
                          fontSize: 12,
                          fontWeight: is_selected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(Recipe meal, int index) {
    final delay = index * 0.15;
    final reason = meal.slug == null ? null : _ai_reasons[meal.slug!];
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final progress = Curves.easeOut.transform(
          (((_staggerController.value - delay) / (1 - delay))
              .clamp(0.0, 1.0)),
        );
        return Transform.translate(
          offset: Offset(0, 40 * (1 - progress)),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: _MealCard(
        recipe: meal,
        reason: reason,
        swapping: _swapping_index == index,
        on_swap: () => _swapMeal(index),
        onTap: () => showRecipeSheet(context, meal),
      ),
    );
  }

  Widget _buildViewAllButton() {
    final app = context.app;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PremiumCard(
        on_tap: () => context.go('/recipes'),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View All Meals',
              style: TextStyle(
                color: app.accent,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios, color: app.accent, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return PremiumSectionLabel(title);
  }
}

class _MealCard extends StatefulWidget {
  final Recipe recipe;
  final String? reason;
  final bool swapping;
  final VoidCallback onTap;
  final VoidCallback on_swap;

  const _MealCard({
    required this.recipe,
    required this.onTap,
    required this.on_swap,
    this.reason,
    this.swapping = false,
  });

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final is_dark = Theme.of(context).brightness == Brightness.dark;
    final card_bg = recipe_surface_background(recipe.background_color, is_dark);
    final title_color = recipe_surface_title_color(is_dark);
    final meta_color = recipe_surface_muted_text(is_dark, recipe.accent_color);
  return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _scale = 0.96);
      },
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: card_bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: recipe.accent_color.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: recipe.accent_color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.swapping ? null : widget.on_swap,
                        child: widget.swapping
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF1DB954),
                                ),
                              )
                            : Icon(
                                Icons.swap_horiz,
                                color: recipe.accent_color.withValues(alpha: 0.75),
                                size: 18,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: TextStyle(
                            color: title_color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.reason != null &&
                            widget.reason!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.reason!,
                            style: TextStyle(
                              color: title_color.withValues(alpha: 0.65),
                              fontSize: 10,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: visible_recipe_tags(recipe.tags, limit: 2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: tag.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: tag.color.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                tag.label,
                                style: TextStyle(
                                  color: tag.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: meta_color,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          recipe.time,
                          style: TextStyle(
                            color: meta_color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.local_fire_department,
                        color: meta_color.withValues(alpha: 0.8),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recipe.calories,
                          style: TextStyle(
                            color: meta_color.withValues(alpha: 0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}