import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData? icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  const AppTextField(
      {super.key,
      required this.label,
      required this.controller,
      this.hint,
      this.icon,
      this.obscureText = false,
      this.suffix,
      this.keyboardType,
      this.validator,
      this.maxLines = 1});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: icon == null ? null : Icon(icon),
              suffixIcon: suffix)));
}
