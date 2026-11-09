import 'package:flutter/material.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/widgets/custom_app_bar.dart';

class FeaturePage extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  const FeaturePage(
      {super.key,
      required this.title,
      required this.child,
      this.actions,
      this.bottomNavigationBar});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(title: title, actions: actions),
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background, AppColors.backgroundDark])),
          child: SafeArea(child: child)));
}
