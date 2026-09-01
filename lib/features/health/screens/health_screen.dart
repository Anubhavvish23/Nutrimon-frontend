import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../models/bmi_profile.dart';
import '../models/symptom_catalog_item.dart';
import '../providers/bmi_profile_provider.dart';
import '../providers/health_profile_provider.dart';
import '../providers/selected_symptoms_provider.dart';
import '../providers/symptom_analysis_provider.dart';
import '../providers/symptoms_catalog_provider.dart';
import '../providers/symptom_timeline_provider.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _staggerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ScrollController _scrollController;
  final TextEditingController _custom_symptom_controller =
      TextEditingController();

  int _currentPage = 0;
  final int _perPage = 10;
  bool _analyzing = false;

  List<Map<String, dynamic>> _cardSymptoms(List<SymptomCatalogItem> catalog) {
    return catalog.map((item) => item.toCardMap()).toList();
  }

  List<Map<String, dynamic>> _filteredSymptoms(List<SymptomCatalogItem> catalog) {
    return _cardSymptoms(catalog);
  }

  List<Map<String, dynamic>> _pageSymptoms(List<SymptomCatalogItem> catalog) {
    final filtered = _filteredSymptoms(catalog);
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int _totalPages(List<SymptomCatalogItem> catalog) {
    return (_filteredSymptoms(catalog).length / _perPage).ceil();
  }

  void _runStagger() {
    _staggerController.reset();
    _staggerController.forward();
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedSymptomsProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _staggerController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _custom_symptom_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog_async = ref.watch(symptomsCatalogProvider);
    final selected_symptom_slugs = ref.watch(selectedSymptomsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildTabs(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSymptomsTab(catalog_async),
                  _buildAddCustomTab(),
                  _buildResultsTab(),
                ],
              ),
            ),
            if (selected_symptom_slugs.isNotEmpty)
              _buildAnalyzeButton(selected_symptom_slugs.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final app = context.app;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: app.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: app.border),
          ),
          child: const Center(
            child: Text('💊', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Check',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Select symptoms to find deficiencies',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: app.text_muted,
                      fontSize: 12,
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final app = context.app;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: app.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: app.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: app.accent,
          borderRadius: BorderRadius.circular(11),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: app.text_muted,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Symptoms'),
          Tab(text: 'Custom'),
          Tab(text: 'Results'),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab(AsyncValue<List<SymptomCatalogItem>> catalog_async) {
    return catalog_async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DB954)),
      ),
      error: (error, _) {
        final on_surface = context.on_surface;
        final app = context.app;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, color: app.text_muted, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Could not load symptoms',
                  style: TextStyle(
                    color: on_surface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: app.text_muted, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => ref.invalidate(symptomsCatalogProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
      },
      data: (catalog) => _buildSymptomsGrid(catalog),
    );
  }

  Widget _buildSymptomsGrid(List<SymptomCatalogItem> catalog) {
    final page_items = _pageSymptoms(catalog);

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      interactive: true,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final global_index = _currentPage * _perPage + index;
                  return _buildSymptomCard(
                    page_items[index],
                    global_index,
                    index,
                  );
                },
                childCount: page_items.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPagination(catalog),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCard(
      Map<String, dynamic> symptom, int globalIndex, int localIndex) {
    final slug = symptom['slug'] as String;
    final isSelected = ref.watch(selectedSymptomsProvider).contains(slug);
    final delay = localIndex * 0.08;
    final app = context.app;
    final on_surface = context.on_surface;

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final progress = Curves.easeOut.transform(
          (((_staggerController.value - delay) / (1 - delay))
              .clamp(0.0, 1.0)),
        );
        return Transform.translate(
          offset: Offset(0, 30 * (1 - progress)),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(selectedSymptomsProvider.notifier).toggle(slug);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? (symptom['color'] as Color).withOpacity(0.15)
                : app.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? symptom['color']
                  : app.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (symptom['color'] as Color).withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (symptom['color'] as Color).withOpacity(
                        isSelected ? 0.15 : 0.06),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(symptom['emoji'],
                          style: const TextStyle(fontSize: 28)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? symptom['color']
                              : app.border,
                          border: Border.all(
                            color: isSelected
                                ? symptom['color']
                                : app.text_muted.withValues(alpha: 0.35),
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 12)
                            : null,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom['name'],
                        style: TextStyle(
                          color: on_surface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (symptom['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (symptom['color'] as Color).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          symptom['severity'],
                          style: TextStyle(
                            color: symptom['color'],
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<int?> _paginationItems(List<SymptomCatalogItem> catalog) {
    final total = _totalPages(catalog);
    if (total <= 5) {
      return List.generate(total, (i) => i);
    }

    final items = <int?>[];
    final seen = <int>{};

    void addPage(int page) {
      if (seen.add(page)) {
        items.add(page);
      }
    }

    void addDots() {
      if (items.isEmpty || items.last != null) {
        items.add(null);
      }
    }

    addPage(0);

    if (_currentPage > 2) {
      addDots();
    }

    for (var i = _currentPage - 1; i <= _currentPage + 1; i++) {
      if (i > 0 && i < total - 1) {
        addPage(i);
      }
    }

    if (_currentPage < total - 3) {
      addDots();
    }

    addPage(total - 1);
    return items;
  }

  Widget _buildPagination(List<SymptomCatalogItem> catalog) {
    final app = context.app;
    final on_surface = context.on_surface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _paginationItems(catalog).map((item) {
          if (item == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '...',
                style: TextStyle(
                  color: app.text_muted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final is_active = item == _currentPage;
          return GestureDetector(
            onTap: () {
              setState(() => _currentPage = item);
              _runStagger();
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: is_active ? app.accent : app.surface,
                shape: BoxShape.circle,
                border: is_active ? null : Border.all(color: app.border),
              ),
              child: Text(
                '${item + 1}',
                style: TextStyle(
                  color: is_active ? Colors.white : on_surface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalyzeButton(int selected_count) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: ElevatedButton(
          onPressed: _analyzing
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  await _runAnalysis(
                    slugs: ref.read(selectedSymptomsProvider).toList(),
                  );
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_analyzing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.biotech, size: 18),
              const SizedBox(width: 8),
              Text(
                _analyzing
                    ? 'Analyzing...'
                    : 'Analyze $selected_count Symptom${selected_count > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runAnalysis({
    List<String> slugs = const [],
    String custom_text = '',
  }) async {
    final trimmed_custom = custom_text.trim();
    if (slugs.isEmpty && trimmed_custom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select symptoms or enter a custom one'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _analyzing = true);

    final bmi = ref.read(bmiProfileProvider);
    final health = ref.read(healthProfileProvider);

    final result = await ApiService.analyzeSymptoms({
      'symptom_slugs': slugs,
      'custom_text': trimmed_custom,
      if (bmi.is_calculated) 'bmi': bmi.bmi,
      if (bmi.is_calculated) 'bmi_label': bmiLabelFor(bmi.bmi),
      if (health.sleep_hours != null) 'sleep_hours': health.sleep_hours,
      'allergies': health.allergies,
      'conditions': health.conditions,
    });

    if (!mounted) return;
    setState(() => _analyzing = false);

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']?.toString() ?? 'Analysis failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final data = result['data'] as Map<String, dynamic>? ?? {};
    final analysis = SymptomAnalysisResult.fromApi(
      data,
      analyzed_slugs: slugs,
      custom_text: trimmed_custom,
    );
    ref.read(symptomAnalysisProvider.notifier).state = analysis;
    await ref.read(symptomTimelineProvider.notifier).addFromAnalysis(analysis);

    await ApiService.saveUserProfile({
      'last_symptom_analysis': {
        ...data,
        'analyzed_slugs': slugs,
        'custom_text': trimmed_custom,
      },
    });

    _tabController.animateTo(2);
    await _promptSaveAfterAnalysis(slugs: slugs, custom_text: trimmed_custom);
  }

  Future<void> _promptSaveAfterAnalysis({
    required List<String> slugs,
    required String custom_text,
  }) async {
    final should_save = await showDialog<bool>(
      context: context,
      builder: (dialog_context) {
        final dialog_app = dialog_context.app;
        final dialog_on_surface = dialog_context.on_surface;
        return AlertDialog(
          backgroundColor: dialog_app.surface,
          title: Text(
            'Save these symptoms?',
            style: TextStyle(color: dialog_on_surface),
          ),
          content: Text(
            'Saving links them to your account and can refresh your breakfast plan.',
            style: TextStyle(color: dialog_app.text_muted, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, save'),
            ),
          ],
        );
      },
    );

    if (!mounted || should_save != true) return;

    final existing = ref.read(selectedSymptomsProvider);
    final next_slugs = {...existing, ...slugs}.toList();
    if (custom_text.isNotEmpty && !next_slugs.contains(custom_text)) {
      // custom text is free-form; keep selected catalog slugs only in profile
    }

    ref.read(selectedSymptomsProvider.notifier).replaceAll(next_slugs.toSet());
    await ApiService.saveUserProfile({'symptom_slugs': next_slugs});

    if (!mounted) return;

    ref.read(mealPlanNeedsRefreshProvider.notifier).state++;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal plan updated'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }

  Widget _buildAddCustomTab() {
    final app = context.app;
    final on_surface = context.on_surface;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          'Describe your symptom',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _custom_symptom_controller,
          maxLines: 5,
          style: TextStyle(color: on_surface),
          decoration: InputDecoration(
            hintText: 'e.g. heavy head in the morning, low energy after waking…',
            hintStyle: TextStyle(color: app.text_muted),
            filled: true,
            fillColor: app.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: app.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: app.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _analyzing ||
                  _custom_symptom_controller.text.trim().isEmpty
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  await _runAnalysis(
                    custom_text: _custom_symptom_controller.text,
                  );
                },
          child: Text(_analyzing ? 'Analyzing...' : 'Analyze custom symptom'),
        ),
      ],
    );
  }

  Widget _buildResultsTab() {
    final analysis = ref.watch(symptomAnalysisProvider);
    if (analysis == null || analysis.analysis.isEmpty) {
      return const EmptyStateView(
        emoji: '📊',
        title: 'Your results',
        subtitle: 'Select symptoms and tap Analyze to see insights.',
      );
    }

    final app = context.app;
    final on_surface = context.on_surface;
    final is_dark = context.is_dark_mode;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          'AI analysis',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: app.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: app.border),
          ),
          child: Text(
            analysis.analysis,
            style: TextStyle(
              color: on_surface,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
        if (analysis.meal_suggestions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Meal plan suggestions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Try these breakfasts to help you feel better sooner.',
            style: TextStyle(color: app.text_muted, fontSize: 13, height: 1.35),
          ),
          const SizedBox(height: 12),
          ...analysis.meal_suggestions.map(
            (meal) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: app.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: app.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: TextStyle(
                            color: on_surface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (meal.calories.isNotEmpty || meal.protein.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (meal.calories.isNotEmpty) meal.calories,
                              if (meal.protein.isNotEmpty) meal.protein,
                            ].join(' · '),
                            style: TextStyle(
                              color: app.text_muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          meal.action_text.isNotEmpty
                              ? meal.action_text
                              : 'Resolve it sooner by consuming ${meal.name} this morning.',
                          style: const TextStyle(
                            color: Color(0xFF1DB954),
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (analysis.possible_deficiencies.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'May relate to',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.possible_deficiencies
                .map(
                  (item) => Chip(
                    label: Text(item),
                    backgroundColor: is_dark
                        ? const Color(0xFF12281C)
                        : app.accent.withValues(alpha: 0.12),
                    side: BorderSide(color: app.accent.withValues(alpha: 0.45)),
                    labelStyle: TextStyle(
                      color: app.accent,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        if (analysis.food_tips.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Breakfast tips',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...analysis.food_tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: Color(0xFF1DB954))),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: on_surface.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          analysis.disclaimer.isEmpty
              ? 'Not medical advice. Not a diagnosis.'
              : analysis.disclaimer,
          style: TextStyle(color: app.text_muted, fontSize: 11, height: 1.3),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/health/symptoms-timeline'),
            icon: const Icon(Icons.timeline, size: 18),
            label: const Text('Open symptom timeline'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFBF5AF2),
              side: const BorderSide(color: Color(0xFFBF5AF2)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}