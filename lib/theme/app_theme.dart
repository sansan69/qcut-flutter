import 'package:flutter/material.dart';

/// QCUT brand color tokens — the single source of truth for the dark "Midnight" theme.
///
/// Every screen should reference these semantic tokens (or `Theme.of(context)`)
/// rather than inventing ad-hoc colors. Legacy aliases at the bottom exist only
/// to keep old call-sites compiling while they migrate to semantic names.
class QCutColors {
  // ── Brand ──
  static const primary = Color(0xFF6B4EE6);
  static const primaryContainer = Color(0xFF4A3A9E);
  static const secondary = Color(0xFF9B7BFF);
  static const secondaryContainer = Color(0xFF2D2659);

  // ── Surfaces (deep near-black) ──
  static const surface = Color(0xFF0D0D12);
  static const surfaceContainer = Color(0xFF1A1A24);
  static const surfaceContainerHigh = Color(0xFF242433);
  static const surfaceContainerHighest = Color(0xFF2E2E42);

  // ── Content ──
  static const onSurface = Color(0xFFE8E6F0);
  static const onSurfaceVariant = Color(0xFF9E9CB0);
  static const outline = Color(0xFF3E3E52);
  static const outlineVariant = Color(0xFF2A2A3A);

  // ── Status ──
  static const error = Color(0xFFF87171);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const info = Color(0xFF60A5FA);

  // ── Misc ──
  static const iconBackground = Color(0xFF1A1325);
  static const scrim = Color(0xFF000000);

  // ── Tinted surfaces (for chips / subtle fills) ──
  static Color tint(Color c, [double alpha = 0.12]) => c.withValues(alpha: alpha);
  static Color get primaryTint => primary.withValues(alpha: 0.14);
  static Color get successTint => success.withValues(alpha: 0.14);
  static Color get warningTint => warning.withValues(alpha: 0.14);
  static Color get errorTint => error.withValues(alpha: 0.14);
  static Color get infoTint => info.withValues(alpha: 0.14);

  // ── Backward-compatible aliases ──
  // NOTE: prefer semantic tokens. These map legacy names to their closest
  // semantic dark value so unmigrated code still reads as a dark screen.
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
  static const redBg = surfaceContainer;
}

/// Brand gradients used across headers, hero banners, CTAs and chart bars.
class QCutGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B4EE6), Color(0xFF9B7BFF)],
  );

  /// Subtle purple→surface gradient for hero/app-bar backgrounds.
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A3A9E), Color(0xFF0D0D12)],
  );

  /// Brighter accent for FABs and active chips.
  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5BF0), Color(0xFFB49BFF)],
  );

  /// Success gradient for confirmation / completed states.
  static const success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF4ADE80)],
  );

  /// Danger gradient for destructive CTAs.
  static const danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF87171), Color(0xFFB91C1C)],
  );

  /// Surface sheen for elevated glassy cards.
  static const sheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF242433), Color(0xFF16161F)],
  );
}

/// Soft shadows / glows tuned for the dark surface.
class QCutShadows {
  static List<BoxShadow> card([double elevation = 0]) => elevation <= 0
      ? []
      : [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: elevation * 6, offset: Offset(0, elevation * 2))];

  /// Soft purple glow for primary CTAs and active accents.
  static List<BoxShadow> glow([Color? color]) => [
        BoxShadow(color: (color ?? QCutColors.primary).withValues(alpha: 0.45), blurRadius: 18, spreadRadius: 1, offset: const Offset(0, 4)),
      ];

  static List<BoxShadow> soft() => [
        BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 2)),
      ];
}

