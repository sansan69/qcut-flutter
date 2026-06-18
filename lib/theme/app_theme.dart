import 'package:flutter/material.dart';

class QCutColors {
  static const primary = Color(0xFF6B4EE6);
  static const primaryContainer = Color(0xFF4A3A9E);
  static const secondary = Color(0xFF9B7BFF);
  static const secondaryContainer = Color(0xFF2D2659);
  static const surface = Color(0xFF0D0D12);
  static const surfaceContainer = Color(0xFF1A1A24);
  static const surfaceContainerHigh = Color(0xFF242433);
  static const onSurface = Color(0xFFE8E6F0);
  static const onSurfaceVariant = Color(0xFF9E9CB0);
  static const outline = Color(0xFF3E3E52);
  static const error = Color(0xFFF87171);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const iconBackground = Color(0xFF1A1325);

  // Backward-compatible aliases for legacy callers until full migration
  static const navy = surface;
  static const charcoal = onSurfaceVariant;
  static const surfaceVariant = surfaceContainer;
  static const burgundy = error;
  static const emerald = success;
  static const emeraldBg = surfaceContainer;
  static const amber = warning;
  static const amberBg = surfaceContainer;
  static const purple = primary;
  static const purpleBg = primaryContainer;
  static const red = error;
  static const redBg = secondaryContainer;
}

class QCutTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: QCutColors.primary,
      onPrimary: Colors.white,
      primaryContainer: QCutColors.primaryContainer,
      onPrimaryContainer: Colors.white,
      secondary: QCutColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: QCutColors.secondaryContainer,
      onSecondaryContainer: Colors.white,
      surface: QCutColors.surface,
      onSurface: QCutColors.onSurface,
      surfaceContainerHighest: QCutColors.surfaceContainerHigh,
      onSurfaceVariant: QCutColors.onSurfaceVariant,
      error: QCutColors.error,
      onError: Colors.white,
      outline: QCutColors.outline,
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: QCutColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: QCutColors.surface,
      foregroundColor: QCutColors.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: QCutColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: QCutColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: QCutColors.primary,
        side: const BorderSide(color: QCutColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: QCutColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QCutColors.outline),
      ),
    ),
  );
}
