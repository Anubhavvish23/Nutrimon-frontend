import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color scaffold;
  final Color surface;
  final Color surface_elevated;
  final Color border;
  final Color text_muted;
  final Color accent;
  final Color nav_bar;
  final Color glow;

  const AppThemeExtension({
    required this.scaffold,
    required this.surface,
    required this.surface_elevated,
    required this.border,
    required this.text_muted,
    required this.accent,
    required this.nav_bar,
    required this.glow,
  });

  static const dark = AppThemeExtension(
    scaffold: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    surface_elevated: Color(0xFF1C1C1C),
    border: Color(0xFF2A2A2A),
    text_muted: Color(0xFF8A8A8A),
    accent: Color(0xFF1DB954),
    nav_bar: Color(0xF0141414),
    glow: Color(0x331DB954),
  );

  static const light = AppThemeExtension(
    scaffold: Color(0xFFF2F2F7),
    surface: Colors.white,
    surface_elevated: Color(0xFFF8F8FA),
    border: Color(0xFFE5E5EA),
    text_muted: Color(0xFF6C6C70),
    accent: Color(0xFF1DB954),
    nav_bar: Color(0xF5FFFFFF),
    glow: Color(0x221DB954),
  );

  @override
  AppThemeExtension copyWith({
    Color? scaffold,
    Color? surface,
    Color? surface_elevated,
    Color? border,
    Color? text_muted,
    Color? accent,
    Color? nav_bar,
    Color? glow,
  }) {
    return AppThemeExtension(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surface_elevated: surface_elevated ?? this.surface_elevated,
      border: border ?? this.border,
      text_muted: text_muted ?? this.text_muted,
      accent: accent ?? this.accent,
      nav_bar: nav_bar ?? this.nav_bar,
      glow: glow ?? this.glow,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface_elevated:
          Color.lerp(surface_elevated, other.surface_elevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      text_muted: Color.lerp(text_muted, other.text_muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      nav_bar: Color.lerp(nav_bar, other.nav_bar, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get app =>
      Theme.of(this).extension<AppThemeExtension>()!;

  bool get is_dark_mode => Theme.of(this).brightness == Brightness.dark;

  Color get on_surface => Theme.of(this).colorScheme.onSurface;

  List<Color> fact_banner_gradient(List<Color>? from_api) {
    if (is_dark_mode) {
      return from_api ??
          [const Color(0xFF1A3A1A), const Color(0xFF0D2010)];
    }
    return [const Color(0xFFE8F8EE), const Color(0xFFCDEFDC)];
  }

  Color get fact_banner_text =>
      is_dark_mode ? Colors.white : const Color(0xFF1A3A2A);

  Color get fact_banner_muted =>
      is_dark_mode ? const Color(0xFF888888) : const Color(0xFF6C8A74);

  Color get fact_dot_inactive =>
      is_dark_mode ? const Color(0xFF333333) : const Color(0xFFB8D4C4);

  List<Color> get streak_card_gradient => is_dark_mode
      ? [const Color(0xFF3A1A00), const Color(0xFF1F0D00)]
      : [const Color(0xFFFFF4E8), const Color(0xFFFFE8CC)];

  Color get streak_card_border =>
      is_dark_mode ? const Color(0xFF5A2D00) : const Color(0xFFFFD4A8);

  Color get streak_label_text =>
      is_dark_mode ? Colors.white : const Color(0xFF3A2A1A);
}
