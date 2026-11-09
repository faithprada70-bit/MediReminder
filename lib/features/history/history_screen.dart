import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/widgets/bottom_nav_bar.dart';
import 'package:medi_reminder/widgets/empty_state.dart';
import 'package:medi_reminder/widgets/feature_page.dart';
import 'package:medi_reminder/widgets/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    await MedicineService.instance.reconcileMissedDoses();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = MedicineService.instance.getHistory();

    final list = filter == 'All'
        ? all
        : all.where((entry) => entry.status == filter).toList();

    return FeaturePage(
      title: 'Medication History',
      bottomNavigationBar: const BottomNavBar(selectedIndex: 1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'Taken', label: Text('Taken')),
                ButtonSegment(value: 'Missed', label: Text('Missed')),
              ],
              selected: {filter},
              onSelectionChanged: (value) {
                setState(() {
                  filter = value.first;
                });
              },
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: EmptyState(
                      title: 'No History Yet',
                      message: 'Medicine actions will appear here.',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshHistory,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: list.map((entry) {
                        final date = DateTime.tryParse(entry.dateTime);

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              entry.status == 'Taken'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: entry.status == 'Taken'
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            title: Text(entry.medicineName),
                            subtitle: Text(
                              date == null
                                  ? entry.dateTime
                                  : DateFormat('MMM d, yyyy • h:mm a')
                                      .format(date),
                            ),
                            trailing: StatusBadge(entry.status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
