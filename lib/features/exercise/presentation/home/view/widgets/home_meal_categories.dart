import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_horizontal_section.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMealCategories extends StatelessWidget {
  const HomeMealCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      buildWhen: (previous, current) =>
          previous.mealCategoriesResource != current.mealCategoriesResource,
      builder: (context, state) {
        return HomeHorizontalSection<MealCategoryEntity>(
          title: LocaleKeys.home_recommendation_for_you.tr(),
          resource: state.mealCategoriesResource,
          getTitle: (category) => category.name,
          getImage: (category) => category.thumbnail,
        );
      },
    );
  }
}
