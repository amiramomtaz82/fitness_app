import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../generated/locale_keys.g.dart';

const foodDetailsPanel = Color(0xFF242424);

final foodChipBlur = ImageFilter.blur(sigmaX: 10, sigmaY: 10);

final foodCaptionBlur = ImageFilter.blur(sigmaX: 14, sigmaY: 14);

final foodCardBlur = ImageFilter.blur(sigmaX: 16, sigmaY: 16);

class FoodNutritionSample {
  const FoodNutritionSample(this.value, this.label);

  final String value;
  final String label;
}

List<FoodNutritionSample> foodNutritionSamples() {
  return const [
    FoodNutritionSample('350 kcal', LocaleKeys.food_energy),
    FoodNutritionSample('25 g', LocaleKeys.food_protein),
    FoodNutritionSample('40 g', LocaleKeys.food_carbs),
    FoodNutritionSample('12 g', LocaleKeys.food_fat),
  ];
}

class FoodNutritionRow extends StatelessWidget {
  const FoodNutritionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final sample in foodNutritionSamples())
          FoodNutritionChip(sample: sample),
      ],
    );
  }
}

class FoodNutritionChip extends StatelessWidget {
  const FoodNutritionChip({super.key, required this.sample});

  final FoodNutritionSample sample;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.r,
      height: 64.r,
      child: ClipOval(
        child: BackdropFilter(
          filter: foodChipBlur,
          child: FoodNutritionChipFill(sample: sample),
        ),
      ),
    );
  }
}

class FoodNutritionChipFill extends StatelessWidget {
  const FoodNutritionChipFill({super.key, required this.sample});

  final FoodNutritionSample sample;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: nutritionChipDecoration(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: FoodNutritionChipLabel(sample: sample),
        ),
      ),
    );
  }
}

BoxDecoration nutritionChipDecoration() {
  return BoxDecoration(
    shape: BoxShape.circle,
    color: foodDetailsPanel.withValues(alpha: 0.5),
    border: Border.all(
      color: AppColors.grey.withValues(alpha: 0.55),
      width: 0.5,
    ),
  );
}

class FoodNutritionChipLabel extends StatelessWidget {
  const FoodNutritionChipLabel({super.key, required this.sample});

  final FoodNutritionSample sample;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FoodNutritionFittedLine(
          text: sample.value,
          style: AppTextStyles.white14bold.copyWith(height: 1),
        ),
        SizedBox(height: 2.h),
        FoodNutritionFittedLine(
          text: sample.label.tr(),
          style: AppTextStyles.orange12regular.copyWith(
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class FoodNutritionFittedLine extends StatelessWidget {
  const FoodNutritionFittedLine({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 12;
    final lineHeight = fontSize * (style.height ?? 1);
    return SizedBox(
      width: double.infinity,
      height: lineHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(text, softWrap: false, style: style),
      ),
    );
  }
}

class FoodNutritionNote extends StatelessWidget {
  const FoodNutritionNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Text(
        LocaleKeys.food_nutrition_note.tr(),
        style: nutritionNoteStyle(context),
      ),
    );
  }
}

TextStyle nutritionNoteStyle(BuildContext context) {
  final style = Theme.of(context).textTheme.bodySmall ?? const TextStyle();
  return style.copyWith(color: AppColors.grey);
}
