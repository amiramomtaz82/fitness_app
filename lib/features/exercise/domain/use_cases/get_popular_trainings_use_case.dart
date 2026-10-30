import 'dart:math';

import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_level_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/repo/exercise_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPopularTrainingsUseCase {
  final ExerciseRepo _exerciseRepo;
  final Random _random = Random();

  GetPopularTrainingsUseCase(this._exerciseRepo);

  Future<BaseResponse<List<PopularTrainingEntity>>> call() async {
    // 1. Get all difficulty levels.
    final levelsResult = await _exerciseRepo.getDifficultyLevels();

    if (levelsResult is ErrorResponse<List<DifficultyLevelEntity>>) {
      return ErrorResponse(
        failure: levelsResult.failure,
        error: levelsResult.error,
      );
    }

    final levels =
        (levelsResult as SuccessResponse<List<DifficultyLevelEntity>>).data;

    // 2. Get 20 random muscles.
    final musclesResult = await _exerciseRepo.getRandomMuscles();

    if (musclesResult is ErrorResponse<List<MuscleEntity>>) {
      return ErrorResponse(
        failure: musclesResult.failure,
        error: musclesResult.error,
      );
    }

    final muscles = (musclesResult as SuccessResponse<List<MuscleEntity>>).data;

    // 3. Make sure we have data to select from.
    if (levels.isEmpty || muscles.isEmpty) {
      return const SuccessResponse<List<PopularTrainingEntity>>([]);
    }

    // 4. Select two random muscle-level combinations.
    final popularTrainings = <PopularTrainingEntity>[];

    var attempts = 0;
    while (popularTrainings.length < 2 && attempts < 8) {
      attempts++;

      final muscle = muscles[_random.nextInt(muscles.length)];
      final level = levels[_random.nextInt(levels.length)];

      final exercisesResult = await _exerciseRepo
          .getExercisesByMuscleDifficulty(
            primeMoverMuscleId: muscle.id,
            difficultyLevelId: level.id,
          );

      if (exercisesResult is ErrorResponse<List<ExerciseEntity>>) {
        return ErrorResponse(
          failure: exercisesResult.failure,
          error: exercisesResult.error,
        );
      }

      final exercises =
          (exercisesResult as SuccessResponse<List<ExerciseEntity>>).data;

      // Skip pairs that have no exercises and keep looking for a valid pair.
      if (exercises.isEmpty) continue;

      popularTrainings.add(
        PopularTrainingEntity(
          muscleName: muscle.name,
          levelName: level.name,
          exercisesCount: exercises.length,
          imageUrl: muscle.imageUrl,
        ),
      );
    }

    // 5. Return the selected popular trainings.
    return SuccessResponse<List<PopularTrainingEntity>>(popularTrainings);
  }
}
