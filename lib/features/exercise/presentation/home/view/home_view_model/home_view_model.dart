import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_popular_trainings_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_random_muscles_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_intent.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_categories_use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeViewModel extends BaseCubit<HomeState, BaseUiEvent> {
  final GetRandomMusclesUseCase _getRandomMusclesUseCase;
  final GetMuscleGroupsUseCase _getMuscleGroupsUseCase;
  final GetMusclesByGroupIdUseCase _getMusclesByGroupIdUseCase;
  final GetMealCategoriesUseCase _getMealCategoriesUseCase;
  final GetPopularTrainingsUseCase _getPopularTrainingsUseCase;

  HomeViewModel(
    this._getRandomMusclesUseCase,
    this._getMuscleGroupsUseCase,
    this._getMusclesByGroupIdUseCase,
    this._getMealCategoriesUseCase,
    this._getPopularTrainingsUseCase,
  ) : super(const HomeState());

  void doIntent(HomeIntent intent) {
    switch (intent) {
      case InitHomeIntent():
        _getRandomMuscles();
        _getMuscleGroups();
        _getMealCategories();
        _getPopularTrainings();

      case SelectMuscleGroupIntent(:final index):
        _onMuscleGroupSelected(index);
    }
  }

  void _onMuscleGroupSelected(int index) {
    final groups = state.groupsResource.data ?? [];

    if (index < 0 || index >= groups.length) return;
    if (index == state.selectedGroupIndex) return;

    emit(state.copyWith(selectedGroupIndex: index));

    _getMusclesByGroupId(groups[index].id);
  }

  Future<void> _getRandomMuscles() async {
    emit(state.copyWith(randomMusclesResource: const Resource.loading()));

    final result = await _getRandomMusclesUseCase();

    switch (result) {
      case SuccessResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(randomMusclesResource: Resource.success(result.data)),
        );

      case ErrorResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(randomMusclesResource: Resource.error(result.failure)),
        );
        emitFailure(result.failure);
    }
  }

  Future<void> _getMuscleGroups() async {
    emit(state.copyWith(groupsResource: const Resource.loading()));

    final result = await _getMuscleGroupsUseCase();

    switch (result) {
      case SuccessResponse<List<MuscleGroupEntity>>():
        emit(
          state.copyWith(
            groupsResource: Resource.success(result.data),
            selectedGroupIndex: 0,
          ),
        );

        if (result.data.isNotEmpty) {
          _getMusclesByGroupId(result.data.first.id);
        }

      case ErrorResponse<List<MuscleGroupEntity>>():
        emit(state.copyWith(groupsResource: Resource.error(result.failure)));
        emitFailure(result.failure);
    }
  }

  Future<void> _getMusclesByGroupId(String groupId) async {
    emit(state.copyWith(groupMusclesResource: const Resource.loading()));

    final result = await _getMusclesByGroupIdUseCase(groupId);

    switch (result) {
      case SuccessResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(groupMusclesResource: Resource.success(result.data)),
        );

      case ErrorResponse<List<MuscleEntity>>():
        emit(
          state.copyWith(groupMusclesResource: Resource.error(result.failure)),
        );
        emitFailure(result.failure);
    }
  }

  Future<void> _getMealCategories() async {
    emit(state.copyWith(mealCategoriesResource: const Resource.loading()));

    final result = await _getMealCategoriesUseCase();

    switch (result) {
      case SuccessResponse<List<MealCategoryEntity>>():
        emit(
          state.copyWith(mealCategoriesResource: Resource.success(result.data)),
        );

      case ErrorResponse<List<MealCategoryEntity>>():
        emit(
          state.copyWith(
            mealCategoriesResource: Resource.error(result.failure),
          ),
        );
        emitFailure(result.failure);
    }
  }

  Future<void> _getPopularTrainings() async {
    emit(state.copyWith(popularTrainingResource: const Resource.loading()));

    final result = await _getPopularTrainingsUseCase();

    switch (result) {
      case SuccessResponse<List<PopularTrainingEntity>>():
        emit(
          state.copyWith(
            popularTrainingResource: Resource.success(result.data),
          ),
        );

      case ErrorResponse<List<PopularTrainingEntity>>():
        emit(
          state.copyWith(
            popularTrainingResource: Resource.error(result.failure),
          ),
        );
        emitFailure(result.failure);
    }
  }
}
