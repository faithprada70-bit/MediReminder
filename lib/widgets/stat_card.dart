import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const StatCard(
      {super.key,
      required this.title,
      required this.value,
      required this.icon});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.primaryLight),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])));
}
