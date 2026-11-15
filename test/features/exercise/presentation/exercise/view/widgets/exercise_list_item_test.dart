import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/widgets/exercise_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

const _exercise = ExerciseEntity(
  id: 'exercise-1',
  name: 'Barbell Bench Press',
  difficultyLevel: 'Beginner',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  primaryEquipment: 'Barbell',
  shortVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
  explanationVideoUrl: '',
);

void main() {
  Widget build({
    ExerciseEntity exercise = _exercise,
    bool isPlaying = false,
    VoidCallback? onPlay,
  }) {
    return makeTestableComponent(
      ExerciseListItem(
        exercise: exercise,
        isPlaying: isPlaying,
        onPlay: onPlay ?? () {},
      ),
    );
  }

  group('ExerciseListItem —', () {
    testWidgets('renders the exercise details', (tester) async {
      await tester.pumpWidget(build());

      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('3 Groups * 15 Times'), findsOneWidget);
      expect(find.text('Barbell • Beginner'), findsOneWidget);
    });

    testWidgets('falls back to sensible equipment and difficulty values', (
      tester,
    ) async {
      const blank = ExerciseEntity(
        id: 'exercise-2',
        name: 'Bodyweight Move',
        difficultyLevel: '',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Pectoralis Major',
        primaryEquipment: '',
        shortVideoUrl: '',
        explanationVideoUrl: '',
      );

      await tester.pumpWidget(build(exercise: blank));

      expect(find.text('Barbell • Beginner'), findsOneWidget);
    });

    testWidgets('shows a thumbnail image when the URL is playable', (
      tester,
    ) async {
      await tester.pumpWidget(build());

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsNothing);
    });

    testWidgets('shows a placeholder icon when no video exists', (
      tester,
    ) async {
      const noVideo = ExerciseEntity(
        id: 'exercise-2',
        name: 'No Video',
        difficultyLevel: 'Beginner',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Pectoralis Major',
        primaryEquipment: 'Barbell',
        shortVideoUrl: '',
        explanationVideoUrl: '',
      );

      await tester.pumpWidget(build(exercise: noVideo));

      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('switches the play icon while the exercise is playing', (
      tester,
    ) async {
      await tester.pumpWidget(build(isPlaying: false));
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.pumpWidget(build(isPlaying: true));
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });

    testWidgets('calls onPlay when the row or play button is tapped', (
      tester,
    ) async {
      var plays = 0;
      await tester.pumpWidget(build(onPlay: () => plays++));

      await tester.tap(find.text('Barbell Bench Press'));
      await tester.pump();
      expect(plays, 1);

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(plays, 2);
    });
  });
}
