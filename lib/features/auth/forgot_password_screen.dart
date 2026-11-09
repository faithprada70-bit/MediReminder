import 'package:flutter/material.dart';
import 'package:medi_reminder/core/utils/validators.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';
import 'package:medi_reminder/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> reset() async {
    if (!form.currentState!.validate()) return;

    setState(() => loading = true);

    final error = await AuthService.instance.resetPassword(
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists for this email, a reset link will be sent.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: form,
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Icon(
                Icons.lock_reset,
                size: 65,
                color: Color(0xFFBD79FF),
              ),
              const SizedBox(height: 16),
              const Text(
                'Forgot your password?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your registered email address. '
                'We will send you a link to reset your password.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              AppTextField(
                label: 'Registered Email',
                controller: email,
                icon: Icons.mail_outline,
                validator: Validators.email,
              ),
              const SizedBox(height: 15),
              AppButton(
                title: loading ? 'Sending...' : 'Send Reset Link',
                icon: Icons.email_outlined,
                onPressed: loading ? null : reset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
