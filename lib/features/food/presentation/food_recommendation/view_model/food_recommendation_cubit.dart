import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/use_cases/get_meal_categories_use_case.dart';
import '../../../domain/use_cases/get_meals_by_category_use_case.dart';
import 'food_recommendation_intent.dart';
import 'food_recommendation_state.dart';

@injectable
class FoodRecommendationCubit
    extends BaseCubit<FoodRecommendationState, BaseUiEvent> {
  final GetMealCategoriesUseCase _getMealCategoriesUseCase;
  final GetMealsByCategoryUseCase _getMealsByCategoryUseCase;

  FoodRecommendationCubit(
    this._getMealCategoriesUseCase,
    this._getMealsByCategoryUseCase,
  ) : super(const FoodRecommendationState());

  void doIntent(FoodRecommendationIntent intent) {
    switch (intent) {
      case LoadFoodRecommendationIntent():
        _loadCategories();
      case SelectCategoryIntent(:final index):
        _selectCategory(index);
      case RetryIntent():
        _retry();
    }
  }

  Future<void> _loadCategories() async {
    if (state.categories.isLoading) return;
    emit(state.copyWith(categories: const Resource.loading()));
    final result = await _getMealCategoriesUseCase();
    switch (result) {
      case SuccessResponse(:final data):
        emit(
          state.copyWith(categories: Resource.success(data), selectedIndex: 0),
        );
        await _loadSelectedCategoryMeals();
      case ErrorResponse(:final failure):
        emit(state.copyWith(categories: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  Future<void> _selectCategory(int index) async {
    final count = state.categories.data?.length ?? 0;
    if (index == state.selectedIndex || index < 0 || index >= count) return;
    emit(state.copyWith(selectedIndex: index));
    await _loadSelectedCategoryMeals();
  }

  Future<void> _loadSelectedCategoryMeals() async {
    final category = state.selectedCategory?.name;
    if (category == null) {
      emit(state.copyWith(meals: const Resource.success([])));
      return;
    }
    emit(state.copyWith(meals: const Resource.loading()));
    final result = await _getMealsByCategoryUseCase(category);
    // The user may have switched tabs while this request was running.
    if (state.selectedCategory?.name != category) return;
    switch (result) {
      case SuccessResponse(:final data):
        emit(state.copyWith(meals: Resource.success(data)));
      case ErrorResponse(:final failure):
        emit(state.copyWith(meals: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  Future<void> _retry() {
    return state.categories.isSuccess
        ? _loadSelectedCategoryMeals()
        : _loadCategories();
  }
}
