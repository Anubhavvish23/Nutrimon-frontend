import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../plans/providers/saved_meal_plan_provider.dart';
import '../providers/grocery_checked_provider.dart';
import '../utils/grocery_list_utils.dart';

class GroceryListScreen extends ConsumerStatefulWidget {
  const GroceryListScreen({super.key});

  @override
  ConsumerState<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends ConsumerState<GroceryListScreen> {
  Future<void> _toggle_item(GroceryItem item) async {
    final item_key = grocery_item_key(item.label);
    await ref.read(groceryCheckedProvider.notifier).toggle(item_key);
  }

  Future<void> _copy_list(List<GroceryItem> items) async {
    await Clipboard.setData(ClipboardData(text: grocery_list_text(items)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grocery list copied'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = context.on_surface;
    final checked = ref.watch(groceryCheckedProvider);
    final saved = ref.watch(savedMealPlanProvider);
    final items = build_grocery_list(saved.recipes).map((item) {
      final item_key = grocery_item_key(item.label);
      return GroceryItem(
        label: item.label,
        recipe_names: item.recipe_names,
        checked: checked.contains(item_key),
      );
    }).toList();
    final bought = items.where((item) => item.checked).length;

    return Scaffold(
      backgroundColor: app.scaffold,
      appBar: AppBar(
        backgroundColor: app.scaffold,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: on_surface),
        ),
        title: Text(
          'Grocery List',
          style: TextStyle(fontWeight: FontWeight.w700, color: on_surface),
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              onPressed: () => _copy_list(items),
              icon: Icon(Icons.copy_outlined, color: on_surface),
            ),
        ],
      ),
      body: saved.recipes.isEmpty
          ? Center(
              child: Text(
                'Build a meal plan first',
                style: TextStyle(color: app.text_muted),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Text(
                  '${saved.recipes.length} meals · $bought/${items.length} bought',
                  style: TextStyle(color: app.text_muted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pantry basics like salt, oil, and water are skipped.',
                  style: TextStyle(
                    color: app.text_muted.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: app.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: app.border),
                    ),
                    child: CheckboxListTile(
                      value: item.checked,
                      onChanged: (_) => _toggle_item(item),
                      activeColor: app.accent,
                      checkColor: Colors.white,
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: item.checked ? app.text_muted : on_surface,
                          decoration: item.checked
                              ? TextDecoration.lineThrough
                              : null,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        item.recipe_names.join(' · '),
                        style: TextStyle(
                          color: app.text_muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
