import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/meal_category_entity.dart';
import '../../../domain/entities/meal_summary_entity.dart';
import '../../../domain/use_cases/get_meal_categories_use_case.dart';
import '../../../domain/use_cases/get_meals_by_category_use_case.dart';
import 'food_browse_intent.dart';
import 'food_browse_state.dart';

@injectable
class FoodBrowseCubit extends BaseCubit<FoodBrowseState, BaseUiEvent> {
  final GetMealCategoriesUseCase getMealCategoriesUseCase;
  final GetMealsByCategoryUseCase getMealsByCategoryUseCase;

  FoodBrowseCubit(this.getMealCategoriesUseCase, this.getMealsByCategoryUseCase)
    : super(const FoodBrowseState());

  void doIntent(FoodBrowseIntent intent) {
    switch (intent) {
      case LoadFoodBrowseIntent():
        loadCategories();
      case SelectFoodCategoryIntent(:final category):
        loadMeals(category);
    }
  }

  Future<void> loadCategories() async {
    if (state.categories.isLoading) return;
    emit(state.copyWith(categories: const Resource.loading()));
    applyCategories(await getMealCategoriesUseCase.call());
  }

  void applyCategories(BaseResponse<List<MealCategoryEntity>> response) {
    switch (response) {
      case SuccessResponse(:final data):
        showCategories(data);
      case ErrorResponse(:final failure):
        showCategoryFailure(failure);
    }
  }

  void showCategories(List<MealCategoryEntity> categories) {
    emit(state.copyWith(categories: Resource.success(categories)));
    final first = firstCategoryName(categories);
    if (first == null) {
      return;
    }
    loadMeals(first);
  }

  void showCategoryFailure(Failure failure) {
    emit(
      state.copyWith(
        categories: Resource.error(failure),
        meals: const Resource.initial(),
      ),
    );
  }

  Future<void> loadMeals(String category) async {
    final name = category.trim();
    if (name.isEmpty) {
      return;
    }
    final token = state.mealsToken + 1;
    emit(
      state.copyWith(
        selectedCategory: name,
        mealsToken: token,
        meals: const Resource.loading(),
      ),
    );
    applyMeals(token, await getMealsByCategoryUseCase.call(name));
  }

  void applyMeals(int token, BaseResponse<List<MealSummaryEntity>> response) {
    if (token != state.mealsToken) {
      return;
    }
    switch (response) {
      case SuccessResponse(:final data):
        emit(state.copyWith(meals: Resource.success(data)));
      case ErrorResponse(:final failure):
        emit(state.copyWith(meals: Resource.error(failure)));
    }
  }
}

String? firstCategoryName(List<MealCategoryEntity> categories) {
  for (final category in categories) {
    final name = category.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
  }
  return null;
}
