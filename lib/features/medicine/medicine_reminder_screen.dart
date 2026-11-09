import 'package:flutter/material.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/services/notification_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';

class MedicineReminderScreen extends StatelessWidget {
  final String medicineId;

  const MedicineReminderScreen({
    super.key,
    required this.medicineId,
  });

  @override
  Widget build(BuildContext context) {
    final medicine = MedicineService.instance.getMedicineById(medicineId);

    if (medicine == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reminder'),
        ),
        body: const Center(
          child: Text('Medicine not found.'),
        ),
      );
    }

    final scheduledTimes = medicine.reminderTimes.isEmpty
        ? 'As needed'
        : medicine.reminderTimes.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_active,
                size: 92,
                color: Color(0xFFBD79FF),
              ),
              const SizedBox(height: 25),
              const Text(
                'Time to take your medicine!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                medicine.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                medicine.dosage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Scheduled: $scheduledTimes',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Mark the scheduled dose as Taken.
              AppButton(
                title: 'Take Now',
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  await MedicineService.instance.recordAction(
                    medicine,
                    'Taken',
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as taken.'),
                    ),
                  );

                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),

              // Mark the scheduled dose as Missed.
              OutlinedButton.icon(
                onPressed: () async {
                  await MedicineService.instance.recordAction(
                    medicine,
                    'Missed',
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marked as missed.'),
                    ),
                  );

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Mark as Missed'),
              ),

              const SizedBox(height: 12),

              // Snooze the reminder for 15 minutes.
              OutlinedButton(
                onPressed: () async {
                  final success = await NotificationService.instance
                      .scheduleMedicineReminder(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .remainder(2147483647),
                    medicineName: medicine.name,
                    dateTime: DateTime.now().add(
                      const Duration(minutes: 15),
                    ),
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Reminder snoozed for 15 minutes.'
                            : 'Could not schedule reminder. Check notification permissions.',
                      ),
                    ),
                  );

                  if (success) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Snooze (15 min)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
