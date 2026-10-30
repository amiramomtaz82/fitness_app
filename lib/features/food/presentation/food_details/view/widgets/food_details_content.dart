import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/widgets/app_youtube_video.dart';
import '../../../../domain/entities/meal_details_entity.dart';
import '../../../../domain/entities/meal_ingredient.dart';
import 'food_details_back.dart';
import 'food_details_ingredients.dart';
import 'food_details_media.dart';
import 'food_details_nutrition.dart';

class FoodDetailsContent extends StatelessWidget {
  const FoodDetailsContent({
    super.key,
    required this.meal,
    required this.onBack,
  });

  final MealDetailsEntity meal;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 16.h),
      children: [
        FoodDetailsMedia(
          videoUrl: meal.youtubeUrl,
          thumbnailUrl: meal.thumbnailUrl,
          video: FoodDetailsPlayer(videoUrl: meal.youtubeUrl, onBack: onBack),
          caption: FoodDetailsMediaCaption(meal: meal),
        ),
        FoodDetailsIngredientBlock(ingredients: meal.ingredients),
      ],
    );
  }
}

class FoodDetailsMediaCaption extends StatelessWidget {
  const FoodDetailsMediaCaption({super.key, required this.meal});

  final MealDetailsEntity meal;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: 20.h,
      child: IgnorePointer(child: FoodDetailsCaptionColumn(meal: meal)),
    );
  }
}

class FoodDetailsCaptionColumn extends StatelessWidget {
  const FoodDetailsCaptionColumn({super.key, required this.meal});

  final MealDetailsEntity meal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FoodDetailsName(name: meal.name),
        SizedBox(height: 6.h),
        FoodDetailsSummary(text: meal.instructions),
        SizedBox(height: 12.h),
        const FoodNutritionUnavailable(),
      ],
    );
  }
}

class FoodDetailsName extends StatelessWidget {
  const FoodDetailsName({super.key, required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: foodNameStyle(context),
    );
  }
}

class FoodDetailsSummary extends StatelessWidget {
  const FoodDetailsSummary({super.key, required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final value = text?.trim() ?? '';
    if (value.isEmpty) return const SizedBox.shrink();
    return Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: foodSummaryStyle(context),
    );
  }
}

class FoodDetailsIngredientBlock extends StatelessWidget {
  const FoodDetailsIngredientBlock({super.key, required this.ingredients});

  final List<MealIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: FoodDetailsIngredients(ingredients: ingredients),
    );
  }
}

class FoodDetailsPlayer extends StatelessWidget {
  const FoodDetailsPlayer({
    super.key,
    required this.videoUrl,
    required this.onBack,
  });

  final String? videoUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AppYoutubeVideo(
        videoUrl: videoUrl ?? '',
        aspectRatio: foodPlayerAspectRatio,
        showThumbnail: false,
        unavailableColor: const Color(0x00000000),
        showBackButton: true,
        onBack: onBack,
        backButton: FoodDetailsBackButton(onPressed: onBack),
      ),
    );
  }
}

TextStyle foodNameStyle(BuildContext context) {
  final style = context.textTheme.headlineLarge ?? const TextStyle();
  return style.copyWith(
    color: AppColors.white,
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w700,
  );
}

TextStyle foodSummaryStyle(BuildContext context) {
  final style = context.textTheme.bodyMedium ?? const TextStyle();
  return style.copyWith(color: AppColors.grey, fontSize: 14, height: 1.3);
}
