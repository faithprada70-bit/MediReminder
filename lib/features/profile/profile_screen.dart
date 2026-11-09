import 'package:flutter/material.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/widgets/bottom_nav_bar.dart';
import 'package:medi_reminder/widgets/feature_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => FeaturePage(
        title: 'Profile',
        bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.cardLight,
              child: Icon(
                Icons.person,
                size: 55,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                AuthService.instance.currentName,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                AuthService.instance.currentUser?['email'] ?? '',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 24),
            _ProfileTile(
              icon: Icons.person_outline,
              title: 'My Information',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.personalInformation,
              ),
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.settings,
              ),
            ),
            _ProfileTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.notifications,
              ),
            ),
            _ProfileTile(
              icon: Icons.info_outline,
              title: 'About MediReminder',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.about,
              ),
            ),
            _ProfileTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.help,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await AuthService.instance.logout();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ],
        ),
      );
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryLight),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
