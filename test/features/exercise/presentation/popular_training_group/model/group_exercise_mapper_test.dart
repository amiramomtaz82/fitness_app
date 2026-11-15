import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const benchPress = ExerciseEntity(
    id: 'e_1',
    name: 'Bench Press',
    primaryEquipment: 'Barbell',
    targetMuscleGroup: 'Chest',
    primeMoverMuscle: 'Pectoralis Major',
    secondaryMuscle: 'Triceps Brachii',
  );

  const chestFly = ExerciseEntity(
    id: 'e_2',
    name: 'Chest Fly',
    targetMuscleGroup: 'Chest',
    tertiaryMuscle: 'Anterior Deltoid',
  );

  const pushUp = ExerciseEntity(id: 'e_3', name: 'Push Up');

  group('GroupExerciseMapper.toItems', () {
    test('returns an empty list when there are no exercises', () {
      expect(GroupExerciseMapper.toItems(const []), isEmpty);
    });

    test('maps every exercise to an item and keeps the order', () {
      final items = GroupExerciseMapper.toItems(const [benchPress, chestFly]);

      expect(items, [
        GroupExerciseItem.from(benchPress),
        GroupExerciseItem.from(chestFly),
      ]);
      expect(items.map((item) => item.name), ['Bench Press', 'Chest Fly']);
    });

    test('gives every item its display values', () {
      final item = GroupExerciseMapper.toItems(const [benchPress]).single;

      expect(item.subtitle, 'Barbell');
      expect(item.exercise, benchPress);
    });
  });

  group('GroupExerciseMapper.relatedMuscles', () {
    test('returns an empty list when there are no exercises', () {
      expect(GroupExerciseMapper.relatedMuscles(const []), isEmpty);
    });

    test('returns an empty list when no exercise names a muscle', () {
      expect(GroupExerciseMapper.relatedMuscles(const [pushUp]), isEmpty);
    });

    test('collects the muscles in first seen order', () {
      expect(GroupExerciseMapper.relatedMuscles(const [benchPress, chestFly]), [
        'Chest',
        'Pectoralis Major',
        'Triceps Brachii',
        'Anterior Deltoid',
      ]);
    });

    test('drops muscles that only hold spaces', () {
      const spaced = ExerciseEntity(
        id: 'e_4',
        name: 'Incline Press',
        primeMoverMuscle: '   ',
        secondaryMuscle: 'Biceps Brachii',
      );

      expect(GroupExerciseMapper.relatedMuscles(const [spaced]), [
        'Biceps Brachii',
      ]);
    });
  });
}
