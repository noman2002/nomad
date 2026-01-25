import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF6B35);
  static const secondary = Color(0xFF00B4D8);
  static const dark = Color(0xFF1A1A1D);
  static const light = Color(0xFFF7F7F7);
  static const accent = Color(0xFFFFD23F);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.dark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.light,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
    ),
    useMaterial3: true,
  );
}
