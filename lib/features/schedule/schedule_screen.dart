import 'package:flutter/material.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/widgets/feature_page.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final meds = MedicineService.instance
        .getMedicines()
        .where((m) => m.isActive)
        .toList()
      ..sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
    return FeaturePage(
        title: 'My Schedule',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            MaterialLocalizations.of(context)
                                .formatMediumDate(DateTime.now()),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Today’s medicine schedule',
                            style: TextStyle(color: AppColors.muted)),
                      ]))),
          const SizedBox(height: 12),
          const Text('Upcoming Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (meds.isEmpty)
            const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No active medicines scheduled.',
                    style: TextStyle(color: AppColors.muted))),
          ...meds.map((m) => Card(
              child: ListTile(
                  leading:
                      const Icon(Icons.alarm, color: AppColors.primaryLight),
                  title: Text(m.reminderTime),
                  subtitle: Text('${m.name} • ${m.dosage}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.medicineDetails,
                      arguments: m.id)))),
        ]));
  }
}
