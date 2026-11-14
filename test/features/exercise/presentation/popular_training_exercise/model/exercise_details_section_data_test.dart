import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_section_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const entries = [
    ExerciseDetailsTextEntry(labelKey: 'exercises.grip', value: 'Pronated'),
    ExerciseDetailsVideoEntry(labelKey: 'exercises.video_demonstration'),
  ];

  group('ExerciseDetailsSectionData', () {
    test('keeps the title key and its entries', () {
      const section = ExerciseDetailsSectionData(
        titleKey: 'exercises.execution',
        entries: entries,
      );

      expect(section.titleKey, 'exercises.execution');
      expect(section.entries, entries);
    });

    test('sections with the same title and entries are equal', () {
      const first = ExerciseDetailsSectionData(
        titleKey: 'exercises.execution',
        entries: entries,
      );
      const second = ExerciseDetailsSectionData(
        titleKey: 'exercises.execution',
        entries: entries,
      );

      expect(first, second);
    });

    test('sections with a different title are not equal', () {
      const first = ExerciseDetailsSectionData(
        titleKey: 'exercises.execution',
        entries: entries,
      );
      const second = ExerciseDetailsSectionData(
        titleKey: 'exercises.classification',
        entries: entries,
      );

      expect(first, isNot(second));
    });

    test('sections with different entries are not equal', () {
      const first = ExerciseDetailsSectionData(
        titleKey: 'exercises.execution',
        entries: entries,
      );
      const second = ExerciseDetailsSectionData(
        titleKey: 'exercises.execution',
        entries: [ExerciseDetailsTextEntry(labelKey: 'exercises.grip')],
      );

      expect(first, isNot(second));
    });
  });
}
