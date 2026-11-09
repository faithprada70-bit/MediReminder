import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/widgets/bottom_nav_bar.dart';
import 'package:medi_reminder/widgets/feature_page.dart';
import 'package:medi_reminder/widgets/stat_card.dart';

class HealthInsightsScreen extends StatelessWidget {
  const HealthInsightsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final history = MedicineService.instance.getHistory();
    final taken = history.where((e) => e.status == 'Taken').length;
    final missed = history.where((e) => e.status == 'Missed').length;
    final total = taken + missed;
    final adherence = total == 0 ? 0 : (taken * 100 ~/ total);
    return FeaturePage(
        title: 'Health Insights',
        bottomNavigationBar: const BottomNavBar(selectedIndex: 2),
        child: ListView(padding: const EdgeInsets.all(18), children: [
          const Text('Your Health Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(children: [
                    SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(fit: StackFit.expand, children: [
                          CircularProgressIndicator(
                              value: adherence / 100,
                              strokeWidth: 12,
                              backgroundColor: AppColors.cardLight,
                              color: AppColors.primaryLight),
                          Center(
                              child: Text('$adherence%\\nOn Track',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold))),
                        ])),
                    const SizedBox(height: 12),
                    const Text('Medicine Adherence',
                        style: TextStyle(color: AppColors.muted)),
                  ]))),
          Row(children: [
            Expanded(
                child: StatCard(
                    title: 'Taken',
                    value: '$taken',
                    icon: Icons.check_circle_outline)),
            const SizedBox(width: 10),
            Expanded(
                child: StatCard(
                    title: 'Missed',
                    value: '$missed',
                    icon: Icons.cancel_outlined)),
          ]),
          const SizedBox(height: 16),
          const Card(
              child: ListTile(
                  leading:
                      Icon(Icons.lightbulb_outline, color: AppColors.warning),
                  title: Text('Health Tip'),
                  subtitle: Text(
                      'Keep your medicine schedule organized and follow the directions provided by your healthcare professional.'))),
          const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                  'Insights are based only on actions recorded in this app.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11))),
        ]));
  }
}
