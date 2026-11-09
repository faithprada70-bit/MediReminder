import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  const AppButton(
      {super.key,
      required this.title,
      this.onPressed,
      this.icon,
      this.loading = false});
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      height: 49,
      child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                AppColors.primaryLight,
                AppColors.primary,
                AppColors.primaryDark
              ]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: .22),
                    blurRadius: 16)
              ]),
          child: ElevatedButton.icon(
              onPressed: loading ? null : onPressed,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
              label: Text(title),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))))));
}
