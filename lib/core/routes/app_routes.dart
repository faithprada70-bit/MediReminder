import 'package:flutter/material.dart';
import 'package:medi_reminder/features/about/about_screen.dart';
import 'package:medi_reminder/features/auth/forgot_password_screen.dart';
import 'package:medi_reminder/features/auth/login_screen.dart';
import 'package:medi_reminder/features/auth/signup_screen.dart';
import 'package:medi_reminder/features/help/help_support_screen.dart';
import 'package:medi_reminder/features/home/home_screen.dart';
import 'package:medi_reminder/features/history/history_screen.dart';
import 'package:medi_reminder/features/insights/health_insights_screen.dart';
import 'package:medi_reminder/features/medicine/add_medicine_screen.dart';
import 'package:medi_reminder/features/medicine/edit_medicine_screen.dart';
import 'package:medi_reminder/features/medicine/medicine_details_screen.dart';
import 'package:medi_reminder/features/medicine/medicine_reminder_screen.dart';
import 'package:medi_reminder/features/medicine/my_medicines_screen.dart';
import 'package:medi_reminder/features/notifications/notifications_screen.dart';
import 'package:medi_reminder/features/onboarding/onboarding_screen.dart';
import 'package:medi_reminder/features/profile/personal_information_screen.dart';
import 'package:medi_reminder/features/profile/profile_screen.dart';
import 'package:medi_reminder/features/profile/settings_screen.dart';
import 'package:medi_reminder/features/schedule/schedule_screen.dart';
import 'package:medi_reminder/features/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/splash',
      onboarding = '/onboarding',
      login = '/login',
      signup = '/signup',
      forgotPassword = '/forgot-password',
      home = '/home',
      addMedicine = '/add-medicine',
      myMedicines = '/my-medicines',
      medicineDetails = '/medicine-details',
      editMedicine = '/edit-medicine',
      reminder = '/reminder',
      history = '/history',
      insights = '/insights',
      schedule = '/schedule',
      notifications = '/notifications',
      profile = '/profile',
      personalInformation = '/personal-information',
      settings = '/settings',
      about = '/about',
      help = '/help';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case signup:
        page = const SignupScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case home:
        page = const HomeScreen();
        break;
      case addMedicine:
        page = const AddMedicineScreen();
        break;
      case myMedicines:
        page = const MyMedicinesScreen();
        break;
      case medicineDetails:
        page = MedicineDetailsScreen(medicineId: args as String);
        break;
      case editMedicine:
        page = EditMedicineScreen(medicineId: args as String);
        break;
      case reminder:
        page = MedicineReminderScreen(medicineId: args as String);
        break;
      case history:
        page = const HistoryScreen();
        break;
      case insights:
        page = const HealthInsightsScreen();
        break;
      case schedule:
        page = const ScheduleScreen();
        break;
      case notifications:
        page = const NotificationsScreen();
        break;
      case profile:
        page = const ProfileScreen();
        break;
      case personalInformation:
        page = const PersonalInformationScreen();
        break;
      case AppRoutes.settings:
        page = const SettingsScreen();
        break;
      case about:
        page = const AboutScreen();
        break;
      case help:
        page = const HelpSupportScreen();
        break;
      default:
        page = const LoginScreen();
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
