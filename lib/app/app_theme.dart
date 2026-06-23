import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF15143A);
  static const purple = Color(0xFF2D2873);
  static const background = Color(0xFFEFF4FF);
  static const cyan = Color(0xFF14B8D4);
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFFF3B3B);
  static const yellow = Color(0xFFFFD93D);
  static const textMuted = Color(0xFF6B7280);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: null,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cyan,
        primary: AppColors.cyan,
        secondary: AppColors.green,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.navy),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textMuted),
      ),
    );
  }
}
