import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  static const List<Map<String, dynamic>> items = [
    {'icon': Icons.home_outlined, 'label': 'Home', 'route': '/home'},
    {'icon': Icons.restaurant_menu_outlined, 'label': 'Plans', 'route': '/plans'},
    {'icon': Icons.favorite_outline, 'label': 'Health', 'route': '/health'},
    {'icon': Icons.menu_book_outlined, 'label': 'Recipes', 'route': '/recipes'},
    {'icon': Icons.person_outline, 'label': 'Profile', 'route': '/profile'},
  ];

  static int selectedIndexForLocation(String location) {
    if (location.startsWith('/bmi') ||
        location.startsWith('/health-check') ||
        location.startsWith('/health/sleep') ||
        location.startsWith('/health/allergies') ||
        location.startsWith('/health/symptoms-timeline')) {
      return 2;
    }
    if (location.startsWith('/fridge-roulette')) {
      return 3;
    }
    if (location.startsWith('/micro-goals')) {
      return 0;
    }
    for (var i = 0; i < items.length; i++) {
      final route = items[i]['route'] as String;
      if (location.startsWith(route)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final current_index = selectedIndexForLocation(
      GoRouterState.of(context).matchedLocation,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF222222))),
      ),
      child: BottomNavigationBar(
        currentIndex: current_index,
        onTap: (index) {
          final route = items[index]['route'] as String;
          if (GoRouterState.of(context).matchedLocation != route) {
            context.go(route);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1DB954),
        unselectedItemColor: const Color(0xFF555555),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: items
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item['icon'] as IconData),
                label: item['label'] as String,
              ),
            )
            .toList(),
      ),
    );
  }
}
