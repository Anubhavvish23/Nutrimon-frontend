import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../plans/models/recipe.dart';
import '../../plans/widgets/recipe_sheet_content.dart';
import '../data/recipe_catalog.dart';
import '../providers/favorites_provider.dart';
import '../providers/recipes_catalog_provider.dart';
import '../utils/recipe_card_mapper.dart';
import '../utils/recipe_tag_utils.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  final bool initial_favorites;

  const RecipesScreen({
    super.key,
    this.initial_favorites = false,
  });

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final TextEditingController _search_controller = TextEditingController();

  String _searchQuery = '';
  bool _showFavorites = false;
  int _currentPage = 0;
  final int _perPage = 10;

  List<Map<String, dynamic>> _cardRecipesFrom(List<Recipe> catalog) {
    return catalog.map(recipeToCardMap).toList();
  }

  List<Map<String, dynamic>> _displayedRecipes(List<Map<String, dynamic>> card_recipes) {
    var list = card_recipes.asMap().entries.toList();
    final favorites = ref.read(favoritesProvider);

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((e) => e.value['name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_showFavorites) {
      list = list.where((e) {
        final slug = e.value['slug']?.toString() ?? '';
        final name = e.value['name']?.toString() ?? '';
        return favorites.contains(slug) || favorites.contains(name);
      }).toList();
    }

    return list.map((e) => {...e.value, '_originalIndex': e.key}).toList();
  }

  List<Map<String, dynamic>> _pageRecipes(List<Map<String, dynamic>> card_recipes) {
    final displayed = _displayedRecipes(card_recipes);
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, displayed.length);
    if (start >= displayed.length) return [];
    return displayed.sublist(start, end);
  }

  int _totalPages(List<Map<String, dynamic>> card_recipes) {
    return (_displayedRecipes(card_recipes).length / _perPage).ceil();
  }

  void _runStagger() {
    _staggerController.reset();
    _staggerController.forward();
  }

  @override
  void initState() {
    super.initState();
    _showFavorites = widget.initial_favorites;
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _search_controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search_controller.clear();
    setState(() {
      _searchQuery = '';
      _currentPage = 0;
    });
    _runStagger();
  }

  void _clearFilters() {
    _search_controller.clear();
    setState(() {
      _searchQuery = '';
      _showFavorites = false;
      _currentPage = 0;
    });
    _runStagger();
  }

  Widget _buildCatalogError(Object error) {
    final app = context.app;
    final on_surface = context.on_surface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: app.text_muted, size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load recipes',
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
              onPressed: () => ref.invalidate(recipesCatalogProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog_async = ref.watch(recipesCatalogProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: catalog_async.when(
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                  ],
                ),
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1DB954)),
                ),
              ),
            ],
          ),
          error: (error, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildHeader(),
              ),
              Expanded(child: _buildCatalogError(error)),
            ],
          ),
          data: (catalog) {
            ref.watch(favoritesProvider);
            final card_recipes = _cardRecipesFrom(catalog);
            final displayed = _displayedRecipes(card_recipes);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: displayed.isEmpty
                      ? _buildEmpty()
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.64,
                                  ),
                                itemCount: _pageRecipes(card_recipes).length,
                                itemBuilder: (context, index) {
                                  final recipe = _pageRecipes(card_recipes)[index];
                                  final original_index =
                                      recipe['_originalIndex'] as int;
                                  return _buildRecipeCard(
                                    recipe,
                                    original_index,
                                    index,
                                    catalog,
                                  );
                                },
                              ),
                            ),
                            if (_totalPages(card_recipes) > 1)
                              _buildPagination(card_recipes),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final app = context.app;
    final on_surface = context.on_surface;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: app.surface_elevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: app.border),
          ),
          child: const Center(
            child: Text('🍳', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recipes',
                style: TextStyle(
                  color: on_surface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Discover healthy breakfast recipes',
                style: TextStyle(color: app.text_muted, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Fridge Roulette',
          onPressed: () => context.push('/fridge-roulette'),
          icon: const Icon(Icons.kitchen_outlined, color: Color(0xFFFF9500)),
        ),
        IconButton(
          tooltip: _showFavorites ? 'Show all recipes' : 'Show favorites',
          onPressed: () {
            setState(() {
              _showFavorites = !_showFavorites;
              _currentPage = 0;
            });
            _runStagger();
          },
          style: IconButton.styleFrom(
            backgroundColor: _showFavorites
                ? const Color(0xFFFF375F).withValues(alpha: 0.15)
                : app.surface_elevated,
            side: BorderSide(
              color: _showFavorites
                  ? const Color(0xFFFF375F)
                  : app.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            _showFavorites ? Icons.favorite : Icons.favorite_border,
            color: _showFavorites
                ? const Color(0xFFFF375F)
                : app.text_muted,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final has_query = _searchQuery.isNotEmpty;
    final app = context.app;

    return TextField(
      controller: _search_controller,
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
          _currentPage = 0;
        });
        _runStagger();
      },
      style: TextStyle(color: context.on_surface),
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        hintStyle: TextStyle(color: app.text_muted),
        prefixIcon: Icon(Icons.search, color: app.text_muted),
        suffixIcon: has_query
            ? IconButton(
                icon: Icon(Icons.close, color: app.text_muted),
                onPressed: _clearSearch,
                tooltip: 'Clear search',
              )
            : null,
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
          borderSide: const BorderSide(color: Color(0xFF1DB954), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildRecipeCard(
    Map<String, dynamic> recipe,
    int originalIndex,
    int localIndex,
    List<Recipe> catalog,
  ) {
    final recipe_name = recipe['name'] as String;
    final recipe_slug = recipe['slug']?.toString() ?? recipe_name;
    final favorites = ref.watch(favoritesProvider);
    final isFav =
        favorites.contains(recipe_slug) || favorites.contains(recipe_name);
    final delay = (localIndex * 0.08).clamp(0.0, 0.7);

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
      child: _RecipeCard(
        recipe: recipe,
        isFavorite: isFav,
        onFavToggle: () {
          ref.read(favoritesProvider.notifier).toggle(recipe_slug);
        },
        onTap: () => showRecipeSheet(
          context,
          recipeFromCardMap(recipe, catalog: catalog),
        ),
      ),
    );
  }

  Widget _buildPagination(List<Map<String, dynamic>> card_recipes) {
    final app = context.app;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages(card_recipes), (i) {
          final isActive = i == _currentPage;
          return GestureDetector(
            onTap: () {
              setState(() => _currentPage = i);
              _runStagger();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 32 : 28,
              height: isActive ? 32 : 28,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1DB954)
                    : app.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF1DB954)
                      : app.border,
                ),
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : app.text_muted,
                    fontSize: isActive ? 13 : 11,
                    fontWeight: isActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    final has_search = _searchQuery.trim().isNotEmpty;
    final query = _searchQuery.trim();

    if (_showFavorites && has_search) {
      return EmptyStateView(
        emoji: '💔',
        title: 'No matching favorites',
        subtitle:
            'Nothing saved matches "$query". Clear search or browse all recipes.',
        action_label: 'Clear search',
        on_action: _clearSearch,
        secondary_action_label: 'Show all recipes',
        on_secondary_action: _clearFilters,
      );
    }

    if (_showFavorites) {
      return EmptyStateView(
        emoji: '💔',
        title: 'No favorites yet',
        subtitle: 'Tap the heart on any recipe to save it here for quick access.',
        action_label: 'Browse recipes',
        on_action: () {
          setState(() => _showFavorites = false);
          _runStagger();
        },
      );
    }

    if (has_search) {
      return EmptyStateView(
        emoji: '🔍',
        title: 'No recipes found',
        subtitle:
            'We could not find anything for "$query". Try another name or ingredient.',
        action_label: 'Clear search',
        on_action: _clearSearch,
      );
    }

    return const EmptyStateView(
      emoji: '🥣',
      title: 'No recipes here',
      subtitle: 'Something went wrong loading the catalog. Pull to refresh later.',
    );
  }
}

// Separate stateful widget for recipe card
class _RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool isFavorite;
  final VoidCallback onFavToggle;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.isFavorite,
    required this.onFavToggle,
    required this.onTap,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final app = context.app;
    final is_dark = context.is_dark_mode;
    final card_bg = is_dark
        ? recipe['bg'] as Color
        : Color.lerp(recipe['bg'] as Color, Colors.white, 0.55)!;
    final title_color = is_dark ? Colors.white : const Color(0xFF1A1A1A);
    final meta_color = is_dark ? const Color(0xFF888888) : app.text_muted;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: card_bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (recipe['border'] as Color).withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: (recipe['border'] as Color).withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -12,
                top: -12,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (recipe['circle'] as Color).withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                left: -10,
                bottom: 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (recipe['circle'] as Color).withOpacity(0.07),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(recipe['emoji'],
                          style: const TextStyle(fontSize: 28)),
                      GestureDetector(
                        onTap: widget.onFavToggle,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(widget.isFavorite),
                              color: widget.isFavorite
                                  ? const Color(0xFFFF375F)
                                  : const Color(0xFF555555),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe['name'],
                    style: TextStyle(
                      color: title_color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            (recipe['tags'] as List<Map<String, dynamic>>)
                                .take(2)
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (tag['color'] as Color)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: (tag['color'] as Color)
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        tag['label'],
                                        style: TextStyle(
                                          color: tag['color'],
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ))
                                .toList(),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          color: meta_color, size: 10),
                      const SizedBox(width: 2),
                      Text(recipe['cal'],
                          style: TextStyle(color: meta_color, fontSize: 9)),
                      const SizedBox(width: 6),
                      Icon(Icons.access_time, color: meta_color, size: 10),
                      const SizedBox(width: 2),
                      Text(recipe['time'],
                          style: TextStyle(color: meta_color, fontSize: 9)),
                      const SizedBox(width: 6),
                      Icon(
                        (recipe['is_veg'] as bool? ?? true)
                            ? Icons.eco_outlined
                            : Icons.set_meal_outlined,
                        color: (recipe['is_veg'] as bool? ?? true)
                            ? const Color(0xFF1DB954)
                            : const Color(0xFFFF6B6B),
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.fitness_center, color: meta_color, size: 10),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          recipe['protein'],
                          style: TextStyle(color: meta_color, fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: is_dark
                          ? Colors.black26
                          : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            (recipe['border'] as Color).withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Recipe',
                          style: TextStyle(
                            color: recipe['border'],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios,
                            color: recipe['border'] as Color, size: 10),
                      ],
                    ),
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


