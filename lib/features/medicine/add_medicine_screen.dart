import 'package:flutter/material.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/services/notification_service.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final form = GlobalKey<FormState>();

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

  List<TimeOfDay> times = [
    defaultTimes[0],
  ];

  DateTime start = DateTime.now();
  DateTime? end;

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

  String dateString(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
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

  Future<void> selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) return;

    setState(() {
      start = selected;

      if (end != null && end!.isBefore(start)) {
        end = null;
      }
    });
  }

  Future<void> selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: end ?? start,
      firstDate: start,
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) return;

    setState(() {
      end = selected;
    });
  }

  Future<void> save() async {
    if (saving) return;

    if (!form.currentState!.validate()) return;

    if (end != null && end!.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date.'),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final selectedTimes = times.take(timeCount).map(formatTime).toList();

      // Save the medicine first.
      final medicine = await MedicineService.instance.addMedicine(
        name: name.text.trim(),
        dosage: dosage.text.trim(),
        frequency: frequency,
        startDate: dateString(start),
        endDate: end == null ? null : dateString(end!),
        reminderTime: selectedTimes.isNotEmpty ? selectedTimes.first : '',
        reminderTimes: selectedTimes,
        notes: notes.text.trim(),
      );

      // Check notification permission and schedule each daily reminder.
      var allRemindersScheduled = true;

      if (selectedTimes.isNotEmpty) {
        final permissionGranted =
            await NotificationService.instance.requestPermission();

        if (!permissionGranted) {
          allRemindersScheduled = false;
        } else {
          for (var i = 0; i < selectedTimes.length; i++) {
            final selectedTime = times[i];

            final scheduledDate = DateTime(
              start.year,
              start.month,
              start.day,
              selectedTime.hour,
              selectedTime.minute,
            );

            final success = await NotificationService.instance
                .scheduleDailyMedicineReminder(
              id: notificationId('${medicine.id}_dose_$i'),
              medicineName: medicine.name,
              dateTime: scheduledDate,
            );

            if (!success) {
              allRemindersScheduled = false;
            }
          }
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allRemindersScheduled
                ? 'Medicine saved and reminders scheduled successfully.'
                : 'Medicine saved, but reminders could not all be scheduled. Check notification permissions.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save medicine: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(Icons.medication_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter medicine name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: dosage,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'Example: 500 mg',
                  prefixIcon: Icon(Icons.medical_information_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter dosage.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
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
              const SizedBox(height: 20),
              const Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Start Date'),
                  subtitle: Text(dateString(start)),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: selectStartDate,
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('End Date'),
                  subtitle: Text(
                    end == null ? 'No end date' : dateString(end!),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (end != null)
                        IconButton(
                          tooltip: 'Remove end date',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              end = null;
                            });
                          },
                        ),
                      const Icon(Icons.edit_calendar),
                    ],
                  ),
                  onTap: selectEndDate,
                ),
              ),
              const SizedBox(height: 16),
              if (timeCount > 0) ...[
                const Text(
                  'Reminder Times',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional information',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: saving ? null : save,
                  icon: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    saving ? 'Saving...' : 'Save Medicine',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
