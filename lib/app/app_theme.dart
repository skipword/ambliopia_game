import 'package:flutter/material.dart';

class AppColors {
  // Colores principales existentes.
  // No cambiar sin revisar los estímulos de los juegos.
  static const navy = Color(0xFF171833);
  static const purple = Color(0xFF5B57C8);

  static const cyan = Color(0xFF14B8D4);

  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFFF3B3B);

  static const yellow = Color(0xFFFFD45C);

  // Fondos.
  static const background = Color(0xFFF2F6FD);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF8FAFD);

  // Texto.
  static const textMuted = Color(0xFF687083);
  static const textSoft = Color(0xFF9097A8);

  // Colores suaves para interfaz.
  static const softCyan = Color(0xFFE5F8FB);
  static const softGreen = Color(0xFFEAF9F0);
  static const softRed = Color(0xFFFFECEE);
  static const softPurple = Color(0xFFF0EEFF);
  static const softOrange = Color(0xFFFFF2E7);
  static const softBlue = Color(0xFFEAF2FB);

  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.cyan,
      onPrimary: Colors.white,
      secondary: AppColors.purple,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.navy,
      error: AppColors.red,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: colorScheme,

      // Dejamos la fuente del sistema por ahora.
      // Es más confiable en web, Android y modo offline.
      fontFamily: null,

      splashFactory: InkSparkle.splashFactory,

      iconTheme: const IconThemeData(color: AppColors.navy, size: 24),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 38,
          height: 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
        ),

        headlineLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 31,
          height: 1.08,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),

        headlineMedium: TextStyle(
          color: AppColors.navy,
          fontSize: 25,
          height: 1.10,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.45,
        ),

        headlineSmall: TextStyle(
          color: AppColors.navy,
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w900,
        ),

        titleLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 20,
          height: 1.15,
          fontWeight: FontWeight.w900,
        ),

        titleMedium: TextStyle(
          color: AppColors.navy,
          fontSize: 17,
          height: 1.20,
          fontWeight: FontWeight.w800,
        ),

        titleSmall: TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          height: 1.20,
          fontWeight: FontWeight.w800,
        ),

        bodyLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 16,
          height: 1.40,
          fontWeight: FontWeight.w600,
        ),

        bodyMedium: TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          height: 1.40,
          fontWeight: FontWeight.w600,
        ),

        bodySmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),

        labelLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),

        labelMedium: TextStyle(
          color: AppColors.navy,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),

        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 62,
        titleTextStyle: TextStyle(
          color: AppColors.navy,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.25,
        ),
        iconTheme: IconThemeData(color: AppColors.navy, size: 24),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          side: BorderSide(
            color: AppColors.navy.withValues(alpha: 0.12),
            width: 1.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.cyan,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textSoft,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        labelStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),

        floatingLabelStyle: const TextStyle(
          color: AppColors.cyan,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.navy.withValues(alpha: 0.06)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.red.withValues(alpha: 0.7)),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: const Color(0xFFF8FBFC),
        indicatorColor: AppColors.cyan.withValues(alpha: 0.14),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            color: selected ? AppColors.navy : AppColors.textMuted,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          );
        }),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.navy.withValues(alpha: 0.07),
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
