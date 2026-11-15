import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/widgets/exercise_bottom_container.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../../../helpers/test_localization.dart';

const _exerciseA = ExerciseEntity(
  id: 'exercise-a',
  name: 'Barbell Bench Press',
  difficultyLevel: 'Beginner',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  primaryEquipment: 'Barbell',
  shortVideoUrl: '',
  explanationVideoUrl: '',
);

const _exerciseB = ExerciseEntity(
  id: 'exercise-b',
  name: 'Push Up',
  difficultyLevel: 'Intermediate',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  primaryEquipment: 'Bodyweight',
  shortVideoUrl: '',
  explanationVideoUrl: '',
);

void main() {
  setUpAll(loadTestLocalization);

  Widget build({
    List<ExerciseEntity> exercises = const [_exerciseA, _exerciseB],
    String? activeExerciseId,
    bool isLoading = false,
    bool isError = false,
    String? errorMessage,
    bool hasMore = false,
    VoidCallback? onRetry,
    VoidCallback? onLoadMore,
    ValueChanged<ExerciseEntity>? onPlayExercise,
  }) {
    return makeTestableWidget(
      Scaffold(
        body: ExerciseBottomContainer(
          exercises: exercises,
          activeExerciseId: activeExerciseId,
          isLoading: isLoading,
          isError: isError,
          errorMessage: errorMessage,
          hasMore: hasMore,
          onRetry: onRetry ?? () {},
          onLoadMore: onLoadMore ?? () {},
          onPlayExercise: onPlayExercise ?? (_) {},
        ),
      ),
    );
  }

  group('ExerciseBottomContainer —', () {
    testWidgets('shows a spinner while loading without data', (tester) async {
      await tester.pumpWidget(build(exercises: const [], isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(_exerciseA.name), findsNothing);
    });

    testWidgets('shows the error message and invokes retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        build(
          exercises: const [],
          isError: true,
          errorMessage: 'Network is down',
          onRetry: () => retries++,
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Network is down'), findsOneWidget);

      await tester.tap(find.text(LocaleKeys.common_retry.tr()));
      await tester.pump();

      expect(retries, 1);
    });

    testWidgets('falls back to a generic error message', (tester) async {
      await tester.pumpWidget(
        build(exercises: const [], isError: true, errorMessage: null),
      );

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('shows the empty state when there is nothing to list', (
      tester,
    ) async {
      await tester.pumpWidget(build(exercises: const []));

      expect(find.text(LocaleKeys.exercises_no_exercises.tr()), findsOneWidget);
    });

    testWidgets('renders every exercise and marks the active one', (
      tester,
    ) async {
      await tester.pumpWidget(build(activeExerciseId: 'exercise-b'));

      expect(find.text(_exerciseA.name), findsOneWidget);
      expect(find.text(_exerciseB.name), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });

    testWidgets('reports the tapped exercise', (tester) async {
      ExerciseEntity? played;
      await tester.pumpWidget(
        build(onPlayExercise: (exercise) => played = exercise),
      );

      await tester.tap(find.text(_exerciseB.name));
      await tester.pump();

      expect(played, _exerciseB);
    });

    testWidgets('shows a footer spinner when more pages are available', (
      tester,
    ) async {
      await tester.pumpWidget(build(hasMore: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('requests the next page when scrolled to the bottom', (
      tester,
    ) async {
      var loadMoreCalls = 0;
      await tester.pumpWidget(
        build(
          exercises: List.generate(
            12,
            (index) => ExerciseEntity(
              id: 'exercise-$index',
              name: 'Exercise $index',
              difficultyLevel: 'Beginner',
              targetMuscleGroup: 'Chest',
              primeMoverMuscle: 'Pectoralis Major',
              primaryEquipment: 'Barbell',
              shortVideoUrl: '',
              explanationVideoUrl: '',
            ),
          ),
          hasMore: true,
          onLoadMore: () => loadMoreCalls++,
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();

      expect(loadMoreCalls, greaterThan(0));
    });

    testWidgets('does not request more pages when hasMore is false', (
      tester,
    ) async {
      var loadMoreCalls = 0;
      await tester.pumpWidget(
        build(
          exercises: List.generate(
            12,
            (index) => ExerciseEntity(
              id: 'exercise-$index',
              name: 'Exercise $index',
              difficultyLevel: 'Beginner',
              targetMuscleGroup: 'Chest',
              primeMoverMuscle: 'Pectoralis Major',
              primaryEquipment: 'Barbell',
              shortVideoUrl: '',
              explanationVideoUrl: '',
            ),
          ),
          onLoadMore: () => loadMoreCalls++,
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();

      expect(loadMoreCalls, 0);
    });
  });
}
