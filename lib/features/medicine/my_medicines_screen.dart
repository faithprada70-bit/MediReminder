import 'package:flutter/material.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';

class MyMedicinesScreen extends StatefulWidget {
  const MyMedicinesScreen({super.key});

  @override
  State<MyMedicinesScreen> createState() => _MyMedicinesScreenState();
}

class _MyMedicinesScreenState extends State<MyMedicinesScreen> {
  List<Medicine> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    _medicines = MedicineService.instance.getMedicines();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleMedicine(Medicine medicine, bool active) async {
    final success = await MedicineService.instance.toggleMedicine(
      medicine.id,
      active,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            active
                ? 'Medicine activated, but reminders could not be scheduled. Check notification permissions.'
                : 'Medicine deactivated, but some reminders may not have been cancelled.',
          ),
        ),
      );
    }

    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medicines'),
      ),
      body: _medicines.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No Medicines Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your medicines and vitamins will appear here after you add them.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final medicine = _medicines[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medication_outlined),
                    ),
                    title: Text(
                      medicine.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${medicine.dosage} • ${medicine.frequency}',
                    ),
                    trailing: Switch(
                      value: medicine.isActive,
                      onChanged: (value) {
                        _toggleMedicine(medicine, value);
                      },
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.medicineDetails,
                        arguments: medicine,
                      ).then((_) => _loadMedicines());
                    },
                  ),
                );
              },
            ),
    );
  }
}
