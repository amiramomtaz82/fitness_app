import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/exercise_view.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_intent.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_state.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_view_model.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_app.dart';

class _MockExerciseDetailsCubit extends Mock implements ExerciseDetailsCubit {}

const _exercise = ExerciseEntity(
  id: 'exercise-1',
  name: 'Barbell Bench Press',
  difficultyLevel: 'Beginner',
  targetMuscleGroup: 'Chest',
  primeMoverMuscle: 'Pectoralis Major',
  primaryEquipment: 'Barbell',
  shortVideoUrl: 'https://youtu.be/dQw4w9WgXcQ',
  explanationVideoUrl: '',
  mechanics: 'Compound',
);

const _difficultyLevels = [
  DifficultyLevelEntity(id: 'level-1', name: 'Beginner'),
  DifficultyLevelEntity(id: 'level-2', name: 'Intermediate'),
];

const _exercises = ExercisesResultEntity(
  totalExercises: 1,
  totalPages: 1,
  currentPage: 1,
  exercises: [_exercise],
);

const _successState = ExerciseDetailsState(
  difficultyLevels: Resource.success(_difficultyLevels),
  exercises: Resource.success(_exercises),
  selectedDifficultyId: 'level-1',
);

void main() {
  late _MockExerciseDetailsCubit cubit;
  late StreamController<BaseUiEvent> events;

  setUpAll(() async {
    final content = await rootBundle.loadString('assets/translations/en.json');
    final json = jsonDecode(content) as Map<String, dynamic>;
    Localization.load(const Locale('en'), translations: Translations(json));
    registerFallbackValue(const LoadExerciseDetailsIntent(''));
  });

  setUp(() {
    cubit = _MockExerciseDetailsCubit();
    events = StreamController<BaseUiEvent>.broadcast();
    when(() => cubit.eventStream).thenAnswer((_) => events.stream);
    when(() => cubit.close()).thenAnswer((_) async {});
  });

  tearDown(() => events.close());

  Widget makeTestable(ExerciseDetailsState state) {
    whenListen(
      cubit,
      const Stream<ExerciseDetailsState>.empty(),
      initialState: state,
    );
    return makeTestableWidget(
      BlocProvider<ExerciseDetailsCubit>.value(
        value: cubit,
        child: const ExerciseView(muscleId: 'muscle-1', muscleName: 'Chest'),
      ),
    );
  }

  group('ExerciseView —', () {
    testWidgets('renders hero, stats, tabs and exercise data', (tester) async {
      await tester.pumpWidget(makeTestable(_successState));
      await tester.pumpAndSettle();

      expect(find.text('Chest Exercise'), findsOneWidget);
      expect(find.text('30 MIN'), findsOneWidget);
      expect(find.text('130 Cal', findRichText: true), findsOneWidget);
      expect(find.text('Beginner'), findsWidgets);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Barbell Bench Press'), findsOneWidget);
      expect(find.text('Barbell • Beginner'), findsOneWidget);

      final intents = verify(
        () => cubit.doIntent(captureAny()),
      ).captured.cast<ExerciseDetailsIntent>();
      expect(intents.whereType<LoadExerciseDetailsIntent>(), hasLength(1));
    });

    testWidgets('selecting a difficulty dispatches the intent', (tester) async {
      await tester.pumpWidget(makeTestable(_successState));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Intermediate'));
      await tester.pump();

      final intents = verify(
        () => cubit.doIntent(captureAny()),
      ).captured.cast<ExerciseDetailsIntent>();
      final selection = intents.whereType<SelectDifficultyIntent>().single;
      expect(selection.difficultyId, 'level-2');
    });

    testWidgets('shows the empty state when no exercises are returned', (
      tester,
    ) async {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_difficultyLevels),
        exercises: Resource.success(
          ExercisesResultEntity(
            totalExercises: 0,
            totalPages: 0,
            currentPage: 1,
            exercises: [],
          ),
        ),
        selectedDifficultyId: 'level-1',
      );

      await tester.pumpWidget(makeTestable(state));
      await tester.pumpAndSettle();

      expect(find.text(LocaleKeys.exercises_no_exercises.tr()), findsOneWidget);
    });

    testWidgets('retries when loading difficulty levels fails', (tester) async {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.error(NetworkFailure()),
      );

      await tester.pumpWidget(makeTestable(state));
      await tester.pumpAndSettle();

      final retryButton = find.text(LocaleKeys.common_retry.tr());
      await tester.ensureVisible(retryButton);
      await tester.pumpAndSettle();
      await tester.tap(retryButton);
      await tester.pump();

      final intents = verify(
        () => cubit.doIntent(captureAny()),
      ).captured.cast<ExerciseDetailsIntent>();
      expect(intents.whereType<RetryExerciseDetailsIntent>(), hasLength(1));
    });

    testWidgets('shows a loader while the exercises are loading', (
      tester,
    ) async {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_difficultyLevels),
        exercises: Resource.loading(),
      );

      await tester.pumpWidget(makeTestable(state));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the exercise error and retries from the list', (
      tester,
    ) async {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_difficultyLevels),
        exercises: Resource.error(
          NetworkFailure(serverMessage: 'Could not load exercises'),
        ),
        selectedDifficultyId: 'level-1',
      );

      await tester.pumpWidget(makeTestable(state));
      await tester.pumpAndSettle();

      expect(find.text('Could not load exercises'), findsOneWidget);

      final retryButton = find.text(LocaleKeys.common_retry.tr());
      await tester.ensureVisible(retryButton);
      await tester.pumpAndSettle();
      await tester.tap(retryButton);
      await tester.pump();

      final intents = verify(
        () => cubit.doIntent(captureAny()),
      ).captured.cast<ExerciseDetailsIntent>();
      expect(intents.whereType<RetryExerciseDetailsIntent>(), hasLength(1));
    });

    testWidgets('falls back to the default difficulty categories', (
      tester,
    ) async {
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success([]),
        exercises: Resource.success(_exercises),
      );

      await tester.pumpWidget(makeTestable(state));
      await tester.pumpAndSettle();

      expect(find.text('Beginner'), findsWidgets);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets(
      'scales the session time and calories with the exercise count',
      (tester) async {
        const exercises = [
          _exercise,
          ExerciseEntity(
            id: 'exercise-2',
            name: 'Push Up',
            difficultyLevel: 'Intermediate',
            targetMuscleGroup: 'Chest',
            primeMoverMuscle: 'Pectoralis Major',
            primaryEquipment: 'Bodyweight',
            shortVideoUrl: '',
            explanationVideoUrl: '',
          ),
          ExerciseEntity(
            id: 'exercise-3',
            name: 'Cable Fly',
            difficultyLevel: 'Advanced',
            targetMuscleGroup: 'Chest',
            primeMoverMuscle: 'Pectoralis Major',
            primaryEquipment: 'Cable',
            shortVideoUrl: '',
            explanationVideoUrl: '',
          ),
        ];
        const state = ExerciseDetailsState(
          difficultyLevels: Resource.success(_difficultyLevels),
          exercises: Resource.success(
            ExercisesResultEntity(
              totalExercises: 3,
              totalPages: 1,
              currentPage: 1,
              exercises: exercises,
            ),
          ),
          selectedDifficultyId: 'level-1',
        );

        await tester.pumpWidget(makeTestable(state));
        await tester.pumpAndSettle();

        expect(find.text('18 MIN'), findsOneWidget);
        expect(find.text('78 Cal', findRichText: true), findsOneWidget);
        expect(find.text('Push Up'), findsOneWidget);
      },
    );

    testWidgets('warns when an exercise has no playable video', (tester) async {
      const noVideoExercise = ExerciseEntity(
        id: 'exercise-no-video',
        name: 'No Video Exercise',
        difficultyLevel: 'Beginner',
        targetMuscleGroup: 'Chest',
        primeMoverMuscle: 'Pectoralis Major',
        primaryEquipment: 'Barbell',
        shortVideoUrl: '',
        explanationVideoUrl: '',
      );
      const state = ExerciseDetailsState(
        difficultyLevels: Resource.success(_difficultyLevels),
        exercises: Resource.success(
          ExercisesResultEntity(
            totalExercises: 1,
            totalPages: 1,
            currentPage: 1,
            exercises: [noVideoExercise],
          ),
        ),
        selectedDifficultyId: 'level-1',
      );

      await tester.pumpWidget(makeTestable(state));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No Video Exercise'));
      await tester.pumpAndSettle();

      expect(
        find.text(LocaleKeys.exercises_video_unavailable.tr()),
        findsOneWidget,
      );
    });

    testWidgets('shows a snackbar for failures emitted by the cubit', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable(_successState));
      await tester.pumpAndSettle();

      events.add(
        const ShowErrorSnackBarEvent(
          ServerFailure(serverMessage: 'Something exploded'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something exploded'), findsOneWidget);
    });
  });
}
