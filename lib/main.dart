import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:medi_reminder/firebase_options.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_theme.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/services/medicine_service.dart';
import 'package:medi_reminder/services/notification_service.dart';
import 'package:medi_reminder/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize app services.
  await StorageService.instance.init();
  await AuthService.instance.init();
  await MedicineService.instance.init();
  await NotificationService.instance.initialize();

  runApp(const MediReminderApp());
}

class MediReminderApp extends StatefulWidget {
  const MediReminderApp({super.key});

  @override
  State<MediReminderApp> createState() => _MediReminderAppState();
}

class _MediReminderAppState extends State<MediReminderApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Listen for app lifecycle changes.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check overdue doses when the user returns to the app.
    if (state == AppLifecycleState.resumed) {
      unawaited(
        MedicineService.instance.reconcileMissedDoses(),
      );
    }
  }

  @override
  void dispose() {
    // Stop listening when the app is disposed.
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediReminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
