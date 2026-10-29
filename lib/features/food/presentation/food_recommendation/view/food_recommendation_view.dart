import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/contants/app_assets.dart';
import '../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../../../../core/widgets/app_background_scaffold.dart';
import '../view_model/food_recommendation_cubit.dart';
import '../view_model/food_recommendation_intent.dart';
import '../view_model/food_recommendation_state.dart';
import 'widgets/food_recommendation_header.dart';
import 'widgets/meal_categories_tabs.dart';
import 'widgets/meals_grid_section.dart';

/// Expects a [FoodRecommendationCubit] provided above it (see the route).
class FoodRecommendationView extends StatefulWidget {
  const FoodRecommendationView({super.key});

  @override
  State<FoodRecommendationView> createState() => _FoodRecommendationViewState();
}

class _FoodRecommendationViewState extends State<FoodRecommendationView>
    with
        UiEventMixin<
          FoodRecommendationView,
          FoodRecommendationState,
          BaseUiEvent
        > {
  @override
  BaseCubit<FoodRecommendationState, BaseUiEvent> get cubit =>
      context.read<FoodRecommendationCubit>();

  @override
  void initState() {
    super.initState();
    context.read<FoodRecommendationCubit>().doIntent(
      const LoadFoodRecommendationIntent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      backgroundImage: AppAssets.foodBG,
      overlayOpacity: 0.7,
      child: Column(
        children: [
          SizedBox(height: 16.h),
          const FoodRecommendationHeader(),
          SizedBox(height: 24.h),
          const MealCategoriesTabs(),
          SizedBox(height: 8.h),
          const Expanded(child: MealsGridSection()),
        ],
      ),
    );
  }
}
