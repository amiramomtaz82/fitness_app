import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/meal_details_entity.dart';
import '../../../domain/use_cases/get_meal_details_use_case.dart';
import 'food_details_intent.dart';
import 'food_details_state.dart';

@injectable
class FoodDetailsCubit extends BaseCubit<FoodDetailsState, BaseUiEvent> {
  final GetMealDetailsUseCase getMealDetailsUseCase;

  FoodDetailsCubit(this.getMealDetailsUseCase)
    : super(const FoodDetailsState());

  void doIntent(FoodDetailsIntent intent) {
    switch (intent) {
      case LoadMealDetailsIntent():
        loadMealDetails(intent.mealId);
    }
  }

  Future<void> loadMealDetails(String mealId) async {
    if (state.mealResource.isLoading) return;
    emit(
      state.copyWith(
        mealResource: const Resource.loading(),
        isMealNotFound: false,
      ),
    );
    applyMealResponse(await getMealDetailsUseCase.call(mealId));
  }

  void applyMealResponse(BaseResponse<MealDetailsEntity?> response) {
    switch (response) {
      case SuccessResponse(data: final meal?):
        showMeal(meal);
      case SuccessResponse():
        showMissingMeal();
      case ErrorResponse(:final failure):
        showMealFailure(failure);
    }
  }

  void showMeal(MealDetailsEntity meal) {
    emit(
      state.copyWith(
        mealResource: Resource.success(meal),
        isMealNotFound: false,
      ),
    );
  }

  void showMissingMeal() {
    emit(
      state.copyWith(
        mealResource: const Resource.initial(),
        isMealNotFound: true,
      ),
    );
  }

  void showMealFailure(Failure failure) {
    emit(
      state.copyWith(
        mealResource: Resource.error(failure),
        isMealNotFound: false,
      ),
    );
    emitFailure(failure);
  }
}
