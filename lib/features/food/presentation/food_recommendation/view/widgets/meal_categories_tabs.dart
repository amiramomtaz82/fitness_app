import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/widgets/app_catgory_tab_bar.dart';
import '../../view_model/food_recommendation_cubit.dart';
import '../../view_model/food_recommendation_intent.dart';
import '../../view_model/food_recommendation_state.dart';

class MealCategoriesTabs extends StatelessWidget {
  const MealCategoriesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodRecommendationCubit, FoodRecommendationState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedIndex != current.selectedIndex,
      builder: (context, state) {
        final categories = state.categories.data ?? const [];
        if (categories.isEmpty) return SizedBox(height: 33.h);
        return AppCategoryTabBar(
          key: const Key('mealCategoriesTabs'),
          categories: categories.map((category) => category.name).toList(),
          selectedIndex: state.selectedIndex,
          onCategorySelected: (index) => context
              .read<FoodRecommendationCubit>()
              .doIntent(SelectCategoryIntent(index)),
        );
      },
    );
  }
}
