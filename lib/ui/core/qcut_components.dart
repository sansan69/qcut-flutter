import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reusable QCUT "Midnight" primitives. Screens compose these instead of
/// hand-rolling cards, headers, buttons and labels — guaranteeing visual
/// consistency across the whole app.

// ════════════════════════════════════════════════════════════════
// Cards
// ════════════════════════════════════════════════════════════════

/// A glassy surface card: surfaceContainer with a hairline outline and
/// optional soft elevation. Use for most content groupings.
class QGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final VoidCallback? onTap;
  final List<BoxShadow> boxShadow;
  final Color? color;
  final BorderSide? border;

  const QGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 16,
    this.onTap,
    this.boxShadow = const [],
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color ?? QCutColors.surfaceContainer,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border?.color ?? QCutColors.outlineVariant, width: border?.width ?? 1),
      boxShadow: boxShadow,
    );
    final content = Padding(padding: padding, child: child);
    if (onTap == null) {
      return Container(margin: margin, decoration: decoration, child: content);
    }
    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: content),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Headers
// ════════════════════════════════════════════════════════════════

/// Branded gradient header band. Useful as a hero or the body's first
/// child to anchor a screen in the brand palette.
class QGradientHeader extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;
  final double height;

  const QGradientHeader({
    super.key,
    this.title,
    this.titleText,
    this.subtitle,
    this.leading,
    this.actions,
    this.gradient = QCutGradients.hero,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 24),
    this.height = 0,
  }) : assert(title == null || titleText == null, 'Provide either title or titleText, not both');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Padding(
            padding: padding,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  if (title != null)
                    title!
                  else if (titleText != null)
                    Text(titleText!, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4)),
                  ],
                ]),
              ),
              if (actions != null) ...actions!,
            ]),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Section labels
// ════════════════════════════════════════════════════════════════

/// Icon + title section header, with an optional trailing count chip.
class QSectionLabel extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? trailing;
  final Color? accent;
  final TextStyle? titleStyle;

  const QSectionLabel({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
    this.accent,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? QCutColors.primary;
    return Row(children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
      ],
      Text(title, style: titleStyle ?? Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: QCutColors.onSurface)),
      const Spacer(),
      if (trailing != null)
        QCountChip(label: trailing!),
    ]);
  }
}

/// Small pill used for counts / status tags. Takes a [color] for tint+text.
class QCountChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final bool filled;

  const QCountChip({
    super.key,
    required this.label,
    this.color = QCutColors.primary,
    this.textColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: filled ? Colors.white : (textColor ?? color), letterSpacing: 0.3),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Icon chips
// ════════════════════════════════════════════════════════════════

/// A rounded icon sitting inside a tinted circle. Color drives both tint and icon.
class QIconChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool glow;

  const QIconChip({
    super.key,
    required this.icon,
    this.color = QCutColors.primary,
    this.size = 48,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: glow ? QCutShadows.glow(color) : null,
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Stat cards
// ════════════════════════════════════════════════════════════════

/// Compact KPI tile: big number + label, tinted by [color].
class QStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData? icon;

  const QStatCard({
    super.key,
    required this.value,
    required this.label,
    this.color = QCutColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
          ],
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color, height: 1.1)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.85), letterSpacing: 0.3)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Buttons
// ════════════════════════════════════════════════════════════════

/// Primary CTA: gradient fill + soft purple glow.
class QPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final bool expand;
  final double height;
  final Gradient gradient;

  const QPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.expand = true,
    this.height = 52,
    this.gradient = QCutGradients.primary,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final btn = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: disabled ? null : gradient,
        color: disabled ? QCutColors.surfaceContainerHigh : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: disabled ? null : QCutShadows.glow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: disabled ? QCutColors.onSurfaceVariant.withValues(alpha: 0.4) : Colors.white, size: 20), const SizedBox(width: 8)],
              DefaultTextStyle(
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: disabled ? QCutColors.onSurfaceVariant.withValues(alpha: 0.4) : Colors.white, letterSpacing: 0.3),
                child: child,
              ),
            ]),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Tonal secondary button on a [QCutColors.surfaceContainerHigh] fill.
class QTonalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;
  final bool expand;
  final Color? color;

  const QTonalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
    this.expand = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? QCutColors.surfaceContainerHigh;
    final btn = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14), border: Border.all(color: QCutColors.outlineVariant)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: QCutColors.onSurface, size: 18), const SizedBox(width: 8)],
              DefaultTextStyle(style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: QCutColors.onSurface), child: child),
            ]),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ════════════════════════════════════════════════════════════════
// Misc helpers
// ════════════════════════════════════════════════════════════════

/// Empty state: faded icon + headline + optional subtitle + action.
class QEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? tint;

  const QEmptyState({super.key, required this.icon, required this.title, this.subtitle, this.action, this.tint});

  @override
  Widget build(BuildContext context) {
    final color = tint ?? QCutColors.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: color.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color.withValues(alpha: 0.6))),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.4), height: 1.4)),
          ],
          if (action != null) ...[const SizedBox(height: 20), action!],
        ]),
      ),
    );
  }
}

/// A rounded selection tile used by booking/onboarding flows. Highlights when
/// [selected] via a primary border + tint + check badge.
class QSelectionTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final double radius;

  const QSelectionTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected ? QCutColors.primaryTint : QCutColors.surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: selected ? QCutColors.primary : QCutColors.outlineVariant, width: selected ? 1.5 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              leading,
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                title,
                if (subtitle != null) ...[const SizedBox(height: 2), subtitle!],
              ])),
              if (selected)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(gradient: QCutGradients.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
