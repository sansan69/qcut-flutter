import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SwipeableListTile extends StatelessWidget {
  final Key dismissibleKey;
  final Widget child;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onLongPress;

  const SwipeableListTile({
    super.key,
    required this.dismissibleKey,
    required this.child,
    this.onComplete,
    this.onCancel,
    this.onLongPress,
  });

  Future<bool> _confirmAction(BuildContext context, String title, String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: QCutColors.surfaceContainer,
        title: Text(title, style: const TextStyle(color: QCutColors.onSurface)),
        content: Text(message, style: const TextStyle(color: QCutColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissibleKey,
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (onComplete == null) return false;
          final confirmed = await _confirmAction(context, 'Complete', 'Mark this token as completed?');
          if (confirmed) onComplete?.call();
          return false;
        } else {
          if (onCancel == null) return false;
          final confirmed = await _confirmAction(context, 'Cancel / No-show', 'Cancel or mark this token as no-show?');
          if (confirmed) onCancel?.call();
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
