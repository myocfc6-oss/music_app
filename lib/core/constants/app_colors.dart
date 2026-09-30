import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme Palette
  static const Color background = Color(0xFF0A0A0B);
  static const Color primaryNeon = Color(0xFFA6EB00);
  static const Color primaryNeonDark = Color(0xFF8ACC00);

  static const Color surfaceDark = Color(0xFF121214);
  static const Color surfaceCard = Color(0xFF1F1F23);
  static const Color surfaceElevated = Color(0xFF27272A);
  static const Color borderDark = Color(0xFF27272A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F3F5);
  static const Color lightBorder = Color(0xFFE4E4E7);

  static const Color lightTextPrimary = Color(0xFF09090B);
  static const Color lightTextSecondary = Color(0xFF52525B);
  static const Color lightTextMuted = Color(0xFFA1A1AA);

  static const Color primaryNeonLight = Color(0xFF65A30D);
  static const Color primaryNeonLightDark = Color(0xFF4D7C0F);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color overlay = Color(0x80000000);
}

extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground => isDarkMode ? AppColors.background : AppColors.lightBackground;
  Color get surfaceCard => isDarkMode ? AppColors.surfaceCard : AppColors.lightSurfaceCard;
  Color get surfaceDark => isDarkMode ? AppColors.surfaceDark : AppColors.lightSurface;
  Color get surfaceElevated => isDarkMode ? AppColors.surfaceElevated : AppColors.lightSurfaceElevated;
  Color get borderDark => isDarkMode ? AppColors.borderDark : AppColors.lightBorder;
  Color get textPrimary => isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDarkMode ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDarkMode ? AppColors.textMuted : AppColors.lightTextMuted;
  Color get primaryNeon => isDarkMode ? AppColors.primaryNeon : AppColors.primaryNeonLight;
}
