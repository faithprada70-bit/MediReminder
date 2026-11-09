import 'package:flutter/material.dart';
import 'package:medi_reminder/core/routes/app_routes.dart';
import 'package:medi_reminder/core/theme/app_colors.dart';
import 'package:medi_reminder/core/utils/validators.dart';
import 'package:medi_reminder/services/auth_service.dart';
import 'package:medi_reminder/widgets/app_button.dart';
import 'package:medi_reminder/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool obscure = true, remember = true, loading = false;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!form.currentState!.validate()) return;
    setState(() => loading = true);
    final error = await AuthService.instance
        .login(email: email.text, password: password.text);
    if (!mounted) return;
    setState(() => loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Form(
                          key: form,
                          child: Column(children: [
                            const Icon(Icons.favorite,
                                color: AppColors.primaryLight, size: 65),
                            const SizedBox(height: 10),
                            const Text('MediReminder',
                                style: TextStyle(
                                    fontSize: 27, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 28),
                            const Text('Welcome Back!',
                                style: TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.bold)),
                            const Text('Log in to continue',
                                style: TextStyle(color: AppColors.muted)),
                            const SizedBox(height: 25),
                            AppTextField(
                                label: 'Email Address',
                                hint: 'you@example.com',
                                controller: email,
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email),
                            AppTextField(
                                label: 'Password',
                                controller: password,
                                icon: Icons.lock_outline,
                                obscureText: obscure,
                                suffix: IconButton(
                                    icon: Icon(obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () =>
                                        setState(() => obscure = !obscure)),
                                validator: (v) =>
                                    Validators.required(v, 'your password')),
                            CheckboxListTile(
                                value: remember,
                                onChanged: (v) =>
                                    setState(() => remember = v ?? false),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Remember Me',
                                    style: TextStyle(fontSize: 13)),
                                controlAffinity:
                                    ListTileControlAffinity.leading),
                            Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, AppRoutes.forgotPassword),
                                    child: const Text('Forgot Password?'))),
                            AppButton(
                                title: 'Login',
                                loading: loading,
                                onPressed: login),
                            const SizedBox(height: 18),
                            TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.signup),
                                child: const Text(
                                    "Don't have an account? Sign Up")),
                          ])))))));
}
