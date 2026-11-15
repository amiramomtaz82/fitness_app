import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const training = PopularTrainingEntity(
    primeMoverMuscleId: 'pm_1',
    difficultyLevelId: 'dl_1',
    muscleName: 'Chest',
    levelName: 'Beginner',
    exercisesCount: 3,
    imageUrl: 'https://cdn.test/chest.png',
  );

  group('PopularTrainingEntity', () {
    test('carries the ids that select the exercises of the training', () {
      expect(training.primeMoverMuscleId, 'pm_1');
      expect(training.difficultyLevelId, 'dl_1');
    });

    test('keeps the labels the screens show', () {
      expect(training.muscleName, 'Chest');
      expect(training.levelName, 'Beginner');
      expect(training.exercisesCount, 3);
      expect(training.imageUrl, 'https://cdn.test/chest.png');
    });

    test('accepts a training without a picture', () {
      const withoutImage = PopularTrainingEntity(
        primeMoverMuscleId: 'pm_1',
        difficultyLevelId: 'dl_1',
        muscleName: 'Chest',
        levelName: 'Beginner',
        exercisesCount: 3,
      );

      expect(withoutImage.imageUrl, isNull);
    });

    test('treats trainings with the same values as the same', () {
      const other = PopularTrainingEntity(
        primeMoverMuscleId: 'pm_1',
        difficultyLevelId: 'dl_1',
        muscleName: 'Chest',
        levelName: 'Beginner',
        exercisesCount: 3,
        imageUrl: 'https://cdn.test/chest.png',
      );

      expect(training, other);
      expect(training.hashCode, other.hashCode);
    });

    test('separates trainings that differ only in the muscle id', () {
      const other = PopularTrainingEntity(
        primeMoverMuscleId: 'pm_2',
        difficultyLevelId: 'dl_1',
        muscleName: 'Chest',
        levelName: 'Beginner',
        exercisesCount: 3,
        imageUrl: 'https://cdn.test/chest.png',
      );

      expect(training, isNot(other));
    });

    test('separates trainings that differ only in the difficulty id', () {
      const other = PopularTrainingEntity(
        primeMoverMuscleId: 'pm_1',
        difficultyLevelId: 'dl_2',
        muscleName: 'Chest',
        levelName: 'Beginner',
        exercisesCount: 3,
        imageUrl: 'https://cdn.test/chest.png',
      );

      expect(training, isNot(other));
    });
  });
}
