import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_popular_training_exercises_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_mapper.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_state.dart';
import 'package:fitness_app/features/exercise/presentation/utils/display_values.dart';
import 'package:injectable/injectable.dart';

@injectable
class PopularTrainingGroupViewModel
    extends BaseCubit<PopularTrainingGroupState, BaseUiEvent> {
  final GetPopularTrainingExercisesUseCase _getPopularTrainingExercisesUseCase;

  PopularTrainingGroupViewModel(this._getPopularTrainingExercisesUseCase)
    : super(const PopularTrainingGroupState());

  void doIntent(PopularTrainingGroupIntent intent) {
    switch (intent) {
      case InitPopularTrainingGroupIntent(:final training):
        _prepare(training);
        _getExercises(training);

      case RetryPopularTrainingGroupIntent():
        final training = state.training;
        if (training == null) return;
        _getExercises(training);
    }
  }

  void _prepare(PopularTrainingEntity training) {
    emit(
      state.copyWith(
        training: training,
        exercisesCount: training.exercisesCount,
        heroImageUrl: DisplayValues.text(training.imageUrl),
      ),
    );
  }

  Future<void> _getExercises(PopularTrainingEntity training) async {
    emit(state.copyWith(exercisesResource: const Resource.loading()));

    final result = await _getPopularTrainingExercisesUseCase(
      primeMoverMuscleId: training.primeMoverMuscleId,
      difficultyLevelId: training.difficultyLevelId,
    );

    switch (result) {
      case SuccessResponse<List<ExerciseEntity>>():
        final items = GroupExerciseMapper.toItems(result.data);
        emit(
          state.copyWith(
            exercisesResource: Resource.success(items),
            relatedMuscles: GroupExerciseMapper.relatedMuscles(result.data),
            exercisesCount: items.length,
          ),
        );

      case ErrorResponse<List<ExerciseEntity>>():
        emit(
          state.copyWith(
            exercisesResource: Resource<List<GroupExerciseItem>>.error(
              result.failure,
            ),
          ),
        );
        emitFailure(result.failure);
    }
  }
}
