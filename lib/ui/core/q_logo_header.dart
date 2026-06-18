import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Branded QCUT logo + wordmark header. Uses the transparent logo asset and
/// falls back to a gradient "Q" tile when the image is unavailable.
class QLogoHeader extends StatelessWidget {
  final double height;
  final bool showText;
  final Color? textColor;

  const QLogoHeader({super.key, this.height = 32, this.showText = true, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo/logo_transparent.png',
          height: height,
          errorBuilder: (context, error, stackTrace) => _LogoFallback(size: height),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'QCUT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: textColor ?? QCutColors.onSurface,
                ),
          ),
        ],
      ],
    );
  }
}

/// Gradient rounded "Q" tile — the fallback and a reusable brand mark.
class _LogoFallback extends StatelessWidget {
  final double size;
  const _LogoFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: QCutGradients.primary,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: QCutShadows.glow(),
      ),
      child: Center(
        child: Text(
          'Q',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
