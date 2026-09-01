import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/skeleton/skeleton.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../goals/providers/micro_goals_provider.dart';
import '../../health/providers/health_profile_provider.dart';
import '../../plans/models/recipe.dart';
import '../../plans/providers/meal_preferences_provider.dart';
import '../../plans/widgets/recipe_sheet_content.dart';
import '../../recipes/providers/recipes_catalog_provider.dart';
import '../data/fridge_ingredients.dart';
import '../providers/fridge_last_picks_provider.dart';
import '../utils/fridge_ingredient_search.dart';
import '../utils/fridge_match.dart';

class FridgeRouletteScreen extends ConsumerStatefulWidget {
  const FridgeRouletteScreen({super.key});

  @override
  ConsumerState<FridgeRouletteScreen> createState() =>
      _FridgeRouletteScreenState();
}

class _FridgeRouletteScreenState extends ConsumerState<FridgeRouletteScreen>
    with SingleTickerProviderStateMixin {
  static const int _max_picks = 4;

  final Set<String> _selected = {};
  final TextEditingController _search_controller = TextEditingController();
  String _search_query = '';
  bool _last_picks_applied = false;
  FridgeMatchResult? _result;
  bool _spinning = false;
  String _spin_status = '';

  static const int _max_ai_attempts = 12;
  static const Duration _retry_delay = Duration(milliseconds: 1500);

  late AnimationController _spin_controller;

  @override
  void initState() {
    super.initState();
    _search_controller.addListener(() {
      setState(() => _search_query = _search_controller.text);
    });
    _spin_controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _search_controller.dispose();
    _spin_controller.dispose();
    super.dispose();
  }

  List<FridgeIngredient> get _filtered_ingredients {
    return search_fridge_ingredients(_search_query);
  }

  void _apply_last_picks(List<String> last_picks) {
    if (_last_picks_applied || last_picks.isEmpty || _selected.isNotEmpty) {
      return;
    }
    _last_picks_applied = true;
    setState(() {
      for (final id in last_picks) {
        if (_selected.length >= _max_picks) break;
        if (fridgeIngredientOptions.any((item) => item.id == id)) {
          _selected.add(id);
        }
      }
    });
  }

  void _use_last_picks(List<String> last_picks) {
    HapticFeedback.selectionClick();
    setState(() {
      _selected.clear();
      for (final id in last_picks) {
        if (_selected.length >= _max_picks) break;
        if (fridgeIngredientOptions.any((item) => item.id == id)) {
          _selected.add(id);
        }
      }
      _result = null;
    });
  }

  List<FridgeIngredient> get _selected_items {
    return fridgeIngredientOptions
        .where((item) => _selected.contains(item.id))
        .toList();
  }

  void _toggle_ingredient(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < _max_picks) {
        _selected.add(id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Max 4 ingredients'),
            backgroundColor: Color(0xFFFF9500),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      _result = null;
    });
  }

  void _clear_selection() {
    HapticFeedback.selectionClick();
    setState(() {
      _selected.clear();
      _result = null;
    });
  }

  Future<FridgeMatchResult?> _fetch_ai_match(List<String> selected_labels) async {
    final prefs = ref.read(mealPreferencesProvider);
    final health = ref.read(healthProfileProvider);

    for (var attempt = 1; attempt <= _max_ai_attempts; attempt++) {
      if (!mounted) return null;

      setState(() {
        _spin_status = attempt == 1
            ? 'Finding a recipe for your ingredients…'
            : 'Still searching… attempt $attempt';
      });

      final api_result = await ApiService.spinFridgeRoulette({
        'ingredients': selected_labels,
        if (prefs.diet_type != null) 'diet_type': prefs.diet_type,
        'allergies': health.allergies,
        'conditions': health.conditions,
      });

      if (api_result['success'] == true) {
        final data = api_result['data'] as Map<String, dynamic>? ?? {};
        final parsed = FridgeMatchResult.fromApi(data);
        if (parsed.recipe.name.trim().isNotEmpty) {
          return parsed;
        }
      }

      if (attempt < _max_ai_attempts) {
        await Future<void>.delayed(_retry_delay);
      }
    }

    return null;
  }

  Future<void> _spin(List<Recipe> recipes) async {
    if (_selected.length < 2) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick at least 2 ingredients'),
          backgroundColor: Color(0xFFFF375F),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _spinning = true;
      _result = null;
      _spin_status = 'Finding a recipe for your ingredients…';
    });
    if (!_spin_controller.isAnimating) {
      _spin_controller.repeat();
    }

    final selected_labels = _selected_items.map((item) => item.label).toList();
    final prefs = ref.read(mealPreferencesProvider);

    FridgeMatchResult? match = await _fetch_ai_match(selected_labels);

    if (match == null) {
      match = spinFridgeRoulette(
        recipes: recipes,
        selected_ids: _selected,
        prefer_veg: prefs.is_veg ? true : null,
        random: Random(),
      );
    }

    if (!mounted) return;

    _spin_controller.stop();
    _spin_controller.reset();

    setState(() {
      _spinning = false;
      _spin_status = '';
      _result = match;
    });

    if (match != null) {
      HapticFeedback.lightImpact();
      await ref
          .read(fridgeLastPicksProvider.notifier)
          .save_picks(_selected.toList());
      await ref.read(microGoalsProvider.notifier).recordEvent('fridge_spin');
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No match found — try different ingredients'),
          backgroundColor: Color(0xFFFF9500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog_async = ref.watch(recipesCatalogProvider);
    final last_picks = ref.watch(fridgeLastPicksProvider);
    _apply_last_picks(last_picks);
    final pad = SkeletonResponsive.horizontalPadding(context);
    final filtered = _filtered_ingredients;
    final last_pick_items = fridgeIngredientOptions
        .where((item) => last_picks.contains(item.id))
        .toList();
    final step = _result != null ? 3 : (_selected.length >= 2 ? 2 : 1);
    final app = context.app;
    final on_surface = context.on_surface;

    return Scaffold(
      backgroundColor: app.scaffold,
      body: catalog_async.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: app.accent),
        ),
        error: (_, __) => Center(
          child: Text(
            'Could not load recipes',
            style: TextStyle(color: app.text_muted),
          ),
        ),
        data: (recipes) => SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad - 8, 2, pad, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: on_surface,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Fridge Roulette',
                            style: TextStyle(
                              color: on_surface,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_selected.isNotEmpty)
                          TextButton(
                            onPressed: _clear_selection,
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Color(0xFFFF9500),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: Text(
                      'Pick what is in your fridge and get a real recipe',
                      style: TextStyle(color: app.text_muted, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _StepBar(active_step: step),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _SelectedStrip(
                      selected: _selected_items,
                      max_picks: _max_picks,
                      on_remove: _toggle_ingredient,
                    ),
                  ),
                  if (last_pick_items.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: Row(
                        children: [
                          const Text(
                            'LAST SPIN',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _use_last_picks(last_picks),
                            child: const Text(
                              'Use again',
                              style: TextStyle(
                                color: Color(0xFF1DB954),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: pad),
                        scrollDirection: Axis.horizontal,
                        itemCount: last_pick_items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = last_pick_items[index];
                          final is_on = _selected.contains(item.id);
                          return GestureDetector(
                            onTap: () => _toggle_ingredient(item.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: is_on
                                    ? const Color(0xFF0D3320)
                                    : const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: is_on
                                      ? const Color(0xFF1DB954)
                                      : const Color(0xFF2A2A2A),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(item.emoji),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      color: is_on
                                          ? Colors.white
                                          : const Color(0xFFAAAAAA),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: TextField(
                      controller: _search_controller,
                      style: TextStyle(color: on_surface),
                      decoration: InputDecoration(
                        hintText: 'Search tomato, bread, paneer…',
                        hintStyle: TextStyle(color: app.text_muted),
                        prefixIcon: Icon(
                          Icons.search,
                          color: app.text_muted,
                        ),
                        suffixIcon: _search_query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _search_controller.clear,
                                icon: Icon(
                                  Icons.close,
                                  color: app.text_muted,
                                  size: 18,
                                ),
                              ),
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: Row(
                      children: [
                        const Text(
                          'INGREDIENTS',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selected.length}/$_max_picks selected',
                          style: const TextStyle(
                            color: Color(0xFF1DB954),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: _IngredientGrid(
                        items: filtered,
                        selected: _selected,
                        on_toggle: _toggle_ingredient,
                      ),
                    ),
                  ),
                  if (_result != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 0, pad, 10),
                      child: _ResultCard(
                        result: _result!,
                        on_open: () =>
                            showRecipeSheet(context, _result!.recipe),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(pad, 0, pad, 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _spinning ? null : () => _spin(recipes),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          disabledBackgroundColor: const Color(0xFF0D3320),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _result != null
                              ? 'Spin again'
                              : _spinning
                                  ? 'Finding recipe…'
                                  : 'Find my recipe',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_spinning)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.72),
                    child: Center(
                      child: _SpinOverlay(
                        spin_controller: _spin_controller,
                        items: _selected_items,
                        status: _spin_status,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int active_step;

  const _StepBar({required this.active_step});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Row(
      children: List.generate(3, (index) {
        final step_num = index + 1;
        final is_active = step_num <= active_step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: is_active ? app.accent : app.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 6),
            ],
          ),
        );
      }),
    );
  }
}

class _SelectedStrip extends StatelessWidget {
  final List<FridgeIngredient> selected;
  final int max_picks;
  final ValueChanged<String> on_remove;

  const _SelectedStrip({
    required this.selected,
    required this.max_picks,
    required this.on_remove,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = context.on_surface;
    final is_dark = context.is_dark_mode;
    final selected_bg =
        is_dark ? const Color(0xFF0D3320) : const Color(0xFFE8F8EE);

    if (selected.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: app.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: app.border),
        ),
        child: Text(
          'Tap ingredients below — pick 2 to 4 items',
          style: TextStyle(color: app.text_muted, fontSize: 13),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...selected.map((item) {
          return InputChip(
            label: Text('${item.emoji} ${item.label}'),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => on_remove(item.id),
            backgroundColor: selected_bg,
            deleteIconColor: app.accent,
            labelStyle: TextStyle(
              color: on_surface,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            side: BorderSide(color: app.accent),
          );
        }),
        if (selected.length < max_picks)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: app.border),
            ),
            child: Text(
              '+${max_picks - selected.length} more',
              style: TextStyle(color: app.text_muted, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _IngredientGrid extends StatelessWidget {
  final List<FridgeIngredient> items;
  final Set<String> selected;
  final ValueChanged<String> on_toggle;

  const _IngredientGrid({
    required this.items,
    required this.selected,
    required this.on_toggle,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = context.on_surface;
    final is_dark = context.is_dark_mode;
    final selected_bg =
        is_dark ? const Color(0xFF0D3320) : const Color(0xFFE8F8EE);

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No ingredients match your search',
          style: TextStyle(color: app.text_muted, fontSize: 13),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final is_on = selected.contains(item.id);
        return GestureDetector(
          onTap: () => on_toggle(item.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: is_on ? selected_bg : app.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: is_on ? app.accent : app.border,
                width: is_on ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: is_on ? on_surface : app.text_muted,
                      fontSize: 11,
                      fontWeight: is_on ? FontWeight.w700 : FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpinOverlay extends StatelessWidget {
  final AnimationController spin_controller;
  final List<FridgeIngredient> items;
  final String status;

  const _SpinOverlay({
    required this.spin_controller,
    required this.items,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: app.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app.accent.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: spin_controller,
            child: const Text('🍳', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: items
                .map(
                  (item) => Text(item.emoji, style: const TextStyle(fontSize: 22)),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: app.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final FridgeMatchResult result;
  final VoidCallback on_open;

  const _ResultCard({
    required this.result,
    required this.on_open,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = result.recipe;
    final app = context.app;
    final on_surface = context.on_surface;
    final is_dark = context.is_dark_mode;
    final card_bg =
        is_dark ? const Color(0xFF0D3320) : const Color(0xFFE8F8EE);
    return GestureDetector(
      onTap: on_open,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card_bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: app.accent.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Text(recipe.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR RECIPE',
                    style: TextStyle(
                      color: app.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: on_surface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.matched_labels.join(' · ')} · ${recipe.time}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: app.text_muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: app.accent),
          ],
        ),
      ),
    );
  }
}
