import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static const Color accent = Color(0xFF1DB954);

  static ThemeData get dark => _build(Brightness.dark, AppThemeExtension.dark);

  static ThemeData get light =>
      _build(Brightness.light, AppThemeExtension.light);

  static ThemeData _build(Brightness brightness, AppThemeExtension ext) {
    final is_dark = brightness == Brightness.dark;
    final text_theme = is_dark ? _darkTextTheme() : _lightTextTheme();

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: ext.scaffold,
      extensions: [ext],
      colorScheme: is_dark
          ? const ColorScheme.dark(
              primary: accent,
              surface: Color(0xFF141414),
              onSurface: Colors.white,
            )
          : const ColorScheme.light(
              primary: accent,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
      textTheme: text_theme,
      appBarTheme: AppBarTheme(
        backgroundColor: ext.scaffold,
        foregroundColor: text_theme.bodyLarge?.color,
        elevation: 0,
        titleTextStyle: text_theme.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surface,
        hintStyle: TextStyle(color: ext.text_muted, fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ext.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text_theme.bodyLarge?.color,
          side: BorderSide(color: ext.border),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _darkTextTheme() {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(color: const Color(0xFF8A8A8A)),
    );
  }

  static TextTheme _lightTextTheme() {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    );
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: const Color(0xFF1A1A1A),
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.4,
        color: const Color(0xFF1A1A1A),
      ),
      bodyMedium: base.bodyMedium?.copyWith(color: const Color(0xFF6C6C70)),
    );
  }
}
