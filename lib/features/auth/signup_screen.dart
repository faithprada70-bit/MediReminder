import 'package:flutter/material.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/utils/validators.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';
import 'package:medi_reminder/widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final form = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool hide1 = true;
  bool hide2 = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;

    final error = await AuthService.instance.register(
      name: name.text,
      email: email.text,
      password: password.text,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: form,
            child: Column(
              children: [
                const SizedBox(height: 15),
                const Icon(
                  Icons.favorite,
                  size: 54,
                  color: Color(0xFFBD79FF),
                ),
                const Text(
                  'Start your health journey',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 25),
                AppTextField(
                  label: 'Full Name',
                  controller: name,
                  icon: Icons.person_outline,
                  validator: (v) => Validators.required(v, 'your name'),
                ),
                AppTextField(
                  label: 'Email Address',
                  controller: email,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AppTextField(
                  label: 'Password',
                  controller: password,
                  icon: Icons.lock_outline,
                  obscureText: hide1,
                  suffix: IconButton(
                    icon: Icon(
                      hide1 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => hide1 = !hide1);
                    },
                  ),
                  validator: Validators.password,
                ),
                AppTextField(
                  label: 'Confirm Password',
                  controller: confirm,
                  icon: Icons.lock_outline,
                  obscureText: hide2,
                  suffix: IconButton(
                    icon: Icon(
                      hide2 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => hide2 = !hide2);
                    },
                  ),
                  validator: (v) =>
                      v != password.text ? 'Passwords do not match.' : null,
                ),
                const SizedBox(height: 8),
                AppButton(
                  title: 'Sign Up',
                  onPressed: submit,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
