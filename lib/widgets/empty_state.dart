import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String title, message;
  const EmptyState({super.key, required this.title, required this.message});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.medication_outlined,
            size: 58, color: AppColors.primaryLight),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted)),
      ]));
}
