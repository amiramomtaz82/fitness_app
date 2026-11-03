import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_section_data.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_view_model.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

const kFullExercise = ExerciseEntity(
  id: 'e_1',
  name: 'Barbell Bench Press',
  difficultyLevel: ' Intermediate ',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  secondaryMuscle: 'Triceps Brachii',
  tertiaryMuscle: 'Anterior Deltoid',
  primaryEquipment: 'Barbell',
  primaryItems: 1,
  secondaryEquipment: 'Bench',
  secondaryItems: 2,
  posture: 'Supine',
  singleOrDoubleArm: 'Double',
  continuousOrAlternatingArms: 'Continuous',
  grip: 'Pronated',
  loadPositionEnding: 'Above chest',
  continuousOrAlternatingLegs: 'Continuous',
  footElevation: 'None',
  combinationExercises: 'Chest Dip',
  movementPattern1: 'Push',
  movementPattern2: null,
  movementPattern3: 'Horizontal',
  planeOfMotion1: 'Transverse',
  planeOfMotion2: 'Frontal',
  planeOfMotion3: '   ',
  bodyRegion: 'Upper',
  forceType: 'Push',
  mechanics: 'Compound',
  laterality: 'Bilateral',
  primaryExerciseClassification: 'Press',
  demonstrationVideoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  explanationVideoUrl: 'https://youtu.be/9bZkp7q19f0',
);

const kExerciseWithNoDetails = ExerciseEntity(id: 'e_2', name: 'Push Up');

String? textValue(ExerciseDetailsSectionData section, String labelKey) {
  final entry = section.entries.firstWhere(
    (entry) => entry.labelKey == labelKey,
  );

  return switch (entry) {
    ExerciseDetailsTextEntry(:final value) => value,
    ExerciseDetailsVideoEntry() => null,
  };
}

String? videoValue(ExerciseDetailsSectionData section, String labelKey) {
  final entry = section.entries.firstWhere(
    (entry) => entry.labelKey == labelKey,
  );

  return switch (entry) {
    ExerciseDetailsVideoEntry(:final videoUrl) => videoUrl,
    ExerciseDetailsTextEntry() => null,
  };
}

