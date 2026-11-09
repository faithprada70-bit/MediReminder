import 'package:flutter/material.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/services/notification_service.dart';

class EditMedicineScreen extends StatefulWidget {
  final String medicineId;

  const EditMedicineScreen({
    super.key,
    required this.medicineId,
  });

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final name = TextEditingController();
  final dosage = TextEditingController();
  final notes = TextEditingController();

  static const List<TimeOfDay> defaultTimes = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 22, minute: 0),
  ];

  String frequency = 'Once a day';
  List<TimeOfDay> times = [defaultTimes[0]];

  bool active = true;
  bool loaded = false;
  bool saving = false;

  int get timeCount {
    switch (frequency) {
      case 'Once a day':
        return 1;
      case 'Twice a day':
        return 2;
      case '3 times a day':
        return 3;
      case '4 times a day':
        return 4;
      default:
        return 0;
    }
  }

  int notificationId(String value) {
    var hash = 0x811C9DC5;

    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    return hash;
  }

  TimeOfDay parseTime(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(value.trim());

    if (match != null) {
      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    }

    final parts = value.split(':');

    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return defaultTimes[0];
  }

  String formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loaded) return;

    final medicine =
        MedicineService.instance.getMedicineById(widget.medicineId);

    if (medicine != null) {
      name.text = medicine.name;
      dosage.text = medicine.dosage;
      notes.text = medicine.notes;

      frequency = medicine.frequency;
      active = medicine.isActive;

      times = medicine.reminderTimes.map(parseTime).toList();

      while (times.length < timeCount) {
        times.add(defaultTimes[times.length]);
      }

      if (times.length > timeCount) {
        times = times.take(timeCount).toList();
      }
    }

    loaded = true;
  }

  void changeFrequency(String? value) {
    if (value == null) return;

    setState(() {
      frequency = value;

      while (times.length < timeCount) {
        times.add(defaultTimes[times.length]);
      }

      if (times.length > timeCount) {
        times = times.take(timeCount).toList();
      }
    });
  }

  Future<void> selectTime(int index) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: times[index],
    );

    if (selected == null || !mounted) return;

    setState(() {
      times[index] = selected;
    });
  }

  Future<void> updateMedicine(Medicine original) async {
    if (saving) return;

    if (name.text.trim().isEmpty || dosage.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter medicine name and dosage.'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final selectedTimes = times.take(timeCount).map(formatTime).toList();

      final updated = original.copyWith(
        name: name.text.trim(),
        dosage: dosage.text.trim(),
        frequency: frequency,
        reminderTime: selectedTimes.isNotEmpty ? selectedTimes.first : '',
        reminderTimes: selectedTimes,
        notes: notes.text.trim(),
        isActive: active,
      );

      // Save the updated medicine information.
      await MedicineService.instance.updateMedicine(updated);

      // Cancel the previous reminder slots.
      for (var i = 0; i < 4; i++) {
        await NotificationService.instance.cancelReminder(
          notificationId('${original.id}_dose_$i'),
        );
      }

      var allRemindersScheduled = true;

      // Schedule updated reminders only when the medicine is active.
      if (active && selectedTimes.isNotEmpty) {
        final permissionGranted =
            await NotificationService.instance.requestPermission();

        if (!permissionGranted) {
          allRemindersScheduled = false;
        } else {
          final startDate = DateTime.parse(original.startDate);

          for (var i = 0; i < selectedTimes.length; i++) {
            final selectedTime = times[i];

            final reminderDate = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            final success = await NotificationService.instance
                .scheduleDailyMedicineReminder(
              id: notificationId('${original.id}_dose_$i'),
              medicineName: updated.name,
              dateTime: reminderDate,
            );

            if (!success) {
              allRemindersScheduled = false;
            }
          }
        }
      }

      if (!mounted) return;

      final message = !active || selectedTimes.isEmpty
          ? 'Medicine updated successfully.'
          : allRemindersScheduled
              ? 'Medicine updated and reminders scheduled successfully.'
              : 'Medicine updated, but some reminders could not be scheduled. Check notification permissions.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update medicine: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    dosage.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final original =
        MedicineService.instance.getMedicineById(widget.medicineId);

    if (original == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Medicine'),
        ),
        body: const Center(
          child: Text('Medicine not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                prefixIcon: Icon(Icons.medication_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: dosage,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                prefixIcon: Icon(Icons.medical_information_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                'Once a day',
                'Twice a day',
                '3 times a day',
                '4 times a day',
                'As needed',
              ].map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: changeFrequency,
            ),
            const SizedBox(height: 18),
            if (timeCount > 0) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reminder Times',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(timeCount, (index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text('Reminder ${index + 1}'),
                    subtitle: Text(formatTime(times[index])),
                    trailing: const Icon(Icons.edit),
                    onTap: () => selectTime(index),
                  ),
                );
              }),
            ] else ...[
              const Text(
                'As needed: No fixed reminder times will be scheduled.',
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              value: active,
              onChanged: (value) {
                setState(() {
                  active = value;
                });
              },
              title: const Text('Medicine active'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saving ? null : () => updateMedicine(original),
                icon: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(saving ? 'Updating...' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
