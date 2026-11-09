import 'package:flutter/material.dart';
import 'package:medi_reminder/core/constants/app_constants.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/features/onboarding/onboarding_page.dart';
import 'package:medi_reminder/services/storage_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int index = 0;
  final pages = const [
    OnboardingPage(
        icon: Icons.medication_rounded,
        title: 'Never Miss Your Medicine',
        description:
            'Set reminders and keep track of your medications with ease.'),
    OnboardingPage(
        icon: Icons.calendar_month_rounded,
        title: 'Track Your Health Journey',
        description: 'View your history and monitor your progress.'),
    OnboardingPage(
        icon: Icons.verified_user_rounded,
        title: 'Stay Healthy Always',
        description: 'A healthier you, one reminder at a time.'),
  ];
  Future<void> finish() async {
    await StorageService.instance.setBool(AppConstants.onboardingSeenKey, true);
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: finish, child: const Text('Skip'))),
                Expanded(
                    child: PageView(
                        controller: controller,
                        onPageChanged: (v) => setState(() => index = v),
                        children: pages)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        3,
                        (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(4),
                            width: index == i ? 22 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: index == i
                                    ? AppColors.primaryLight
                                    : AppColors.muted,
                                borderRadius: BorderRadius.circular(10))))),
                const SizedBox(height: 24),
                AppButton(
                    title: index == 2 ? 'Get Started' : 'Next',
                    onPressed: () => index == 2
                        ? finish()
                        : controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut)),
                const SizedBox(height: 10),
              ]))));
}
