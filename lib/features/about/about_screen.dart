import 'package:flutter/material.dart';
import 'package:medi_reminder/core/constants/app_constants.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/widgets/feature_page.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePage(
      title: 'About MediReminder',
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 78,
                color: AppColors.primaryLight,
              ),
              SizedBox(height: 15),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.muted),
              ),
              SizedBox(height: 22),
              Text(
                'A smart medicine reminder and health tracker for a healthier you.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              Text(
                'Made with ❤️\nfor a better tomorrow.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
