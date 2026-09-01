import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? on_tap;
  final Gradient? gradient;
  final Color? border_color;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.on_tap,
    this.gradient,
    this.border_color,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;

    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? app.surface : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border_color ?? app.border.withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.06,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (on_tap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: on_tap,
        borderRadius: BorderRadius.circular(20),
        child: content,
      ),
    );
  }
}

class PremiumSectionLabel extends StatelessWidget {
  final String label;

  const PremiumSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: app.text_muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class PremiumSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color icon_color;
  final String title;
  final String subtitle;
  final VoidCallback on_tap;

  const PremiumSettingsTile({
    super.key,
    required this.icon,
    required this.icon_color,
    required this.title,
    required this.subtitle,
    required this.on_tap,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final on_surface = Theme.of(context).colorScheme.onSurface;

    return PremiumCard(
      on_tap: on_tap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: icon_color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: icon_color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: on_surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: app.text_muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: app.text_muted, size: 22),
        ],
      ),
    );
  }
}
