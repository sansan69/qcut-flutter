import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A swipeable row wrapping [child]. Swipe right → [onComplete] (green),
/// swipe left → [onCancel] (red). Both surface a confirm dialog. Haptics
/// are triggered by the caller on the action callbacks.
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
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
        decoration: BoxDecoration(
          gradient: QCutGradients.success,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          gradient: QCutGradients.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.cancel, color: Colors.white, size: 28),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
      ),
    );
  }
}
