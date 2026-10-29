import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/resource/resource.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../core/widgets/app_content_grid_view.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../domain/entities/meal_summary_entity.dart';
import '../../view_model/food_recommendation_cubit.dart';
import '../../view_model/food_recommendation_intent.dart';
import '../../view_model/food_recommendation_state.dart';

class MealsGridSection extends StatelessWidget {
  const MealsGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodRecommendationCubit, FoodRecommendationState>(
      buildWhen: (previous, current) =>
          previous.meals != current.meals ||
          previous.categories.isError != current.categories.isError,
      builder: (context, state) {
        if (state.categories.isError || state.meals.isError) {
          return const _RetryMessage();
        }
        return _MealsContent(meals: state.meals);
      },
    );
  }
}

class _MealsContent extends StatelessWidget {
  final Resource<List<MealSummaryEntity>> meals;

  const _MealsContent({required this.meals});

  @override
  Widget build(BuildContext context) {
    final list = meals.data;
    if (list == null) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.primary),
      );
    }
    if (list.isEmpty) {
      return _Message(text: LocaleKeys.food_no_meals_found.tr());
    }
    return AppContentGridView(
      key: const Key('mealsGrid'),
      items: list.map(_toCardItem).toList(),
    );
  }

  ContentCardItem _toCardItem(MealSummaryEntity meal) {
    return ContentCardItem(
      id: meal.id,
      title: meal.name,
      imageUrl: meal.thumbnail,
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Message(text: LocaleKeys.errors_something_went_wrong.tr()),
        SizedBox(height: 16.h),
        TextButton(
          key: const Key('mealsRetryBtn'),
          onPressed: () => context.read<FoodRecommendationCubit>().doIntent(
            const RetryIntent(),
          ),
          child: Text(
            LocaleKeys.common_retry.tr(),
            style: AppTextStyles.white14bold.copyWith(
              color: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 32.w),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.white14regular.copyWith(
            color: context.colors.grey,
          ),
        ),
      ),
    );
  }
}
