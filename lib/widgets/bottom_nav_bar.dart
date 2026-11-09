import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/features/history/history_screen.dart';
import 'package:medi_reminder/features/home/home_screen.dart';
import 'package:medi_reminder/features/insights/health_insights_screen.dart';
import 'package:medi_reminder/features/profile/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({super.key, required this.selectedIndex});
  void _go(BuildContext context, int i) {
    final pages = [
      const HomeScreen(),
      const HistoryScreen(),
      const HealthInsightsScreen(),
      const ProfileScreen()
    ];
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => pages[i]));
  }

  @override
  Widget build(BuildContext context) => NavigationBar(
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.primary.withValues(alpha: .3),
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) => _go(context, i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Stats'),
            NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
          ]);
}
