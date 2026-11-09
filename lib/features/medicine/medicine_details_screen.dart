import 'package:flutter/material.dart';
import 'package:medi_reminder/services/notification_service.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';
import 'package:medi_reminder/widgets/status_badge.dart';

class MedicineDetailsScreen extends StatefulWidget {
  final String medicineId;

  const MedicineDetailsScreen({
    super.key,
    required this.medicineId,
  });

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  bool _deleting = false;

  int notificationId(String value) {
    var hash = 0x811C9DC5;

    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  Future<void> _deleteMedicine(Medicine m) async {
    if (_deleting) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete medicine?'),
        content: const Text(
          'This will remove this medicine from your list. '
          'Its previous history records will remain available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _deleting = true);

    var allCancelled = true;

    try {
      // Cancel all four current daily reminder slots.
      for (var i = 0; i < 4; i++) {
        try {
          await NotificationService.instance.cancelReminder(
            notificationId('${m.id}_dose_$i'),
          );
        } catch (e) {
          allCancelled = false;
        }
      }

      // Attempt to cancel an older reminder ID.
      try {
        await NotificationService.instance.cancelReminder(m.id.hashCode);
      } catch (e) {
        allCancelled = false;
      }

      // Delete the medicine while preserving its History.
      await MedicineService.instance.deleteMedicine(m.id);

      if (!mounted) return;

      Navigator.pop(context);

      if (!allCancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Medicine deleted, but some notifications may not have been cancelled.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _deleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete medicine: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = MedicineService.instance.getMedicineById(widget.medicineId);

    if (m == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Medicine Details'),
        ),
        body: const Center(
          child: Text('Medicine not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
          IconButton(
            onPressed: _deleting
                ? null
                : () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.editMedicine,
                      arguments: m.id,
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.cardLight,
            child: Icon(
              Icons.medication,
              size: 45,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              m.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              m.dosage,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 20),
          _Info('Frequency', m.frequency),
          _Info(
            'Reminder Times',
            m.reminderTimes.isEmpty
                ? 'No fixed reminder'
                : m.reminderTimes.join(', '),
          ),
          _Info('Start Date', m.startDate.substring(0, 10)),
          _Info('End Date', m.endDate?.substring(0, 10) ?? 'Not set'),
          _Info('Notes', m.notes.isEmpty ? 'No notes' : m.notes),
          ListTile(
            title: const Text('Status'),
            trailing: StatusBadge(
              m.isActive ? 'Active' : 'Inactive',
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            title: 'Open Reminder',
            icon: Icons.notifications_active,
            onPressed: _deleting
                ? null
                : () => Navigator.pushNamed(
                      context,
                      AppRoutes.reminder,
                      arguments: m.id,
                    ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _deleting ? null : () => _deleteMedicine(m),
            icon: const Icon(Icons.delete_outline),
            label: Text(_deleting ? 'Deleting...' : 'Delete Medicine'),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
