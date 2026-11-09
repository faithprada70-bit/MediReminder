import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/widgets/feature_page.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final meds = MedicineService.instance
        .getMedicines()
        .where((m) => m.isActive)
        .toList();
    return FeaturePage(
        title: 'Notifications',
        child: ListView(padding: const EdgeInsets.all(14), children: [
          if (meds.isEmpty)
            const Padding(
                padding: EdgeInsets.all(25),
                child: Text('No medicine reminders yet.',
                    style: TextStyle(color: AppColors.muted))),
          ...meds.map((m) => Card(
              child: ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.notifications, color: Colors.white)),
                  title: const Text('Medicine Reminder'),
                  subtitle: Text('${m.name} • ${m.reminderTime}')))),
          const Card(
              child: ListTile(
                  leading: Icon(Icons.favorite, color: AppColors.secondary),
                  title: Text('Health Tip'),
                  subtitle: Text('Keep your schedule updated.'))),
        ]));
  }
}
