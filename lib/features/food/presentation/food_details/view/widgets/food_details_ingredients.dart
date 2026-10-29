import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../domain/entities/meal_ingredient.dart';
import 'food_details_nutrition.dart';
import 'food_details_section.dart';

class FoodDetailsIngredients extends StatelessWidget {
  const FoodDetailsIngredients({super.key, required this.ingredients});

  final List<MealIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) return const SizedBox.shrink();
    return FoodDetailsSection(
      title: LocaleKeys.food_ingredients.tr(),
      child: FoodIngredientCard(ingredients: ingredients),
    );
  }
}

class FoodIngredientCard extends StatelessWidget {
  const FoodIngredientCard({super.key, required this.ingredients});

  final List<MealIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: foodCardBlur,
        child: FoodIngredientPanel(ingredients: ingredients),
      ),
    );
  }
}

class FoodIngredientPanel extends StatelessWidget {
  const FoodIngredientPanel({super.key, required this.ingredients});

  final List<MealIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ingredientPanelDecoration(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(children: ingredientRows(ingredients)),
      ),
    );
  }
}

BoxDecoration ingredientPanelDecoration() {
  return BoxDecoration(
    color: foodDetailsPanel.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(20.r),
    border: Border.all(
      color: AppColors.grey.withValues(alpha: 0.28),
      width: 0.5,
    ),
  );
}

List<Widget> ingredientRows(List<MealIngredient> ingredients) {
  return [
    for (var index = 0; index < ingredients.length; index++)
      ...ingredientBlock(ingredients[index], index == ingredients.length - 1),
  ];
}

List<Widget> ingredientBlock(MealIngredient ingredient, bool isLast) {
  return [
    FoodDetailsIngredientRow(ingredient: ingredient),
    if (!isLast) const FoodIngredientDivider(),
  ];
}

class FoodDetailsIngredientRow extends StatelessWidget {
  const FoodDetailsIngredientRow({super.key, required this.ingredient});

  final MealIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(ingredient.name, style: ingredientNameStyle(context)),
          ),
          FoodDetailsMeasure(measure: ingredient.measure),
        ],
      ),
    );
  }
}

TextStyle ingredientNameStyle(BuildContext context) {
  final style = context.textTheme.bodyLarge ?? const TextStyle();
  return style.copyWith(color: AppColors.white);
}

class FoodDetailsMeasure extends StatelessWidget {
  const FoodDetailsMeasure({super.key, required this.measure});

  final String? measure;

  @override
  Widget build(BuildContext context) {
    final value = measure?.trim() ?? '';
    if (value.isEmpty) return const SizedBox.shrink();
    return Text(value, style: measureStyle(context));
  }
}

class FoodIngredientDivider extends StatelessWidget {
  const FoodIngredientDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.grey.withValues(alpha: 0.35),
    );
  }
}

TextStyle measureStyle(BuildContext context) {
  final style = context.textTheme.bodyMedium ?? const TextStyle();
  return style.copyWith(color: AppColors.orange, fontWeight: FontWeight.w600);
}
