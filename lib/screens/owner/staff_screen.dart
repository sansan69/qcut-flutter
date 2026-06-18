import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';
import '../../ui/core/qcut_components.dart';

/// Staff Management — barber list with add/toggle/delete.
class StaffScreen extends StatefulWidget {
  final List<Barber> barbers;
  final Function(String name) onAdd;
  final Function(Barber barber) onToggle;
  final Function(String id) onDelete;

  const StaffScreen({
    super.key,
    required this.barbers,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _nameCtrl = TextEditingController();

  void _showAddDialog() {
    _nameCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Barber'),
        content: TextField(
          controller: _nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Barber Name'),
          onSubmitted: (_) => _submit(ctx),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _submit(ctx), child: const Text('Add')),
        ],
      ),
    );
  }

  void _submit(BuildContext ctx) {
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onAdd(name);
      Navigator.pop(ctx);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.barbers.where((b) => b.isActive).toList();
    final inactive = widget.barbers.where((b) => !b.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff')),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
      body: widget.barbers.isEmpty
          ? const QEmptyState(icon: Icons.people_outline, title: 'No barbers added', subtitle: 'Tap + to add your first barber')
          : ListView(padding: const EdgeInsets.all(20), children: [
              if (active.isNotEmpty) ...[
                QSectionLabel(icon: Icons.check_circle, title: 'Active', trailing: '${active.length}'),
                const SizedBox(height: 12),
                ...active.map((b) => _BarberCard(
                  barber: b,
                  onToggle: () => widget.onToggle(b),
                  onDelete: () => _confirmDelete(b),
                )),
              ],
              if (inactive.isNotEmpty) ...[
                const SizedBox(height: 24),
                QSectionLabel(icon: Icons.pause_circle, title: 'Inactive', trailing: '${inactive.length}'),
                const SizedBox(height: 12),
                ...inactive.map((b) => _BarberCard(
                  barber: b,
                  onToggle: () => widget.onToggle(b),
                  onDelete: () => _confirmDelete(b),
                )),
              ],
            ]),
    );
  }

  void _confirmDelete(Barber b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Barber?'),
        content: Text('Remove ${b.name} from the shop?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { widget.onDelete(b.id); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: QCutColors.error, foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _BarberCard extends StatelessWidget {
  final Barber barber;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _BarberCard({required this.barber, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final active = barber.isActive;
    return QGlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: active ? QCutColors.successTint : QCutColors.surfaceContainerHigh,
          child: Text(
            barber.name.isNotEmpty ? barber.name[0].toUpperCase() : '?',
            style: TextStyle(fontWeight: FontWeight.w800, color: active ? QCutColors.success : QCutColors.onSurfaceVariant),
          ),
        ),
        title: Text(barber.name, style: TextStyle(fontWeight: FontWeight.w700, color: active ? QCutColors.onSurface : QCutColors.onSurfaceVariant)),
        subtitle: Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, color: active ? QCutColors.success : QCutColors.onSurfaceVariant)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Switch(value: active, onChanged: (_) => onToggle()),
          IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete, color: QCutColors.error),
        ]),
      ),
    );
  }
}
