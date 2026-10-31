import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/routes_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/app_content_grid_view.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../domain/entities/meal_category_entity.dart';
import '../../../../domain/entities/meal_summary_entity.dart';
import '../../view_model/food_browse_cubit.dart';
import '../../view_model/food_browse_intent.dart';
import '../../view_model/food_browse_state.dart';
import 'food_browse_status.dart';

class FoodBrowseBody extends StatelessWidget {
  const FoodBrowseBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FoodBrowseCubit>().state;
    final categories = state.categories.data;
    if (categories == null || !state.categories.isSuccess) {
      return FoodBrowseCategoriesStatus(state: state);
    }
    return FoodBrowseLoaded(state: state, categories: categories);
  }
}

class FoodBrowseLoaded extends StatelessWidget {
  const FoodBrowseLoaded({
    super.key,
    required this.state,
    required this.categories,
  });

  final FoodBrowseState state;
  final List<MealCategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FoodBrowseTitle(title: LocaleKeys.food_tab.tr()),
        FoodCategoryPicker(categories: categories, state: state),
        Expanded(child: FoodMealsPane(state: state)),
      ],
    );
  }
}

class FoodBrowseTitle extends StatelessWidget {
  const FoodBrowseTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(title, style: const TextStyle(color: AppColors.white)),
    );
  }
}

class FoodCategoryPicker extends StatelessWidget {
  const FoodCategoryPicker({
    super.key,
    required this.categories,
    required this.state,
  });

  final List<MealCategoryEntity> categories;
  final FoodBrowseState state;

  @override
  Widget build(BuildContext context) {
    return FoodCategoryBar(
      names: categoryNames(categories),
      selectedIndex: selectedCategoryIndex(categories, state.selectedCategory),
      onSelected: (index) => selectCategory(context, categories[index].name),
    );
  }
}

class FoodMealsPane extends StatelessWidget {
  const FoodMealsPane({super.key, required this.state});

  final FoodBrowseState state;

  @override
  Widget build(BuildContext context) {
    final meals = state.meals.data;
    if (meals == null || !state.meals.isSuccess) {
      return FoodBrowseMealsStatus(state: state);
    }
    if (meals.isEmpty) return const FoodBrowseEmptyMeals();
    return FoodMealGrid(meals: meals);
  }
}

class FoodMealGrid extends StatelessWidget {
  const FoodMealGrid({super.key, required this.meals});

  final List<MealSummaryEntity> meals;

  @override
  Widget build(BuildContext context) {
    return AppContentGridView(
      items: mealCards(meals),
      onItemTap: (item) => openMealDetails(context, item.id),
    );
  }
}

void selectCategory(BuildContext context, String category) {
  context.read<FoodBrowseCubit>().doIntent(SelectFoodCategoryIntent(category));
}

void openMealDetails(BuildContext context, String mealId) {
  final id = mealId.trim();
  if (id.isEmpty) {
    return;
  }
  context.push('${AppRoutes.food}/meal/${Uri.encodeComponent(id)}');
}

List<ContentCardItem> mealCards(List<MealSummaryEntity> meals) {
  return [
    for (final meal in meals)
      ContentCardItem(id: meal.id, title: meal.name, imageUrl: meal.thumbnail),
  ];
}
