import 'package:flutter/material.dart';
import 'package:medi_reminder/core/utils/validators.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';
import 'package:medi_reminder/widgets/app_text_field.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final form = GlobalKey<FormState>();

  late final name = TextEditingController(
    text: AuthService.instance.currentUser?['name'] ?? '',
  );

  late final email = TextEditingController(
    text: AuthService.instance.currentUser?['email'] ?? '',
  );

  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (!form.currentState!.validate()) return;

    setState(() => loading = true);

    final error = await AuthService.instance.updateProfile(
      name: name.text.trim(),
      email: email.text.trim(),
    );

    if (!mounted) return;

    setState(() => loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final originalEmail = AuthService.instance.currentUser?['email'] ?? '';

    final emailChanged =
        originalEmail.toLowerCase() != email.text.trim().toLowerCase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          emailChanged
              ? 'Profile updated. Check your new email for verification.'
              : 'Profile updated successfully.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: form,
          child: Column(
            children: [
              AppTextField(
                label: 'Full Name',
                controller: name,
                icon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'your name'),
              ),
              AppTextField(
                label: 'Email',
                controller: email,
                icon: Icons.mail_outline,
                validator: Validators.email,
              ),
              AppButton(
                title: loading ? 'Saving...' : 'Save Changes',
                icon: Icons.save,
                onPressed: loading ? null : saveChanges,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
