import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme_extension.dart';
import '../app_bottom_nav.dart';

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final location = GoRouterState.of(context).matchedLocation;
    final current_index = AppBottomNav.selectedIndexForLocation(location);
    final bottom_pad = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 8 + bottom_pad),
      decoration: BoxDecoration(
        color: app.nav_bar,
        border: Border(top: BorderSide(color: app.border.withOpacity(0.6))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(AppBottomNav.items.length, (index) {
          final item = AppBottomNav.items[index];
          final selected = index == current_index;
          final route = item['route'] as String;
          final icon = item['icon'] as IconData;
          final label = item['label'] as String;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (location != route) context.go(route);
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? app.accent.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: selected ? app.accent : app.text_muted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? app.accent : app.text_muted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
