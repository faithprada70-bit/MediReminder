import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const title = TextStyle(
      fontSize: 27, fontWeight: FontWeight.w800, color: AppColors.text);
  static const heading = TextStyle(
      fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.text);
  static const section = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text);
  static const body =
      TextStyle(fontSize: 14, height: 1.45, color: AppColors.text);
  static const small = TextStyle(fontSize: 12, color: AppColors.muted);
  static const button = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text);
  static const caption = TextStyle(fontSize: 11, color: AppColors.muted);
}
