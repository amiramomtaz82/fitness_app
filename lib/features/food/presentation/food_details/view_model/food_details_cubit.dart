import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/resource/resource.dart';
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
      case LoadMealDetailsIntent(:final mealId):
        _loadMealDetails(mealId);
    }
  }

  Future<void> _loadMealDetails(String mealId) async {
    if (state.mealResource.isLoading) return;
    emit(state.copyWith(mealResource: const Resource.loading()));
    final response = await getMealDetailsUseCase.call(mealId);
    switch (response) {
      case SuccessResponse(:final data):
        emit(state.copyWith(mealResource: Resource.success(data)));
      case ErrorResponse(:final failure):
        emit(state.copyWith(mealResource: Resource.error(failure)));
        emitFailure(failure);
    }
  }
}
