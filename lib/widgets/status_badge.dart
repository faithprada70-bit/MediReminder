import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  const StatusBadge(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final color =
        label.toLowerCase() == 'taken' || label.toLowerCase() == 'active'
            ? AppColors.success
            : label.toLowerCase() == 'missed'
                ? AppColors.error
                : AppColors.muted;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)));
  }
}
