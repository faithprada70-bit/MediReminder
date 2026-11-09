import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/notification_service.dart';
import 'package:medi_reminder/services/storage_service.dart';
import 'package:medi_reminder/widgets/feature_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool sound = true;
  bool darkMode = true;

  @override
  void initState() {
    super.initState();

    final s = StorageService.instance;
    notifications = s.getBool('notifications_enabled', fallback: true);
    sound = s.getBool('reminder_sound', fallback: true);
    darkMode = s.getBool('dark_mode', fallback: true);
  }

  Future<void> save(String key, bool value) async {
    await StorageService.instance.setBool(key, value);
  }

  Future<void> updateNotifications(bool value) async {
    setState(() {
      notifications = value;
    });

    await save('notifications_enabled', value);

    if (!mounted) {
      return;
    }

    if (value) {
      await NotificationService.instance.requestPermission();
    } else {
      await NotificationService.instance.cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeaturePage(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              secondary: const Icon(
                Icons.notifications_active,
                color: AppColors.primaryLight,
              ),
              value: notifications,
              onChanged: updateNotifications,
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Reminder Sound'),
              secondary: const Icon(
                Icons.volume_up,
                color: AppColors.primaryLight,
              ),
              value: sound,
              onChanged: (v) {
                setState(() {
                  sound = v;
                });
                save('reminder_sound', v);
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(
                Icons.dark_mode,
                color: AppColors.primaryLight,
              ),
              value: darkMode,
              onChanged: (v) {
                setState(() {
                  darkMode = v;
                });
                save('dark_mode', v);
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Language'),
              subtitle: const Text('English'),
              leading: const Icon(
                Icons.language,
                color: AppColors.primaryLight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'English is currently the available language.',
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Backup Data'),
              leading: const Icon(
                Icons.backup,
                color: AppColors.primaryLight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Local data is stored on this device. '
                      'Export backup is not included in this prototype.',
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Restore Data'),
              leading: const Icon(
                Icons.restore,
                color: AppColors.primaryLight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No backup file selected.'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Clear Cache'),
              leading: const Icon(
                Icons.cleaning_services,
                color: AppColors.primaryLight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'There is no separate cache to clear. '
                      'Your saved records were kept.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
