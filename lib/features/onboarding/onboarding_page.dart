import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title, description;
  const OnboardingPage(
      {super.key,
      required this.icon,
      required this.title,
      required this.description});
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withValues(alpha: .45),
                  AppColors.background
                ])),
            child: Icon(icon, size: 100, color: AppColors.primaryLight)),
        const SizedBox(height: 35),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.5))),
      ]);
}
