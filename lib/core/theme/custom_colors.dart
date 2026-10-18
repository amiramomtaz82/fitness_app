import 'package:flutter/material.dart';
import 'app_colors.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color inputFill;
  final Color inputFillTranslucent;
  final Color hint;
  final Color grey;
  final Color darkGrey;
  final Color white;
  final Color error;
  final Color success;

  const CustomColors({
    required this.inputFillTranslucent,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.inputFill,
    required this.hint,
    required this.grey,
    required this.darkGrey,
    required this.white,
    required this.error,
    required this.success,
  });

  // Dark Theme Tokens (Figma Design)
  static const CustomColors dark = CustomColors(
    primary: AppColors.orange,
    secondary: AppColors.darkOrange,
    background: AppColors.background,
    surface: AppColors.surface,
    card: AppColors.card,
    textPrimary: AppColors.white,
    textSecondary: AppColors.grey,
    border: AppColors.border,
    inputFill: AppColors.inputTransparent,
    inputFillTranslucent: AppColors.inputTranslucent,
    hint: AppColors.hintGrey,
    grey: AppColors.grey,
    darkGrey: AppColors.darkGrey,
    white: AppColors.white,
    error: AppColors.error,
    success: AppColors.success,
  );

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? inputFill,
  Color? inputFillTranslucent,
    Color? hint,
    Color? grey,
    Color? darkGrey,
    Color? white,
    Color? error,
    Color? success,
  }) {
    return CustomColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      inputFill: inputFill ?? this.inputFill,
      inputFillTranslucent: inputFillTranslucent ?? this.inputFillTranslucent,
      hint: hint ?? this.hint,
      grey: grey ?? this.grey,
      darkGrey: darkGrey ?? this.darkGrey,
      white: white ?? this.white,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(covariant ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputFillTranslucent: Color.lerp(inputFillTranslucent, other.inputFillTranslucent, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      darkGrey: Color.lerp(darkGrey, other.darkGrey, t)!,
      white: Color.lerp(white, other.white, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
