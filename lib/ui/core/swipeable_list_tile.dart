import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SwipeableListTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onLongPress;

  const SwipeableListTile({
    super.key,
    required this.child,
    this.onComplete,
    this.onCancel,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete?.call();
          return false;
        } else {
          onCancel?.call();
          return false;
        }
      },
      background: Container(
        color: QCutColors.success,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: QCutColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.cancel, color: Colors.white),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
