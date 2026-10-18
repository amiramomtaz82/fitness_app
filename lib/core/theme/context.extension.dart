import 'package:flutter/material.dart';
import 'custom_colors.dart' show CustomColors;

extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Single dark theme tokens matching Figma
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>() ?? CustomColors.dark;

  CustomColors get colors => customColors;
}