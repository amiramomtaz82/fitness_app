import 'package:fitness_app/features/exercise/data/models/exercise_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> fullExerciseJson() => {
  '_id': 'e_1',
  'exercise': 'Barbell Bench Press',
  'difficulty_level': 'Beginner',
  'target_muscle_group': 'Chest',
  'prime_mover_muscle': 'Pectoralis Major',
  'secondary_muscle': 'Triceps Brachii',
  'tertiary_muscle': 'Anterior Deltoid',
  'primary_equipment': 'Barbell',
  '_primary_items': 1,
  'secondary_equipment': 'Bench',
  '_secondary_items': 2,
  'posture': 'Supine',
  'single_or_double_arm': 'Double',
  'continuous_or_alternating_arms': 'Continuous',
  'grip': 'Pronated',
  'load_position_ending': 'Above chest',
  'continuous_or_alternating_legs': 'Continuous',
  'foot_elevation': 'None',
  'combination_exercises': 'Chest Dip',
  'movement_pattern_1': 'Push',
  'movement_pattern_2': null,
  'movement_pattern_3': 'Horizontal',
  'plane_of_motion_1': 'Transverse',
  'plane_of_motion_2': 'Frontal',
  'plane_of_motion_3': null,
  'body_region': 'Upper',
  'force_type': 'Push',
  'mechanics': 'Compound',
  'laterality': 'Bilateral',
  'primary_exercise_classification': 'Press',
  'short_youtube_demonstration_link': 'https://youtu.be/dQw4w9WgXcQ',
  'in_depth_youtube_explanation_link': 'https://youtu.be/9bZkp7q19f0',
};

void main() {
  group('ExerciseModel.fromJson', () {
    test('maps the identifiers, the name and the level', () {
      final model = ExerciseModel.fromJson(fullExerciseJson());

      expect(model.id, 'e_1');
      expect(model.name, 'Barbell Bench Press');
      expect(model.difficultyLevel, 'Beginner');
    });

    test('maps the muscle and equipment fields', () {
      final model = ExerciseModel.fromJson(fullExerciseJson());

      expect(model.targetMuscleGroup, 'Chest');
      expect(model.primeMoverMuscle, 'Pectoralis Major');
      expect(model.secondaryMuscle, 'Triceps Brachii');
      expect(model.tertiaryMuscle, 'Anterior Deltoid');
      expect(model.primaryEquipment, 'Barbell');
      expect(model.primaryItems, 1);
      expect(model.secondaryEquipment, 'Bench');
      expect(model.secondaryItems, 2);
    });

    test('maps the execution and classification fields', () {
      final model = ExerciseModel.fromJson(fullExerciseJson());

      expect(model.posture, 'Supine');
      expect(model.singleOrDoubleArm, 'Double');
      expect(model.continuousOrAlternatingArms, 'Continuous');
      expect(model.grip, 'Pronated');
      expect(model.loadPositionEnding, 'Above chest');
      expect(model.footElevation, 'None');
      expect(model.combinationExercises, 'Chest Dip');
      expect(model.movementPattern1, 'Push');
      expect(model.movementPattern3, 'Horizontal');
      expect(model.planeOfMotion2, 'Frontal');
      expect(model.bodyRegion, 'Upper');
      expect(model.forceType, 'Push');
      expect(model.mechanics, 'Compound');
      expect(model.laterality, 'Bilateral');
      expect(model.primaryExerciseClassification, 'Press');
    });

    test('maps both video links', () {
      final model = ExerciseModel.fromJson(fullExerciseJson());

      expect(model.demonstrationVideoUrl, 'https://youtu.be/dQw4w9WgXcQ');
      expect(model.explanationVideoUrl, 'https://youtu.be/9bZkp7q19f0');
    });

    test(
      'leaves every optional field null when the body holds the basics only',
      () {
        final model = ExerciseModel.fromJson({
          '_id': 'e_2',
          'exercise': 'Push Up',
        });

        expect(model.difficultyLevel, isNull);
        expect(model.primaryItems, isNull);
        expect(model.targetMuscleGroup, isNull);
        expect(model.demonstrationVideoUrl, isNull);
        expect(model.explanationVideoUrl, isNull);
      },
    );
  });

  group('ExerciseModel.toJson', () {
    test('writes the api keys back unchanged', () {
      final json = ExerciseModel.fromJson(fullExerciseJson()).toJson();

      expect(json, fullExerciseJson());
    });
  });

  group('ExerciseModel.toEntity', () {
    test('carries every field to the entity', () {
      final entity = ExerciseModel.fromJson(fullExerciseJson()).toEntity();

      expect(entity.id, 'e_1');
      expect(entity.name, 'Barbell Bench Press');
      expect(entity.difficultyLevel, 'Beginner');
      expect(entity.targetMuscleGroup, 'Chest');
      expect(entity.primaryEquipment, 'Barbell');
      expect(entity.primaryItems, 1);
      expect(entity.grip, 'Pronated');
      expect(entity.movementPattern3, 'Horizontal');
      expect(entity.primaryExerciseClassification, 'Press');
      expect(entity.demonstrationVideoUrl, 'https://youtu.be/dQw4w9WgXcQ');
      expect(entity.explanationVideoUrl, 'https://youtu.be/9bZkp7q19f0');
    });

    test('replaces a missing id or name with empty text', () {
      final entity = ExerciseModel.fromJson({}).toEntity();

      expect(entity.id, isEmpty);
      expect(entity.name, isEmpty);
      expect(entity.difficultyLevel, isNull);
    });
  });
}
