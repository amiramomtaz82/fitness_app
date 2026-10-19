import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Fitness Orange Accents (From Figma)
  static const Color orange = Color(0xFFFF4100); // Figma Primary CTA
  static const Color darkOrange = Color(
    0xFFFF6A00,
  ); // Figma Secondary / Gradient
  static const Color lightOrange = Color(0xFFFF8E63);

  // Background & Surfaces (From Figma)
  // Background & Surfaces
  static const Color inputFill = Color(0xFF181A1C);

  // Opacity variants for inputs & selector tiles:
  static const Color inputTransparent = Colors.transparent;
  static const Color inputTranslucent = Color(0x801C1C1E);

  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFF000000); // Figma Pitch Black Canvas
  static const Color surface = Color(0xFF1C1C1E); // Bottom Nav / Containers
  static const Color card = Color(0xFF1E1E22); // Workout cards
  // Input fields
  static const Color border = Color(0xFFD9D9D9); // Borders & dividers

  // Typography & Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF535353);
  static const Color grey = Color(0xFFD3D3D3);
  static const Color hintGrey = Color(0xFF6E6E75);

  // Status
  static const Color error = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);

  // Gradient (From Figma CTA / workout tiles)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6A00), Color(0xFFFF4100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
