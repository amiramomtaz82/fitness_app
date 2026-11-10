import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseDetailsTextEntry', () {
    test('keeps the label key and the value', () {
      const entry = ExerciseDetailsTextEntry(
        labelKey: 'exercises.grip',
        value: 'Pronated',
      );

      expect(entry.labelKey, 'exercises.grip');
      expect(entry.value, 'Pronated');
      expect(entry, isA<ExerciseDetailsEntry>());
    });

    test('accepts a missing value', () {
      const entry = ExerciseDetailsTextEntry(labelKey: 'exercises.grip');

      expect(entry.value, isNull);
    });

    test('entries with the same label and value are equal', () {
      expect(
        const ExerciseDetailsTextEntry(
          labelKey: 'exercises.grip',
          value: 'Neutral',
        ),
        const ExerciseDetailsTextEntry(
          labelKey: 'exercises.grip',
          value: 'Neutral',
        ),
      );
    });

    test('entries with different values are not equal', () {
      expect(
        const ExerciseDetailsTextEntry(
          labelKey: 'exercises.grip',
          value: 'Neutral',
        ),
        isNot(const ExerciseDetailsTextEntry(labelKey: 'exercises.grip')),
      );
    });
  });

  group('ExerciseDetailsVideoEntry', () {
    test('keeps the label key and the video url', () {
      const entry = ExerciseDetailsVideoEntry(
        labelKey: 'exercises.video_demonstration',
        videoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      );

      expect(entry.labelKey, 'exercises.video_demonstration');
      expect(entry.videoUrl, 'https://youtu.be/dQw4w9WgXcQ');
      expect(entry, isA<ExerciseDetailsEntry>());
    });

    test('accepts a missing url', () {
      const entry = ExerciseDetailsVideoEntry(
        labelKey: 'exercises.video_explanation',
      );

      expect(entry.videoUrl, isNull);
    });

    test('entries with the same label and url are equal', () {
      expect(
        const ExerciseDetailsVideoEntry(labelKey: 'a', videoUrl: 'b'),
        const ExerciseDetailsVideoEntry(labelKey: 'a', videoUrl: 'b'),
      );
    });

    test('entries with different urls are not equal', () {
      expect(
        const ExerciseDetailsVideoEntry(labelKey: 'a', videoUrl: 'b'),
        isNot(const ExerciseDetailsVideoEntry(labelKey: 'a')),
      );
    });
  });

  group('ExerciseDetailsEntry subtypes', () {
    test('a text entry is never equal to a video entry', () {
      expect(
        const ExerciseDetailsTextEntry(labelKey: 'a', value: 'b'),
        isNot(const ExerciseDetailsVideoEntry(labelKey: 'a', videoUrl: 'b')),
      );
    });
  });
}