class QCutTheme {
  static ThemeData get dark {
    const scheme = ColorScheme(
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
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: QCutColors.surface,
      splashFactory: InkSparkle.splashFactory,
      // ── Typography ──
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: QCutColors.onSurface, letterSpacing: -0.5, height: 1.15),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: QCutColors.onSurface, letterSpacing: -0.3, height: 1.2),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: QCutColors.onSurface, height: 1.25),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: QCutColors.onSurface, letterSpacing: 0.1),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: QCutColors.onSurface),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: QCutColors.onSurface),
        bodyLarge: TextStyle(fontSize: 15, color: QCutColors.onSurface, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: QCutColors.onSurface, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: QCutColors.onSurface, letterSpacing: 0.3),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: QCutColors.onSurfaceVariant, letterSpacing: 0.5),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: QCutColors.onSurfaceVariant, letterSpacing: 0.8),
      ),
      // ── AppBar ──
      appBarTheme: const AppBarTheme(
        backgroundColor: QCutColors.surface,
        foregroundColor: QCutColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: QCutColors.onSurface, letterSpacing: 0.2),
      ),
      // ── Card ──
      cardTheme: CardThemeData(
        color: QCutColors.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: QCutColors.outlineVariant),
        ),
      ),
      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QCutColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QCutColors.primary,
          side: const BorderSide(color: QCutColors.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: QCutColors.primaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: QCutColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // ── Inputs ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QCutColors.surfaceContainer,
        hintStyle: const TextStyle(color: QCutColors.onSurfaceVariant),
        labelStyle: const TextStyle(color: QCutColors.onSurfaceVariant),
        prefixIconColor: QCutColors.onSurfaceVariant,
        suffixIconColor: QCutColors.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QCutColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QCutColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QCutColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QCutColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: QCutColors.error, width: 1.5),
        ),
      ),
      // ── Chips ──
      chipTheme: ChipThemeData(
        backgroundColor: QCutColors.surfaceContainerHigh,
        selectedColor: QCutColors.primaryContainer,
        checkmarkColor: Colors.white,
        labelStyle: const TextStyle(color: QCutColors.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        side: const BorderSide(color: QCutColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      // ── Navigation bar ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: QCutColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: QCutColors.primaryTint,
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? QCutColors.primary : QCutColors.onSurfaceVariant,
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return IconThemeData(color: selected ? QCutColors.primary : QCutColors.onSurfaceVariant, size: 24);
        }),
        height: 68,
      ),
      // ── Switch ──
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : QCutColors.onSurfaceVariant),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? QCutColors.success : QCutColors.surfaceContainerHigh),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      // ── SegmentedButton ──
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.selected)) return QCutColors.primary;
            return QCutColors.surfaceContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.selected)) return Colors.white;
            return QCutColors.onSurfaceVariant;
          }),
          side: WidgetStateProperty.all(const BorderSide(color: QCutColors.outlineVariant)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
      // ── Dialogs ──
      dialogTheme: DialogThemeData(
        backgroundColor: QCutColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: QCutColors.outlineVariant)),
        titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: QCutColors.onSurface),
        contentTextStyle: const TextStyle(fontSize: 14, color: QCutColors.onSurfaceVariant, height: 1.5),
      ),
      // ── Misc ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor: QCutColors.surfaceContainerHigh,
        contentTextStyle: const TextStyle(color: QCutColors.onSurface, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: QCutColors.outlineVariant)),
      ),
      dividerTheme: const DividerThemeData(color: QCutColors.outlineVariant, thickness: 1, space: 1),
      listTileTheme: const ListTileThemeData(iconColor: QCutColors.onSurfaceVariant, textColor: QCutColors.onSurface),
      tabBarTheme: const TabBarThemeData(
        labelColor: QCutColors.onSurface,
        unselectedLabelColor: QCutColors.onSurfaceVariant,
        indicatorColor: QCutColors.primary,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: QCutColors.primary, linearTrackColor: QCutColors.surfaceContainerHigh, circularTrackColor: QCutColors.surfaceContainerHigh),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: QCutColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      iconTheme: const IconThemeData(color: QCutColors.onSurface),
    );
  }
}

/// Extension helpers for on-the-fly tinted containers.
extension QCutColorX on Color {
  Color get subtle => withValues(alpha: 0.12);
}
