import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/recipe_surface_colors.dart';
import '../../../core/widgets/half_screen_sheet.dart';
import '../models/recipe.dart';
import '../../recipes/utils/recipe_tag_utils.dart';

class RecipeSheetContent extends StatelessWidget {
  final Recipe recipe;

  const RecipeSheetContent({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = context.on_surface;
    final is_dark = context.is_dark_mode;
    final card_bg = recipe_surface_background(recipe.background_color, is_dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: card_bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: recipe.accent_color.withValues(alpha: 0.4),
                ),
              ),
              alignment: Alignment.center,
              child: Text(recipe.emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(
                      color: on_surface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: visible_recipe_tags(recipe.tags)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _statChip(context, Icons.access_time, recipe.time),
            const SizedBox(width: 10),
            _statChip(context, Icons.local_fire_department, recipe.calories),
            const SizedBox(width: 10),
            _statChip(context, Icons.fitness_center, recipe.protein),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          recipe.description,
          style: TextStyle(
            color: app.text_muted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        _sectionTitle(context, 'INGREDIENTS'),
        const SizedBox(height: 12),
        ...recipe.ingredients.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: recipe.accent_color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: on_surface,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle(context, 'STEPS'),
        const SizedBox(height: 12),
        ...List.generate(
          recipe.steps.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: recipe.accent_color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: recipe.accent_color.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: recipe.accent_color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recipe.steps[index],
                    style: TextStyle(
                      color: on_surface.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialog_context) {
                  return AlertDialog(
                    backgroundColor: app.surface,
                    title: Text(
                      'Start meal timer?',
                      style: TextStyle(
                        color: on_surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'Start cooking ${recipe.name} now? The timer will begin as soon as you confirm.',
                      style: TextStyle(color: app.text_muted, height: 1.4),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialog_context).pop(false),
                        child: const Text('Not yet'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialog_context).pop(true),
                        child: const Text('Start timer'),
                      ),
                    ],
                  );
                },
              );
              if (confirmed != true || !context.mounted) return;
              Navigator.of(context).pop();
              context.push('/meal-timer', extra: recipe);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: recipe.accent_color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Start meal now',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.app.text_muted,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String label) {
    final app = context.app;
    final on_surface = context.on_surface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: app.surface_elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: app.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: app.text_muted, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: on_surface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

void showRecipeSheet(BuildContext context, Recipe recipe) {
  final app = context.app;
  HalfScreenSheet.show(
    context: context,
    height_factor: 0.7,
    background_color: app.surface,
    child: RecipeSheetContent(recipe: recipe),
  );
}

