import 'package:flutter/material.dart';

Color recipe_surface_background(Color base, bool is_dark) {
  if (is_dark) return base;
  return Color.lerp(base, Colors.white, 0.72)!;
}

Color recipe_surface_title_color(bool is_dark) {
  return is_dark ? Colors.white : const Color(0xFF1A1A1A);
}

Color recipe_surface_muted_text(bool is_dark, Color accent) {
  return is_dark ? accent.withValues(alpha: 0.85) : accent.withValues(alpha: 0.95);
}

Color recipe_surface_border(Color accent, bool is_dark) {
  return accent.withValues(alpha: is_dark ? 0.4 : 0.32);
}

Color recipe_surface_tag_text(Color tag_color, bool is_dark) {
  if (is_dark) return tag_color;
  return Color.lerp(tag_color, Colors.black, 0.35)!;
}

Color recipe_surface_action_background(bool is_dark) {
  return is_dark ? Colors.black26 : Colors.white.withValues(alpha: 0.72);
}
