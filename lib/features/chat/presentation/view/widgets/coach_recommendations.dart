import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/app_content_card.dart';
import '../../../domain/entites/catalog_entities/exercise_card_entity.dart';
import '../../../domain/entites/catalog_entities/meal_card_entity.dart';

class CoachRecommendations extends StatelessWidget {
  final List<ExerciseCardEntity> exercises;
  final List<MealCardEntity> meals;

  const CoachRecommendations({
    super.key,
    this.exercises = const [],
    this.meals = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    String localized(String name, String? nameAr) =>
        isArabic && (nameAr?.trim().isNotEmpty ?? false) ? nameAr! : name;

    final cards = [
      for (final exercise in exercises)
        _CardData(
          key: 'exercise_${exercise.id}',
          title: localized(exercise.name, exercise.nameAr),
          imageUrl: exercise.demoUrl ?? '',
        ),
      for (final meal in meals)
        _CardData(
          key: 'meal_${meal.id}',
          title: localized(meal.name, meal.nameAr),
          imageUrl: meal.thumb ?? '',
        ),
    ];

    return SizedBox(
      height: 150.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.only(start: 40.w),
        itemCount: cards.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final card = cards[index];
          return SizedBox(
            key: ValueKey(card.key),
            width: 130.w,
            child: AppContentCard(title: card.title, imageUrl: card.imageUrl),
          );
        },
      ),
    );
  }
}

class _CardData {
  final String key;
  final String title;
  final String imageUrl;

  const _CardData({
    required this.key,
    required this.title,
    required this.imageUrl,
  });
}
