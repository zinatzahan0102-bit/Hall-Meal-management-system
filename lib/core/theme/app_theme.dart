import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_management/core/theme/app_palette.dart';

class AppTheme {
  static final ThemeData thememood = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppPallate.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPallate.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPallate.primary,
      secondary: AppPallate.accent,
      surface: AppPallate.surface,
      onSurface: AppPallate.textPrimary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPallate.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE5DA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPallate.primary, width: 1.4),
      ),
      hintStyle: const TextStyle(color: AppPallate.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallate.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppPallate.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    ).apply(
      bodyColor: AppPallate.textPrimary,
      displayColor: AppPallate.textPrimary,
    ),
  );
}