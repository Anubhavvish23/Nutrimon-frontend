import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_brand.dart';
import '../../../core/skeleton/skeleton.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/premium/premium_card.dart';
import '../models/did_you_know_fact.dart';
import '../providers/did_you_know_provider.dart';
import '../providers/home_data_provider.dart';
import '../../plans/providers/saved_meal_plan_provider.dart';
import '../../streak/providers/streak_provider.dart';
import '../../streak/widgets/streak_broken_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentFactIndex = 0;
  bool _showFact = true;
  bool _facts_hidden = false;

  // Animation controllers
  late AnimationController _pulseController;
  Animation<double>? _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Timer? _factTimer;
  int _fact_count = 1;
  bool _streak_sheet_shown = false;

  List<Map<String, dynamic>> _quickActions() {
    final is_dark = Theme.of(context).brightness == Brightness.dark;
    final plan_sub = homePlanLabelForHour(DateTime.now().hour);
    if (is_dark) {
      return [
        {
          'icon': Icons.favorite_outline,
          'label': 'Health Check',
          'sub': 'Get personalized plan',
          'color': const Color(0xFF1DB954),
          'bg': const Color(0xFF0D3320),
          'circle1': const Color(0xFF1DB954),
          'circle2': const Color(0xFF0A8C3A),
          'label_color': Colors.white,
        },
        {
          'icon': Icons.restaurant_outlined,
          'label': "Today's Plan",
          'sub': plan_sub,
          'color': const Color(0xFFFF9500),
          'bg': const Color(0xFF332200),
          'circle1': const Color(0xFFFF9500),
          'circle2': const Color(0xFFCC7000),
          'label_color': Colors.white,
        },
        {
          'icon': Icons.monitor_heart_outlined,
          'label': 'Symptoms',
          'sub': 'Track how you feel',
          'color': const Color(0xFFBF5AF2),
          'bg': const Color(0xFF2A1040),
          'circle1': const Color(0xFFBF5AF2),
          'circle2': const Color(0xFF8A2BE2),
          'label_color': Colors.white,
        },
        {
          'icon': Icons.menu_book_outlined,
          'label': 'Recipes',
          'sub': 'Explore meals',
          'color': const Color(0xFF0A84FF),
          'bg': const Color(0xFF001833),
          'circle1': const Color(0xFF0A84FF),
          'circle2': const Color(0xFF0055CC),
          'label_color': Colors.white,
        },
      ];
    }
    return [
      {
        'icon': Icons.favorite_outline,
        'label': 'Health Check',
        'sub': 'Get personalized plan',
        'color': const Color(0xFF1DB954),
        'bg': const Color(0xFFE8F8EE),
        'circle1': const Color(0xFF1DB954),
        'circle2': const Color(0xFF0A8C3A),
        'label_color': const Color(0xFF1A3A2A),
      },
      {
        'icon': Icons.restaurant_outlined,
        'label': "Today's Plan",
        'sub': plan_sub,
        'color': const Color(0xFFE08600),
        'bg': const Color(0xFFFFF4E6),
        'circle1': const Color(0xFFFF9500),
        'circle2': const Color(0xFFCC7000),
        'label_color': const Color(0xFF3A2A10),
      },
      {
        'icon': Icons.monitor_heart_outlined,
        'label': 'Symptoms',
        'sub': 'Track how you feel',
        'color': const Color(0xFF9A4FD4),
        'bg': const Color(0xFFF3EBFF),
        'circle1': const Color(0xFFBF5AF2),
        'circle2': const Color(0xFF8A2BE2),
        'label_color': const Color(0xFF2A1A3A),
      },
      {
        'icon': Icons.menu_book_outlined,
        'label': 'Recipes',
        'sub': 'Explore meals',
        'color': const Color(0xFF0070E0),
        'bg': const Color(0xFFE8F4FF),
        'circle1': const Color(0xFF0A84FF),
        'circle2': const Color(0xFF0055CC),
        'label_color': const Color(0xFF1A2A3A),
      },
    ];
  }

  @override
  void initState() {
    super.initState();

    // Pulse animation for fire emoji
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide animation for recommendations
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start slide animation after build
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });

    // Auto slide banner every 4 seconds
    _factTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() {
        _showFact = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _currentFactIndex = (_currentFactIndex + 1) % _fact_count;
          _showFact = true;
        });
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybe_show_streak_broken());
  }

  Future<void> _maybe_show_streak_broken() async {
    if (!mounted || _streak_sheet_shown) return;
    final streak = ref.read(streakProvider);
    if (!streak.streak_just_broken || streak.broken_from_streak <= 0) return;
    _streak_sheet_shown = true;
    await showStreakBrokenSheet(
      context,
      previous_streak: streak.broken_from_streak,
    );
    if (!mounted) return;
    await ref.read(streakProvider.notifier).acknowledgeStreakBroken();
    _streak_sheet_shown = false;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _factTimer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
  }

  Future<void> _onRefresh() async {
    ref.invalidate(homeDataProvider);
    ref.invalidate(didYouKnowFactsProvider);
    await Future.wait([
      ref.read(homeDataProvider.future),
      ref.read(didYouKnowFactsProvider.future),
    ]);
    if (!mounted) return;
    setState(() {
      _currentFactIndex = (_currentFactIndex + 1) % _fact_count;
      _showFact = true;
    });
    _slideController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(streakProvider, (previous, next) {
      if (next.streak_just_broken &&
          next.broken_from_streak > 0 &&
          (previous == null || !previous.streak_just_broken)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybe_show_streak_broken());
      }
    });

    final home_async = ref.watch(homeDataProvider);
    final facts_async = ref.watch(didYouKnowFactsProvider);
    final facts = facts_async.value ?? const <DidYouKnowFact>[];
    if (facts.isNotEmpty) {
      _fact_count = facts.length;
      if (_currentFactIndex >= _fact_count) {
        _currentFactIndex = 0;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AmbientBackground(
        child: SafeArea(
          child: home_async.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const HomeDashboardSkeleton(),
            error: (_, __) => RefreshIndicator(
              onRefresh: _onRefresh,
              color: context.app.accent,
              backgroundColor: context.app.surface,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.65,
                    child: Center(
                      child: Text(
                        'Could not load your dashboard',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            data: (_) => RefreshIndicator(
              onRefresh: _onRefresh,
              color: context.app.accent,
              backgroundColor: context.app.surface,
              child: _buildContent(facts_async),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AsyncValue<List<DidYouKnowFact>> facts_async) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          if (!_facts_hidden) ...[
            const SizedBox(height: 24),
            _buildDidYouKnowSection(facts_async),
          ],
          const SizedBox(height: 20),
          _buildStreakCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('PLAY & TRACK'),
          const SizedBox(height: 14),
          _buildPlayTrackRow(),
          const SizedBox(height: 24),
          _buildSectionTitle('QUICK ACTIONS'),
          const SizedBox(height: 14),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildSectionTitle('RECOMMENDED FOR YOU'),
          const SizedBox(height: 14),
          _buildRecommendations(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPlayTrackRow() {
    final cards = [
      {
        'emoji': '🧊',
        'title': 'Fridge',
        'sub': 'Roulette',
        'route': '/fridge-roulette',
        'color': const Color(0xFFFF9500),
      },
      {
        'emoji': '🛒',
        'title': 'Grocery',
        'sub': 'List',
        'route': '/grocery-list',
        'color': const Color(0xFF1DB954),
      },
      {
        'emoji': '🎯',
        'title': 'Micro',
        'sub': 'Goals',
        'route': '/micro-goals',
        'color': const Color(0xFF0A84FF),
      },
    ];

    return Row(
      children: cards.map((card) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: card == cards.last ? 0 : 10,
            ),
            child: PremiumCard(
              on_tap: () => context.push(card['route'] as String),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              border_color: (card['color'] as Color).withOpacity(0.35),
              child: Column(
                children: [
                  Text(
                    card['emoji'] as String,
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['title'] as String,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    card['sub'] as String,
                    style: TextStyle(
                      color: card['color'] as Color,
                      fontSize: 12,
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
  }

  Widget _buildHeader() {
    final text_theme = Theme.of(context).textTheme;
    final app = context.app;
    final home = ref.watch(homeDataProvider).value;
    final hour = DateTime.now().hour;
    final greeting = home?.greeting ?? _getGreeting();
    final subtitle = homeSubtitleForHour(hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppLogo(size: 28),
            const SizedBox(width: 8),
            Text(
              AppBrand.name,
              style: TextStyle(
                color: app.text_muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(greeting, style: text_theme.headlineMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: text_theme.bodyMedium),
      ],
    );
  }
  Widget _buildDidYouKnowSection(AsyncValue<List<DidYouKnowFact>> facts_async) {
    return facts_async.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DB954)),
        ),
      ),
      error: (error, _) => PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DID YOU KNOW?',
              style: TextStyle(
                color: context.app.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tips are taking a short break. Pull down to refresh.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () => ref.invalidate(didYouKnowFactsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (facts) {
        if (facts.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildDidYouKnow(facts);
      },
    );
  }

  Widget _buildDidYouKnow(List<DidYouKnowFact> facts) {
    final banner_facts = facts.map((f) => f.toBannerMap()).toList();
    final fact = banner_facts[_currentFactIndex];
    final api_colors = (fact['colors'] as List?)?.cast<Color>();
    final colors = context.fact_banner_gradient(api_colors);
    final accent = fact['accent'] as Color? ?? context.app.accent;
    final fact_text = context.fact_banner_text;
    final fact_muted = context.fact_banner_muted;
    final dot_inactive = context.fact_dot_inactive;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: Container(
        key: ValueKey(_currentFactIndex),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'DID YOU KNOW?',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _facts_hidden = true),
                  child: Icon(Icons.close, color: accent.withOpacity(0.7), size: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fact['icon']!, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fact['fact']!,
                    style: TextStyle(
                      color: fact_text,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentFactIndex = (_currentFactIndex - 1 +
                              banner_facts.length) %
                          banner_facts.length;
                    });
                  },
                  child: Icon(Icons.chevron_left, color: fact_muted),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(
                    banner_facts.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _currentFactIndex ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _currentFactIndex
                            ? accent
                            : dot_inactive,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentFactIndex =
                          (_currentFactIndex + 1) % banner_facts.length;
                    });
                  },
                  child: Icon(Icons.chevron_right, color: fact_muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    final streak = ref.watch(streakProvider);
    final streak_count = streak.current_streak;
    final subtitle = streak_count == 0
        ? 'Complete a meal today to start your streak!'
        : streak.logged_today
            ? 'Great job — come back tomorrow to hit ${streak_count + 1}!'
            : 'Complete a meal today to keep your streak going';

    return PremiumCard(
      gradient: LinearGradient(
        colors: context.streak_card_gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border_color: context.streak_card_border,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ScaleTransition(
              scale: _pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '$streak_count',
                      style: const TextStyle(
                        color: Color(0xFFFF9500),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'day streak',
                      style: TextStyle(
                        color: context.streak_label_text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.app.text_muted,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return PremiumSectionLabel(title);
  }

  void _onQuickActionTap(BuildContext context, String label) {
    switch (label) {
      case 'Health Check':
        context.go('/health-check');
        break;
      case "Today's Plan":
        context.go('/plans?section=meals');
        break;
      case 'Symptoms':
        context.go('/health');
        break;
      case 'Recipes':
        context.go('/recipes');
        break;
    }
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: _quickActions().map((action) {
        return _AnimatedActionCard(
          action: action,
          onTap: () => _onQuickActionTap(context, action['label'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendations() {
    final saved = ref.watch(savedMealPlanProvider);
    final hour = DateTime.now().hour;
    final plan_cta = hour < 11
        ? 'Build your breakfast plan'
        : hour < 16
            ? 'Build your lunch plan'
            : hour < 21
                ? 'Build your dinner plan'
                : 'Plan tomorrow\'s meals';
    final recommendations = saved.has_recipes
        ? saved.recipes.take(3).map((recipe) {
            return {
              'tag': "TODAY'S PLAN",
              'title': recipe.name,
              'time': recipe.time,
              'cal': recipe.calories,
              'emoji': recipe.emoji,
              'color': recipe.accent_color,
            };
          }).toList()
        : [
            {
              'tag': 'GET STARTED',
              'title': plan_cta,
              'time': '2 min',
              'cal': 'Open Plans',
              'emoji': '🌿',
              'color': const Color(0xFF1DB954),
            },
          ];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Column(
          children: recommendations.map((rec) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PremiumCard(
                on_tap: () => context.go('/plans?section=meals'),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec['tag'] as String,
                            style: TextStyle(
                              color: rec['color'] as Color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rec['title'] as String,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: context.app.text_muted, size: 14),
                              const SizedBox(width: 4),
                              Text(rec['time'] as String,
                                  style: TextStyle(
                                      color: context.app.text_muted,
                                      fontSize: 13)),
                              const SizedBox(width: 12),
                              Icon(Icons.local_fire_department,
                                  color: context.app.text_muted, size: 14),
                              const SizedBox(width: 4),
                              Text(rec['cal'] as String,
                                  style: TextStyle(
                                      color: context.app.text_muted,
                                      fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'View recipe',
                                style: TextStyle(
                                  color: rec['color'] as Color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  color: rec['color'] as Color, size: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(rec['emoji'] as String,
                        style: const TextStyle(fontSize: 48)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

// Separate widget for animated action card with circles
class _AnimatedActionCard extends StatefulWidget {
  final Map<String, dynamic> action;
  final VoidCallback onTap;

  const _AnimatedActionCard({
    required this.action,
    required this.onTap,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final label_color =
        action['label_color'] as Color? ?? context.on_surface;
    final sub_color = context.app.text_muted;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: action['bg'],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (action['color'] as Color).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (action['circle1'] as Color).withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (action['circle2'] as Color).withOpacity(0.1),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(action['icon'], color: action['color'], size: 28),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['label'],
                        style: TextStyle(
                          color: label_color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        action['sub'],
                        style: TextStyle(
                          color: sub_color,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}