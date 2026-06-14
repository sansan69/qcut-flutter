import 'package:flutter/material.dart';

/// Q - CUT brand colors — from QCUT Kotlin Color.kt
class QCutColors {
  static const navy = Color(0xFF0F172A);
  static const charcoal = Color(0xFF334155);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const burgundy = Color(0xFF9F1239);
  static const emerald = Color(0xFF10B981);
  static const emeraldBg = Color(0xFFD1FAE5);
  static const amber = Color(0xFFF59E0B);
  static const amberBg = Color(0xFFFEF3C7);
  static const purple = Color(0xFF7C3AED);
  static const purpleBg = Color(0xFFEDE9FE);
  static const red = Color(0xFFDC2626);
  static const redBg = Color(0xFFFEE2E2);
}

class QCutTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: QCutColors.navy,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
