import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/medicine_service.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.medication_rounded,
            color: AppColors.primaryLight,
          ),
        ),
        title: Text(
          medicine.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${medicine.dosage} • ${medicine.frequency}',
          style: const TextStyle(
            color: AppColors.muted,
          ),
        ),
        trailing: Switch(
          value: medicine.isActive,
          onChanged: onToggle,
        ),
      ),
    );
  }
}
