import 'package:fitness_app/features/exercise/data/models/exercise_model.dart';
import 'package:fitness_app/features/exercise/data/models/exercises_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// A trimmed copy of a real `/exercises` payload. The API uses snake_case
/// keys, which include the YouTube links the player needs.
const _payload = {
  '_id': '69d982f285f6bfa972bf227c',
  'exercise': 'Stability Ball Dead Bug',
  'short_youtube_demonstration': 'Video Demonstration',
  'in_depth_youtube_explanation': 'Video Explanation',
  'difficulty_level': 'Beginner',
  'target_muscle_group': 'Abdominals',
  'prime_mover_muscle': 'Rectus Abdominis',
  'secondary_muscle': null,
  'tertiary_muscle': null,
  'primary_equipment': 'Stability Ball',
  '_primary_items': 1,
  'secondary_equipment': null,
  '_secondary_items': 0,
  'posture': 'Supine',
  'single_or_double_arm': 'Single Arm',
  'continuous_or_alternating_arms': 'Alternating',
  'grip': 'Neutral',
  'load_position_ending': 'Other',
  'continuous_or_alternating_legs': 'Alternating',
  'foot_elevation': 'No Elevation',
  'combination_exercises': 'Single Exercise',
  'movement_pattern_1': 'Anti-Extension',
  'movement_pattern_2': null,
  'movement_pattern_3': null,
  'plane_of_motion_1': 'Sagittal Plane',
  'plane_of_motion_2': null,
  'plane_of_motion_3': null,
  'body_region': 'Midsection',
  'force_type': 'Other',
  'mechanics': 'Compound',
  'laterality': 'Contralateral',
  'primary_exercise_classification': 'Postural',
  'short_youtube_demonstration_link': 'https://youtu.be/5jDEulwWs04',
  'in_depth_youtube_explanation_link': 'https://youtu.be/Sa4ZWmnSC5o',
};

void main() {
  group('ExerciseModel —', () {
    test('reads the snake_case fields sent by the API', () {
      final model = ExerciseModel.fromJson(_payload);

      expect(model.id, '69d982f285f6bfa972bf227c');
      expect(model.exercise, 'Stability Ball Dead Bug');
      expect(model.difficultyLevel, 'Beginner');
      expect(model.targetMuscleGroup, 'Abdominals');
      expect(model.primeMoverMuscle, 'Rectus Abdominis');
      expect(model.primaryEquipment, 'Stability Ball');
      expect(model.primaryItems, 1);
      expect(model.secondaryItems, 0);
      expect(model.mechanics, 'Compound');
      expect(model.bodyRegion, 'Midsection');
    });

    test('maps the YouTube links into the entity used by the player', () {
      final entity = ExerciseModel.fromJson(_payload).toEntity();

      expect(entity.shortVideoUrl, 'https://youtu.be/5jDEulwWs04');
      expect(entity.explanationVideoUrl, 'https://youtu.be/Sa4ZWmnSC5o');
      expect(entity.name, 'Stability Ball Dead Bug');
      expect(entity.difficultyLevel, 'Beginner');
    });

    test('falls back to empty video links when the API omits them', () {
      final json = Map<String, dynamic>.from(_payload)
        ..remove('short_youtube_demonstration_link')
        ..remove('in_depth_youtube_explanation_link');

      final entity = ExerciseModel.fromJson(json).toEntity();

      expect(entity.shortVideoUrl, isEmpty);
      expect(entity.explanationVideoUrl, isEmpty);
    });

    test('round-trips through toJson', () {
      final model = ExerciseModel.fromJson(_payload);

      expect(
        model.toJson()['short_youtube_demonstration_link'],
        'https://youtu.be/5jDEulwWs04',
      );
    });
  });

  group('ExercisesResponseModel —', () {
    test('parses the enveloped exercises list', () {
      final response = ExercisesResponseModel.fromJson({
        'message': 'success',
        'totalExercises': 1,
        'totalPages': 1,
        'currentPage': 1,
        'exercises': [_payload],
      });

      final result = response.toEntity();

      expect(result.totalExercises, 1);
      expect(result.exercises, hasLength(1));
      expect(
        result.exercises.first.shortVideoUrl,
        'https://youtu.be/5jDEulwWs04',
      );
    });
  });
}
