import 'package:flutter/material.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/widgets/bottom_nav_bar.dart';
import 'package:medi_reminder/widgets/feature_page.dart';
import 'package:medi_reminder/widgets/medicine_card.dart';
import 'package:medi_reminder/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void refresh() => setState(() {});
  @override
  Widget build(BuildContext context) {
    final meds = MedicineService.instance
        .getMedicines()
        .where((m) => m.isActive)
        .toList();
    final history = MedicineService.instance.getHistory();
    final taken = history.where((h) => h.status == 'Taken').length;
    final percent = history.isEmpty ? 0 : (taken * 100 ~/ history.length);
    return FeaturePage(
        title: 'MediReminder',
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none))
        ],
        bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
        child: RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView(padding: const EdgeInsets.all(18), children: [
              Text('Hello, ${AuthService.instance.currentName}! 👋',
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold)),
              const Text('Stay on track with your medicine.',
                  style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 20),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(17),
                      child: Row(children: [
                        const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.medication, color: Colors.white)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              const Text("Today's medicines",
                                  style: TextStyle(
                                      color: AppColors.muted, fontSize: 12)),
                              Text(
                                  meds.isEmpty
                                      ? 'No upcoming medicine'
                                      : '${meds.first.name} • ${meds.first.reminderTime}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ])),
                        IconButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.schedule),
                            icon: const Icon(Icons.chevron_right)),
                      ]))),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(
                    child: StatCard(
                        title: 'Adherence',
                        value: '$percent%',
                        icon: Icons.favorite_outline)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        title: 'Active medicines',
                        value: '${meds.length}',
                        icon: Icons.medication_outlined)),
              ]),
              const SizedBox(height: 22),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Quick Actions',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.myMedicines),
                    child: const Text('View all')),
              ]),
              GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _ActionTile(
                        icon: Icons.add_circle_outline,
                        label: 'Add Medicine',
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, AppRoutes.addMedicine);
                          refresh();
                        }),
                    _ActionTile(
                        icon: Icons.calendar_month,
                        label: 'View Schedule',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.schedule)),
                    _ActionTile(
                        icon: Icons.insights,
                        label: 'Health Insights',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.insights)),
                    _ActionTile(
                        icon: Icons.medication_outlined,
                        label: 'My Medicines',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.myMedicines)),
                  ]),
              const SizedBox(height: 20),
              const Text('Your Medicines',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              if (meds.isEmpty)
                const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                        'Add your first medicine to start organizing your schedule.',
                        style: TextStyle(color: AppColors.muted))),
              ...meds.take(3).map((m) => MedicineCard(
                  medicine: m,
                  onTap: () => Navigator.pushNamed(
                          context, AppRoutes.medicineDetails,
                          arguments: m.id)
                      .then((_) => refresh()),
                  onToggle: (v) async {
                    await MedicineService.instance.toggleMedicine(m.id, v);
                    refresh();
                  })),
            ])));
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: AppColors.primaryLight, size: 20),
        const SizedBox(width: 7),
        Flexible(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12))),
      ])));
}
