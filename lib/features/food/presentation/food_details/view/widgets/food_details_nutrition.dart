import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/locale_keys.g.dart';

const foodDetailsPanel = Color(0xFF242424);

final foodCaptionBlur = ImageFilter.blur(sigmaX: 14, sigmaY: 14);

final foodCardBlur = ImageFilter.blur(sigmaX: 16, sigmaY: 16);

class FoodNutritionUnavailable extends StatelessWidget {
  const FoodNutritionUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      LocaleKeys.food_nutrition_note.tr(),
      maxLines: 3,
      style: nutritionUnavailableStyle(context),
    );
  }
}

TextStyle nutritionUnavailableStyle(BuildContext context) {
  final style = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
  return style.copyWith(color: AppColors.grey);
}