void main() {
  late ExerciseDetailsViewModel details;
  late ExerciseDetailsViewModel bareDetails;

  setUp(() {
    details = ExerciseDetailsViewModel.fromEntity(kFullExercise);
    bareDetails = ExerciseDetailsViewModel.fromEntity(kExerciseWithNoDetails);
  });

  group('ExerciseDetailsViewModel header', () {
    test('trims the header values', () {
      expect(details.name, 'Barbell Bench Press');
      expect(details.level, 'Intermediate');
      expect(details.equipment, 'Barbell');
    });

    test('prefers the demonstration url for playback', () {
      expect(details.playUrl, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(details.videoId, 'dQw4w9WgXcQ');
    });

    test('falls back to the explanation url for playback', () {
      const explanationOnly = ExerciseEntity(
        id: 'e_3',
        name: 'Row',
        explanationVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      );

      final mapped = ExerciseDetailsViewModel.fromEntity(explanationOnly);

      expect(mapped.playUrl, 'https://youtu.be/dQw4w9WgXcQ');
      expect(mapped.videoId, 'dQw4w9WgXcQ');
    });

    test('leaves playback null when no url holds a video', () {
      const external = ExerciseEntity(
        id: 'e_4',
        name: 'Stretch',
        demonstrationVideoUrl: 'https://example.com/clip',
      );

      final mapped = ExerciseDetailsViewModel.fromEntity(external);

      expect(mapped.playUrl, 'https://example.com/clip');
      expect(mapped.videoId, isNull);
    });

    test('leaves the header null when the exercise has no details', () {
      expect(bareDetails.name, 'Push Up');
      expect(bareDetails.level, isNull);
      expect(bareDetails.equipment, isNull);
      expect(bareDetails.playUrl, isNull);
      expect(bareDetails.videoId, isNull);
    });
  });

  group('ExerciseDetailsViewModel sections', () {
    test('builds the five sections in display order', () {
      expect(details.sections.map((section) => section.titleKey), [
        LocaleKeys.exercises_related_muscles,
        LocaleKeys.exercises_equipment,
        LocaleKeys.exercises_execution,
        LocaleKeys.exercises_classification,
        LocaleKeys.exercises_videos,
      ]);
    });

    test('always builds every section so labels stay visible', () {
      expect(bareDetails.sections, hasLength(5));
    });

    test('maps the muscle values in order', () {
      final section = details.sections.first;

      expect(
        textValue(section, LocaleKeys.exercises_target_muscle_group),
        'Chest',
      );
      expect(
        textValue(section, LocaleKeys.exercises_prime_mover_muscle),
        'Pectoralis Major',
      );
      expect(
        textValue(section, LocaleKeys.exercises_secondary_muscle),
        'Triceps Brachii',
      );
      expect(
        textValue(section, LocaleKeys.exercises_tertiary_muscle),
        'Anterior Deltoid',
      );
    });

    test('maps the equipment values and turns counts into text', () {
      final section = details.sections[1];

      expect(
        textValue(section, LocaleKeys.exercises_primary_equipment),
        'Barbell',
      );
      expect(textValue(section, LocaleKeys.exercises_primary_items), '1');
      expect(
        textValue(section, LocaleKeys.exercises_secondary_equipment),
        'Bench',
      );
      expect(textValue(section, LocaleKeys.exercises_secondary_items), '2');
    });

    test('maps the execution values', () {
      final section = details.sections[2];

      expect(textValue(section, LocaleKeys.exercises_posture), 'Supine');
      expect(
        textValue(section, LocaleKeys.exercises_single_or_double_arm),
        'Double',
      );
      expect(
        textValue(section, LocaleKeys.exercises_continuous_or_alternating_arms),
        'Continuous',
      );
      expect(textValue(section, LocaleKeys.exercises_grip), 'Pronated');
      expect(
        textValue(section, LocaleKeys.exercises_load_position_ending),
        'Above chest',
      );
      expect(textValue(section, LocaleKeys.exercises_foot_elevation), 'None');
      expect(
        textValue(section, LocaleKeys.exercises_combination_exercises),
        'Chest Dip',
      );
    });

    test('joins the movement patterns and planes without the gaps', () {
      final section = details.sections[3];

      expect(
        textValue(section, LocaleKeys.exercises_movement_patterns),
        'Push, Horizontal',
      );
      expect(
        textValue(section, LocaleKeys.exercises_planes_of_motion),
        'Transverse, Frontal',
      );
      expect(textValue(section, LocaleKeys.exercises_body_region), 'Upper');
      expect(textValue(section, LocaleKeys.exercises_force_type), 'Push');
      expect(textValue(section, LocaleKeys.exercises_mechanics), 'Compound');
      expect(textValue(section, LocaleKeys.exercises_laterality), 'Bilateral');
      expect(
        textValue(
          section,
          LocaleKeys.exercises_primary_exercise_classification,
        ),
        'Press',
      );
    });

    test('keeps both video urls as tappable entries', () {
      final section = details.sections[4];

      expect(
        videoValue(section, LocaleKeys.exercises_video_demonstration),
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );
      expect(
        videoValue(section, LocaleKeys.exercises_video_explanation),
        'https://youtu.be/9bZkp7q19f0',
      );
    });

    test('leaves every value null when the exercise has no details', () {
      for (final section in bareDetails.sections) {
        for (final entry in section.entries) {
          expect(switch (entry) {
            ExerciseDetailsTextEntry(:final value) => value,
            ExerciseDetailsVideoEntry(:final videoUrl) => videoUrl,
          }, isNull);
        }
      }
    });
  });
}
