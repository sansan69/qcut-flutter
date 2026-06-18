import 'package:flutter/material.dart';

class QLogoHeader extends StatelessWidget {
  final double height;
  final bool showText;
  const QLogoHeader({super.key, this.height = 32, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo/logo_transparent.png',
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.cut, color: Colors.white),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'QCUT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ],
    );
  }
}
