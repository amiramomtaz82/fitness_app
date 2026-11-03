import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exercise = ExerciseEntity(
    id: 'e_1',
    name: 'Bench Press',
    difficultyLevel: 'Beginner',
    primaryEquipment: 'Barbell',
    demonstrationVideoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  );

  group('GroupExerciseItem.from', () {
    test('keeps the entity for navigation and copies its name', () {
      final item = GroupExerciseItem.from(exercise);

      expect(item.exercise, exercise);
      expect(item.name, 'Bench Press');
    });

    test('prefers the equipment over the level for the subtitle', () {
      expect(GroupExerciseItem.from(exercise).subtitle, 'Barbell');
    });

    test('falls back to the level when the equipment is missing', () {
      const withoutEquipment = ExerciseEntity(
        id: 'e_2',
        name: 'Squat',
        difficultyLevel: 'Intermediate',
        primaryEquipment: '   ',
      );

      expect(GroupExerciseItem.from(withoutEquipment).subtitle, 'Intermediate');
    });

    test('leaves the subtitle null when both values are missing', () {
      const bare = ExerciseEntity(id: 'e_3', name: 'Lunge');

      expect(GroupExerciseItem.from(bare).subtitle, isNull);
    });

    test('reads the video id from the demonstration url', () {
      expect(GroupExerciseItem.from(exercise).videoId, 'dQw4w9WgXcQ');
    });

    test('falls back to the explanation url for the video id', () {
      const explanationOnly = ExerciseEntity(
        id: 'e_4',
        name: 'Row',
        explanationVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      );

      expect(GroupExerciseItem.from(explanationOnly).videoId, 'dQw4w9WgXcQ');
    });

    test('leaves the video id null when the url is not a video link', () {
      const external = ExerciseEntity(
        id: 'e_5',
        name: 'Stretch',
        demonstrationVideoUrl: 'https://example.com/clip',
      );

      expect(GroupExerciseItem.from(external).videoId, isNull);
    });
  });

  group('GroupExerciseItem equality', () {
    test('items built from the same entity are equal', () {
      expect(
        GroupExerciseItem.from(exercise),
        GroupExerciseItem.from(exercise),
      );
    });

    test('items built from different entities are not equal', () {
      const other = ExerciseEntity(id: 'e_6', name: 'Deadlift');

      expect(
        GroupExerciseItem.from(exercise) == GroupExerciseItem.from(other),
        isFalse,
      );
    });
  });
}
