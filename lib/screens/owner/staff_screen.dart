import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_models.dart';
import '../../theme/app_theme.dart';

/// Staff Management — barber list with add/toggle/delete
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Barber', style: TextStyle(color: QCutColors.navy, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Barber Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          onSubmitted: (_) => _submit(ctx),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: QCutColors.charcoal.withValues(alpha: 0.6)))),
          ElevatedButton(
            onPressed: () => _submit(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: QCutColors.purple, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
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
      appBar: AppBar(
        title: const Text('Staff'),
        backgroundColor: QCutColors.navy,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: QCutColors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: widget.barbers.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.people_outline, size: 64, color: QCutColors.charcoal.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text('No barbers added', style: TextStyle(fontSize: 16, color: QCutColors.charcoal.withValues(alpha: 0.5))),
                const SizedBox(height: 8),
                Text('Tap + to add your first barber', style: TextStyle(fontSize: 13, color: QCutColors.charcoal.withValues(alpha: 0.3))),
              ]),
            )
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (active.isNotEmpty) ...[
                Text('Active (${active.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: QCutColors.navy)),
                const SizedBox(height: 8),
                ...active.map((b) => _BarberCard(
                  barber: b,
                  onToggle: () => widget.onToggle(b),
                  onDelete: () => _confirmDelete(b),
                )),
              ],
              if (inactive.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Inactive (${inactive.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: QCutColors.charcoal.withValues(alpha: 0.5))),
                const SizedBox(height: 8),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Barber?'),
        content: Text('Remove ${b.name} from the shop?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(b.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: QCutColors.red, foregroundColor: Colors.white),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: barber.isActive ? QCutColors.emeraldBg : QCutColors.surfaceVariant,
          child: Text(
            barber.name.isNotEmpty ? barber.name[0].toUpperCase() : '?',
            style: TextStyle(fontWeight: FontWeight.bold, color: barber.isActive ? QCutColors.emerald : QCutColors.charcoal.withValues(alpha: 0.4)),
          ),
        ),
        title: Text(barber.name, style: TextStyle(fontWeight: FontWeight.w600, color: barber.isActive ? QCutColors.navy : QCutColors.charcoal.withValues(alpha: 0.4))),
        subtitle: Text(barber.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, color: barber.isActive ? QCutColors.emerald : QCutColors.red)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Switch(value: barber.isActive, onChanged: (_) => onToggle(), activeColor: QCutColors.emerald),
          IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete, color: QCutColors.red),
        ]),
      ),
    );
  }
}
