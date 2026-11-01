import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/error/failure_message_mapper.dart';
import '../../../../../../core/error/failures.dart';
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
          previous.categories.status != current.categories.status,
      builder: (context, state) {
        final categoriesFailure = state.categories.failure;
        if (state.categories.isError && categoriesFailure != null) {
          return _ErrorMessage(failure: categoriesFailure);
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
    return switch (meals.status) {
      ApiStatus.initial || ApiStatus.loading => const _Loader(),
      ApiStatus.error => _ErrorMessage(
        failure: meals.failure ?? const UnknownFailure(),
      ),
      ApiStatus.success => _MealsGrid(meals: meals.data ?? const []),
    };
  }
}

class _MealsGrid extends StatelessWidget {
  final List<MealSummaryEntity> meals;

  const _MealsGrid({required this.meals});

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return _Message(text: LocaleKeys.food_no_meals_found.tr());
    }
    return AppContentGridView(
      key: const Key('mealsGrid'),
      items: meals.map(_toCardItem).toList(),
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

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.primary),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final Failure failure;

  const _ErrorMessage({required this.failure});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Message(text: failure.toMessage()),
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
