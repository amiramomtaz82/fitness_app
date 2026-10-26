import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_colors.dart';
import 'text_styles.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme =>
      _buildTheme(brightness: Brightness.dark, colors: CustomColors.dark);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required CustomColors colors,
  }) {
    final baseInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.r),
      gapPadding: 5,
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      surface: colors.background,
      error: colors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headLineLarge.copyWith(
          color: colors.textPrimary,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: colors.textPrimary,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: colors.textPrimary,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.darkGrey),
        bodySmall: AppTextStyles.caption.copyWith(color: colors.grey),
        labelLarge: AppTextStyles.button.copyWith(color: colors.white),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colors.darkGrey),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(fontSize: 14, color: colors.grey),
        errorStyle: TextStyle(fontSize: 12, color: colors.error),
        border: baseInputBorder.copyWith(
          borderSide: BorderSide(color: colors.border, width: 1.2),
        ),
        enabledBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: colors.border, width: 1.2),
        ),
        focusedBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 1.2),
        ),
        focusedErrorBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.white,
          disabledBackgroundColor: colors.grey,
          disabledForegroundColor: colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.grey,
          minimumSize: const Size(double.infinity, 54),
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.primary,
        contentTextStyle: TextStyle(
          color: colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        height: 70,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colors.primary : colors.grey,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.grey,
          );
        }),
      ),
    );
  }
}
