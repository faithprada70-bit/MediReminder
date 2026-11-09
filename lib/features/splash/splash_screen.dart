import 'package:flutter/material.dart';
import 'package:medi_reminder/core/constants/app_constants.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final seen =
        StorageService.instance.getBool(AppConstants.onboardingSeenKey);
    final route = !seen
        ? AppRoutes.onboarding
        : AuthService.instance.isLoggedIn()
            ? AppRoutes.home
            : AppRoutes.login;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                AppColors.background,
                Color(0xFF29104E),
                AppColors.backgroundDark
              ])),
          child: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: .2),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: .5),
                              blurRadius: 40)
                        ]),
                    child: const Icon(Icons.favorite,
                        size: 62, color: AppColors.primaryLight)),
                const SizedBox(height: 22),
                const Text('MediReminder',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text(AppConstants.tagline,
                    style: TextStyle(color: AppColors.primaryLight)),
                const SizedBox(height: 52),
                const SizedBox(
                    width: 130,
                    child: LinearProgressIndicator(
                        color: AppColors.primaryLight,
                        backgroundColor: AppColors.card)),
              ]))));
}
