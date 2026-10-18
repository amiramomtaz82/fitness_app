import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  AppTextStyles._();

  static const TextStyle white24bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.orange,
  );

  static const TextStyle white14bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static const TextStyle white14regular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
  static const TextStyle white20bold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static const TextStyle white18regular = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static const TextStyle grey16regular = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );
  static const TextStyle grey12regular = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
  );
  static const TextStyle grey14bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.grey,
  );

  static const TextStyle orange12regular = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.orange,
  );
  static const TextStyle orange20med = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.orange,
  );
  static const TextStyle darkOrange14Bold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.darkOrange,
  );

  //============================================
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle headLineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
