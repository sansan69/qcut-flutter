import 'package:flutter/material.dart';
import '../../models/token_entry.dart';
import '../../services/haptic_service.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/q_logo_header.dart';
import '../../ui/core/qcut_components.dart';
import '../../ui/core/swipeable_list_tile.dart';

Future<void> _showTokenOptions(
  BuildContext context, {
  required TokenEntry token,
  required bool isServing,
  VoidCallback? onComplete,
  VoidCallback? onNoShow,
  VoidCallback? onCancel,
}) async {
  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('#${token.tokenNumber} ${token.name}'),
      content: const Text('Choose an action'),
      actions: [
        if (isServing) ...[
          TextButton(onPressed: () => Navigator.of(context).pop('complete'), child: const Text('Complete')),
          TextButton(onPressed: () => Navigator.of(context).pop('noshow'), child: const Text('No-show')),
        ] else ...[
          TextButton(onPressed: () => Navigator.of(context).pop('cancel'), child: const Text('Cancel')),
        ],
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    ),
  );

  switch (action) {
    case 'complete':
      await HapticService.trigger(HapticType.medium);
      onComplete?.call();
    case 'noshow':
      await HapticService.trigger(HapticType.heavy);
      onNoShow?.call();
    case 'cancel':
      await HapticService.trigger(HapticType.heavy);
      onCancel?.call();
  }
}

/// Token Queue Dashboard — live serving / waiting / completed lists.
class TokenQueueScreen extends StatelessWidget {
  final List<TokenEntry> serving;
  final List<TokenEntry> waiting;
  final List<TokenEntry> completed;
  final VoidCallback onCallNext;
  final Function(TokenEntry) onComplete;
  final Function(TokenEntry) onNoShow;
  final Function(TokenEntry) onCancel;

  const TokenQueueScreen({
    super.key,
    required this.serving,
    required this.waiting,
    required this.completed,
    required this.onCallNext,
    required this.onComplete,
    required this.onNoShow,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const QLogoHeader(height: 28)),
      body: RefreshIndicator(
        onRefresh: () async {
          await HapticService.trigger(HapticType.light);
        },
        child: ListView(padding: const EdgeInsets.all(20), children: [
          QSectionLabel(icon: Icons.campaign, title: 'Now Serving'),
          const SizedBox(height: 12),
          if (serving.isEmpty)
            _EmptyServing(onCallNext: onCallNext, hasWaiting: waiting.isNotEmpty)
          else
            ...serving.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SwipeableListTile(
                dismissibleKey: ValueKey('serving-${t.id}'),
                onComplete: () async {
                  await HapticService.trigger(HapticType.medium);
                  onComplete(t);
                },
                onCancel: () async {
                  await HapticService.trigger(HapticType.heavy);
                  onNoShow(t);
                },
                onLongPress: () => _showTokenOptions(
                  context,
                  token: t,
                  isServing: true,
                  onComplete: () => onComplete(t),
                  onNoShow: () => onNoShow(t),
                ),
                child: _ServingCard(token: t, onComplete: () => onComplete(t), onNoShow: () => onNoShow(t)),
              ),
            )),

          const SizedBox(height: 28),
          QSectionLabel(icon: Icons.access_time, title: 'Waiting Queue', trailing: '${waiting.length} waiting'),
          const SizedBox(height: 12),
          if (waiting.isEmpty)
            const _EmptyCard(text: 'Queue is empty.')
          else
            QGlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: waiting.asMap().entries.map((e) => Column(
                  children: [
                    _WaitingRow(
                      token: e.value,
                      onCancel: () => onCancel(e.value),
                      onLongPress: () => _showTokenOptions(
                        context,
                        token: e.value,
                        isServing: false,
                        onCancel: () => onCancel(e.value),
                      ),
                    ),
                    if (e.key < waiting.length - 1) const Divider(height: 1),
                  ],
                )).toList(),
              ),
            ),

