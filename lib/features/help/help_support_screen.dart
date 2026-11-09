import 'package:flutter/material.dart';
import 'package:medi_reminder/widgets/feature_page.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});
  @override
  Widget build(BuildContext context) => FeaturePage(
      title: 'Help & Support',
      child: ListView(padding: const EdgeInsets.all(16), children: [
        const ExpansionTile(title: Text('How do I add a medicine?'), children: [
          Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                  'Open My Medicines or Add Medicine, enter the details provided by your healthcare professional, then save.'))
        ]),
        const ExpansionTile(
            title: Text('Why did I not receive a reminder?'),
            children: [
              Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                      'Check notification permission and device notification settings. Battery restrictions may also affect scheduled alerts.'))
            ]),
        const ExpansionTile(title: Text('Can I edit a medicine?'), children: [
          Padding(
              padding: EdgeInsets.all(14),
              child: Text('Open the medicine details and choose Edit.'))
        ]),
        Card(
            child: ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Contact Us'),
                subtitle: const Text(
                    'Support contact is not configured in this prototype.'),
                onTap: () => _message(context))),
        Card(
            child: ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: const Text('Report a Problem'),
                onTap: () => _message(context))),
        const Card(
            child: ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Privacy Policy'),
                subtitle: Text(
                    'Local prototype: records are stored on this device.'))),
        const Card(
            child: ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text('Terms of Service'),
                subtitle: Text(
                    'Use this app as a schedule organizer, not as medical advice.'))),
      ]));
  static void _message(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Support messaging is not connected in this prototype.')));
}
