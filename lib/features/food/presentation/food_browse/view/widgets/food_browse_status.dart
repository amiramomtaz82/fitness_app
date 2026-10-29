import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/app_catgory_tab_bar.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../domain/entities/meal_category_entity.dart';
import '../../view_model/food_browse_cubit.dart';
import '../../view_model/food_browse_intent.dart';
import '../../view_model/food_browse_state.dart';

class FoodBrowseCategoriesStatus extends StatelessWidget {
  const FoodBrowseCategoriesStatus({super.key, required this.state});

  final FoodBrowseState state;

  @override
  Widget build(BuildContext context) {
    if (state.categories.isError) {
      return FoodBrowseProblem(
        message: foodBrowseFailureText(state.categories.failure),
        onRetry: () => retryCategories(context),
      );
    }
    final categories = state.categories.data;
    if (state.categories.isSuccess &&
        (categories == null || categories.isEmpty)) {
      return const FoodBrowseMessage(
        messageKey: LocaleKeys.food_empty_categories,
      );
    }
    return const FoodBrowseProgress();
  }
}

class FoodBrowseMealsStatus extends StatelessWidget {
  const FoodBrowseMealsStatus({super.key, required this.state});

  final FoodBrowseState state;

  @override
  Widget build(BuildContext context) {
    if (!state.meals.isError) return const FoodBrowseProgress();
    return FoodBrowseProblem(
      message: foodBrowseFailureText(state.meals.failure),
      onRetry: () => retryMeals(context, state.selectedCategory),
    );
  }
}

class FoodBrowseEmptyMeals extends StatelessWidget {
  const FoodBrowseEmptyMeals({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoodBrowseMessage(messageKey: LocaleKeys.food_empty_meals);
  }
}

class FoodBrowseProgress extends StatelessWidget {
  const FoodBrowseProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.orange),
    );
  }
}

class FoodBrowseMessage extends StatelessWidget {
  const FoodBrowseMessage({super.key, required this.messageKey});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(messageKey.tr(), textAlign: TextAlign.center));
  }
}

class FoodBrowseProblem extends StatelessWidget {
  const FoodBrowseProblem({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(
            onPressed: onRetry,
            child: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      ),
    );
  }
}

class FoodCategoryBar extends StatelessWidget {
  const FoodCategoryBar({
    super.key,
    required this.names,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> names;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCategoryTabBar(
      categories: names,
      selectedIndex: selectedIndex,
      onCategorySelected: onSelected,
    );
  }
}

void retryCategories(BuildContext context) {
  context.read<FoodBrowseCubit>().doIntent(const LoadFoodBrowseIntent());
}

void retryMeals(BuildContext context, String? category) {
  final name = category?.trim() ?? '';
  if (name.isEmpty) {
    return;
  }
  context.read<FoodBrowseCubit>().doIntent(SelectFoodCategoryIntent(name));
}

String foodBrowseFailureText(Failure? failure) {
  final message = failure?.serverMessage;
  if (message != null && message.isNotEmpty) return message;
  return LocaleKeys.errors_something_went_wrong.tr();
}

List<String> categoryNames(List<MealCategoryEntity> categories) {
  return [for (final category in categories) category.name];
}

int selectedCategoryIndex(
  List<MealCategoryEntity> categories,
  String? selected,
) {
  final index = categories.indexWhere((item) => item.name == selected);
  if (index < 0) {
    return 0;
  }
  return index;
}
