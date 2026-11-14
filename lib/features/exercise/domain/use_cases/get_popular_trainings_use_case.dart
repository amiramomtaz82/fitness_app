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
  final Random _random;

  GetPopularTrainingsUseCase(this._exerciseRepo, [Random? random])
    : _random = random ?? Random();

  Future<BaseResponse<List<PopularTrainingEntity>>> call() async {
    final levelsResult = await _exerciseRepo.getDifficultyLevels();

    if (levelsResult is ErrorResponse<List<DifficultyLevelEntity>>) {
      return ErrorResponse(
        failure: levelsResult.failure,
        error: levelsResult.error,
      );
    }

    final levels =
        (levelsResult as SuccessResponse<List<DifficultyLevelEntity>>).data;

    final musclesResult = await _exerciseRepo.getRandomMuscles();

    if (musclesResult is ErrorResponse<List<MuscleEntity>>) {
      return ErrorResponse(
        failure: musclesResult.failure,
        error: musclesResult.error,
      );
    }

    final muscles = (musclesResult as SuccessResponse<List<MuscleEntity>>).data;

    if (levels.isEmpty || muscles.isEmpty) {
      return const SuccessResponse<List<PopularTrainingEntity>>([]);
    }

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

      switch (exercisesResult) {
        case ErrorResponse<List<ExerciseEntity>>(:final failure, :final error):
          return ErrorResponse(failure: failure, error: error);

        case SuccessResponse<List<ExerciseEntity>>(:final data):
          if (data.isEmpty) continue;

          popularTrainings.add(
            PopularTrainingEntity(
              primeMoverMuscleId: muscle.id,
              difficultyLevelId: level.id,
              muscleName: muscle.name,
              levelName: level.name,
              exercisesCount: data.length,
              imageUrl: muscle.imageUrl,
            ),
          );
      }
    }

    return SuccessResponse<List<PopularTrainingEntity>>(popularTrainings);
  }
}