          const SizedBox(height: 28),
          QSectionLabel(icon: Icons.check_circle, title: 'Completed Today'),
          const SizedBox(height: 12),
          if (completed.isEmpty)
            const _EmptyCard(text: 'No completed tokens yet.')
          else
            Wrap(spacing: 6, runSpacing: 6, children: completed.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: QCutColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: QCutColors.outlineVariant),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('#${t.tokenNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: QCutColors.success)),
                const SizedBox(width: 6),
                Text(t.name, style: const TextStyle(fontSize: 11, color: QCutColors.onSurfaceVariant)),
              ]),
            )).toList()),
        ]),
      ),
    );
  }
}

class _EmptyServing extends StatelessWidget {
  final VoidCallback onCallNext;
  final bool hasWaiting;
  const _EmptyServing({required this.onCallNext, required this.hasWaiting});

  @override
  Widget build(BuildContext context) {
    return QGlassCard(
      color: QCutColors.surfaceContainer.withValues(alpha: 0.5),
      child: Column(children: [
        Icon(Icons.hourglass_empty, size: 32, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.4)),
        const SizedBox(height: 8),
        Text('No tokens currently being served.', style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
        if (hasWaiting) ...[
          const SizedBox(height: 16),
          QPrimaryButton(
            onPressed: () async {
              await HapticService.trigger(HapticType.medium);
              onCallNext();
            },
            icon: Icons.play_arrow,
            height: 44,
            child: const Text('Call Next Token'),
          ),
        ],
      ]),
    );
  }
}

class _ServingCard extends StatelessWidget {
  final TokenEntry token;
  final VoidCallback onComplete, onNoShow;
  const _ServingCard({required this.token, required this.onComplete, required this.onNoShow});

  @override
  Widget build(BuildContext context) {
    return QGlassCard(
      padding: EdgeInsets.zero,
      border: const BorderSide(color: QCutColors.success, width: 1.5),
      boxShadow: [BoxShadow(color: QCutColors.success.withValues(alpha: 0.18), blurRadius: 16)],
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(gradient: QCutGradients.success, borderRadius: const BorderRadius.vertical(top: Radius.circular(15))),
          child: const Text('SERVING', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.5)),
        ),
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: QCutColors.successTint, shape: BoxShape.circle, border: Border.all(color: QCutColors.success.withValues(alpha: 0.4))),
            child: const Center(child: Text('#', style: TextStyle(fontWeight: FontWeight.w800, color: QCutColors.success, fontSize: 18))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(token.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: QCutColors.onSurface)),
            if (token.phone.isNotEmpty) Text(token.phone, style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12)),
          ])),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Row(children: [
          Expanded(child: QPrimaryButton(
            onPressed: () async {
              await HapticService.trigger(HapticType.medium);
              onComplete();
            },
            gradient: QCutGradients.success,
            icon: Icons.check,
            height: 44,
            child: const Text('Complete'),
          )),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              await HapticService.trigger(HapticType.heavy);
              onNoShow();
            },
            style: IconButton.styleFrom(
              backgroundColor: QCutColors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              fixedSize: const Size(48, 44),
            ),
            icon: const Icon(Icons.close, color: QCutColors.onSurfaceVariant),
          ),
        ])),
      ]),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  final TokenEntry token;
  final VoidCallback onCancel;
  final VoidCallback? onLongPress;
  const _WaitingRow({required this.token, required this.onCancel, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return SwipeableListTile(
      dismissibleKey: ValueKey('waiting-${token.id}'),
      onCancel: () async {
        await HapticService.trigger(HapticType.heavy);
        onCancel();
      },
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          SizedBox(width: 40, child: Text('#${token.tokenNumber}', style: const TextStyle(fontWeight: FontWeight.w800, color: QCutColors.onSurface))),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(token.name, style: const TextStyle(fontWeight: FontWeight.w600, color: QCutColors.onSurface)),
            if (token.phone.isNotEmpty) Text(token.phone, style: TextStyle(fontSize: 12, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7))),
          ])),
          IconButton(icon: Icon(Icons.cancel, color: QCutColors.onSurfaceVariant.withValues(alpha: 0.4)), onPressed: () async {
            await HapticService.trigger(HapticType.heavy);
            onCancel();
          }),
        ]),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return QGlassCard(
      color: QCutColors.surfaceContainer.withValues(alpha: 0.5),
      child: Center(child: Text(text, style: TextStyle(color: QCutColors.onSurfaceVariant.withValues(alpha: 0.7)))),
    );
  }
}
