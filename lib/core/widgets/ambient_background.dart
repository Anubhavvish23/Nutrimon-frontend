import 'package:flutter/material.dart';
import '../theme/app_theme_extension.dart';

class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final is_dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: app.scaffold,
            gradient: RadialGradient(
              center: const Alignment(0.85, -0.6),
              radius: 1.1,
              colors: [
                app.glow,
                app.scaffold,
              ],
            ),
          ),
        ),
        if (is_dark)
          Positioned(
            left: -80,
            bottom: 120,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1DB954).withOpacity(0.04),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
