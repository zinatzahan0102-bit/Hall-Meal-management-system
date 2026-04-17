import 'package:flutter/material.dart';
import 'package:meal_management/core/theme/app_Pallate.dart';

class Apptheme {
  static final ThemeData thememood = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPallate.gradient2,
      brightness: Brightness.light,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color.fromARGB(255, 232, 235, 241)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPallate.gradient2, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallate.gradient2,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        minimumSize: const Size.fromHeight(54),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
      headlineLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      titleLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF132238),
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: Color(0xFF5B6475),
      ),
    ),
  );
}