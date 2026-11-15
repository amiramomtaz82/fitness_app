import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_difficlulty_levels_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_exercise_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_group_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_intent.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_state.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetExercisesUseCase extends Mock implements GetExercisesUseCase {}

class MockGetDifficultyLevelsUseCase extends Mock
    implements GetDifficultyLevelsUseCase {}

class MockGetMuscleGroupsUseCase extends Mock
    implements GetMuscleGroupsUseCase {}

const _objectId = '69d982ed85f6bfa972bf2220';

const _beginner = DifficultyLevelEntity(id: 'level-1', name: 'Beginner');
const _intermediate = DifficultyLevelEntity(
  id: 'level-2',
  name: 'Intermediate',
);
const _levels = [_intermediate, _beginner];

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

const _pageOne = ExercisesResultEntity(
  totalExercises: 2,
  totalPages: 2,
  currentPage: 1,
  exercises: [_exerciseA],
);

const _pageTwo = ExercisesResultEntity(
  totalExercises: 2,
  totalPages: 2,
  currentPage: 2,
  exercises: [_exerciseB],
);

const _secondPageResult = ExercisesResultEntity(
  totalExercises: 2,
  totalPages: 2,
  currentPage: 1,
  exercises: [_exerciseB],
);

const _groups = [
  MuscleGroupEntity(id: 'chest-id', name: 'Chest'),
  MuscleGroupEntity(id: 'back-id', name: 'Back'),
];

const _busyWithLevels = ExerciseDetailsState(
  difficultyLevels: Resource.loading(),
);

void main() {
  late MockGetExercisesUseCase getExercises;
  late MockGetDifficultyLevelsUseCase getDifficultyLevels;
  late MockGetMuscleGroupsUseCase getMuscleGroups;
  late ExerciseDetailsCubit cubit;

  setUpAll(() {
    registerFallbackValue(const LoadExerciseDetailsIntent(''));
  });

  setUp(() {
    getExercises = MockGetExercisesUseCase();
    getDifficultyLevels = MockGetDifficultyLevelsUseCase();
    getMuscleGroups = MockGetMuscleGroupsUseCase();
    when(
      () => getMuscleGroups(),
    ).thenAnswer((_) async => const SuccessResponse(<MuscleGroupEntity>[]));
    cubit = ExerciseDetailsCubit(
      getExercises,
      getDifficultyLevels,
      getMuscleGroupsUseCase: getMuscleGroups,
    );
  });

  tearDown(() => cubit.close());

  void stubLevels({
    String muscleId = _objectId,
    BaseResponse<List<DifficultyLevelEntity>> response = const SuccessResponse(
      _levels,
    ),
  }) {
    when(
      () => getDifficultyLevels(muscleId: muscleId),
    ).thenAnswer((_) async => response);
  }

  void stubExercises(
    String muscleId,
    String difficultyId,
    int page,
    BaseResponse<ExercisesResultEntity> response,
  ) {
    when(
      () => getExercises(
        muscleId: muscleId,
        difficultyId: difficultyId,
        page: page,
      ),
    ).thenAnswer((_) async => response);
  }

  Future<void> loadInitial() async {
    stubLevels();
    stubExercises(_objectId, _beginner.id, 1, const SuccessResponse(_pageOne));
    cubit.doIntent(const LoadExerciseDetailsIntent(_objectId));
    await pumpEventQueue();
  }

  test('initial state is empty', () {
    expect(cubit.state, const ExerciseDetailsState());
  });

  group('LoadExerciseDetailsIntent —', () {
    blocTest<ExerciseDetailsCubit, ExerciseDetailsState>(
      'loads levels, selects Beginner and loads the first page',
      build: () {
        stubLevels();
        stubExercises(
          _objectId,
          _beginner.id,
          1,
          const SuccessResponse(_pageOne),
        );
        return cubit;
      },
      act: (c) => c.doIntent(
        const LoadExerciseDetailsIntent(_objectId, muscleName: 'Chest'),
      ),
      expect: () => const [
        _busyWithLevels,
        ExerciseDetailsState(difficultyLevels: Resource.success(_levels)),
        ExerciseDetailsState(
          difficultyLevels: Resource.success(_levels),
          selectedDifficultyId: 'level-1',
        ),
        ExerciseDetailsState(
          difficultyLevels: Resource.success(_levels),
          selectedDifficultyId: 'level-1',
          exercises: Resource.loading(),
        ),
        ExerciseDetailsState(
          difficultyLevels: Resource.success(_levels),
          selectedDifficultyId: 'level-1',
          exercises: Resource.success(_pageOne),
        ),
      ],
      verify: (_) {
        verify(() => getDifficultyLevels(muscleId: _objectId)).called(1);
        verify(
          () => getExercises(
            muscleId: _objectId,
            difficultyId: _beginner.id,
            page: 1,
          ),
        ).called(1);
        verifyNever(() => getMuscleGroups());
      },
    );

    blocTest<ExerciseDetailsCubit, ExerciseDetailsState>(
      'falls back to the first level when Beginner is missing',
      build: () {
        stubLevels(
          response: const SuccessResponse([
            DifficultyLevelEntity(id: 'level-3', name: 'Advanced'),
          ]),
        );
        stubExercises(_objectId, 'level-3', 1, const SuccessResponse(_pageOne));
        return cubit;
      },
      act: (c) => c.doIntent(const LoadExerciseDetailsIntent(_objectId)),
      skip: 4,
      expect: () => const [
        ExerciseDetailsState(
          difficultyLevels: Resource.success([
            DifficultyLevelEntity(id: 'level-3', name: 'Advanced'),
          ]),
          selectedDifficultyId: 'level-3',
          exercises: Resource.success(_pageOne),
        ),
      ],
      verify: (_) => verify(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-3', page: 1),
      ).called(1),
    );

    blocTest<ExerciseDetailsCubit, ExerciseDetailsState>(
      'emits an empty exercise result when no levels are available',
      build: () {
        stubLevels(response: const SuccessResponse([]));
        return cubit;
      },
      act: (c) => c.doIntent(const LoadExerciseDetailsIntent(_objectId)),
      expect: () => const [
        _busyWithLevels,
        ExerciseDetailsState(difficultyLevels: Resource.success([])),
        ExerciseDetailsState(
          difficultyLevels: Resource.success([]),
          exercises: Resource.success(
            ExercisesResultEntity(
              totalExercises: 0,
              totalPages: 0,
              currentPage: 1,
              exercises: [],
            ),
          ),
        ),
      ],
      verify: (_) => verifyNever(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      ),
    );

    test('emits a failure event when levels cannot be loaded', () async {
      const failure = NetworkFailure(serverMessage: 'offline');
      stubLevels(
        muscleId: _objectId,
        response: ErrorResponse(failure: failure),
      );

      final eventFuture = cubit.eventStream.first;
      cubit.doIntent(const LoadExerciseDetailsIntent(_objectId));
      await pumpEventQueue();

      final event = await eventFuture;
      expect(event, isA<ShowErrorSnackBarEvent>());
      expect((event as ShowErrorSnackBarEvent).failure, failure);
      expect(cubit.state.difficultyLevels.isError, isTrue);
      verifyNever(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      );
    });

    test('resolves the muscle id from the muscle name', () async {
      when(
        () => getMuscleGroups(),
      ).thenAnswer((_) async => const SuccessResponse(_groups));
      stubLevels(muscleId: 'chest-id');
      stubExercises(
        'chest-id',
        _beginner.id,
        1,
        const SuccessResponse(_pageOne),
      );

      cubit.doIntent(
        const LoadExerciseDetailsIntent('not-an-id', muscleName: 'chest'),
      );
      await pumpEventQueue();

      verify(() => getDifficultyLevels(muscleId: 'chest-id')).called(1);
      expect(cubit.state.exercises.isSuccess, isTrue);
    });

    test(
      'resolves the muscle id by group id when the name does not match',
      () async {
        when(
          () => getMuscleGroups(),
        ).thenAnswer((_) async => const SuccessResponse(_groups));
        stubLevels(muscleId: 'back-id');
        stubExercises(
          'back-id',
          _beginner.id,
          1,
          const SuccessResponse(_pageOne),
        );

        cubit.doIntent(
          const LoadExerciseDetailsIntent('back-id', muscleName: 'unknown'),
        );
        await pumpEventQueue();

        verify(() => getDifficultyLevels(muscleId: 'back-id')).called(1);
      },
    );

    test('falls back to the first group when nothing matches', () async {
      when(
        () => getMuscleGroups(),
      ).thenAnswer((_) async => const SuccessResponse(_groups));
      stubLevels(muscleId: 'chest-id');
      stubExercises(
        'chest-id',
        _beginner.id,
        1,
        const SuccessResponse(_pageOne),
      );

      cubit.doIntent(
        const LoadExerciseDetailsIntent('missing', muscleName: 'missing'),
      );
      await pumpEventQueue();

      verify(() => getDifficultyLevels(muscleId: 'chest-id')).called(1);
    });

    test('keeps the given id when the muscle groups request fails', () async {
      when(() => getMuscleGroups()).thenAnswer(
        (_) async => ErrorResponse<List<MuscleGroupEntity>>(
          failure: const NetworkFailure(),
        ),
      );
      stubLevels(muscleId: 'missing');
      stubExercises(
        'missing',
        _beginner.id,
        1,
        const SuccessResponse(_pageOne),
      );

      cubit.doIntent(const LoadExerciseDetailsIntent('missing'));
      await pumpEventQueue();

      verify(() => getDifficultyLevels(muscleId: 'missing')).called(1);
    });
  });

  group('SelectDifficultyIntent —', () {
    test('selects a valid level and reloads the first page', () async {
      await loadInitial();
      stubExercises(
        _objectId,
        _intermediate.id,
        1,
        const SuccessResponse(_secondPageResult),
      );

      cubit.doIntent(const SelectDifficultyIntent('level-2'));
      await pumpEventQueue();

      expect(cubit.state.selectedDifficultyId, 'level-2');
      expect(cubit.state.exercisesList.single.name, 'Push Up');
      verify(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-2', page: 1),
      ).called(1);
    });

    test('ignores an unknown level', () async {
      await loadInitial();

      cubit.doIntent(const SelectDifficultyIntent('missing'));
      await pumpEventQueue();

      expect(cubit.state.selectedDifficultyId, 'level-1');
      verifyNever(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: 'missing',
          page: any(named: 'page'),
        ),
      );
    });

    test('ignores the already selected level', () async {
      await loadInitial();

      cubit.doIntent(const SelectDifficultyIntent('level-1'));
      await pumpEventQueue();

      verify(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-1', page: 1),
      ).called(1);
    });

    test('ignores a stale response after switching levels', () async {
      final first = Completer<BaseResponse<ExercisesResultEntity>>();
      final second = Completer<BaseResponse<ExercisesResultEntity>>();
      when(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-1', page: 1),
      ).thenAnswer((_) => first.future);
      when(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-2', page: 1),
      ).thenAnswer((_) => second.future);
      stubLevels();

      cubit.doIntent(const LoadExerciseDetailsIntent(_objectId));
      await pumpEventQueue();
      expect(cubit.state.exercises.isLoading, isTrue);
      expect(cubit.state.selectedDifficultyId, 'level-1');

      cubit.doIntent(const SelectDifficultyIntent('level-2'));
      await pumpEventQueue();
      expect(cubit.state.selectedDifficultyId, 'level-2');

      first.complete(const SuccessResponse(_pageOne));
      await pumpEventQueue();
      expect(cubit.state.exercises.isLoading, isTrue);

      second.complete(const SuccessResponse(_secondPageResult));
      await pumpEventQueue();
      expect(cubit.state.exercises.isSuccess, isTrue);
      expect(cubit.state.exercisesList.single.name, 'Push Up');
    });
  });

  group('LoadMoreExercisesIntent —', () {
    test('appends the next page to the existing exercises', () async {
      await loadInitial();
      stubExercises(
        _objectId,
        _beginner.id,
        2,
        const SuccessResponse(_pageTwo),
      );

      cubit.doIntent(const LoadMoreExercisesIntent());
      await pumpEventQueue();

      expect(cubit.state.exercisesList, [_exerciseA, _exerciseB]);
      expect(cubit.state.currentPage, 2);
      verify(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-1', page: 2),
      ).called(1);
    });

    test('does nothing when there are no more pages', () async {
      cubit.emit(
        const ExerciseDetailsState(
          difficultyLevels: Resource.success(_levels),
          exercises: Resource.success(
            ExercisesResultEntity(
              totalExercises: 1,
              totalPages: 1,
              currentPage: 1,
              exercises: [_exerciseA],
            ),
          ),
          selectedDifficultyId: 'level-1',
        ),
      );

      cubit.doIntent(const LoadMoreExercisesIntent());
      await pumpEventQueue();

      verifyNever(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      );
    });

    test('does nothing while a request is already running', () async {
      cubit.emit(
        const ExerciseDetailsState(
          difficultyLevels: Resource.success(_levels),
          exercises: Resource.loading(data: _pageOne),
          selectedDifficultyId: 'level-1',
        ),
      );

      cubit.doIntent(const LoadMoreExercisesIntent());
      await pumpEventQueue();

      verifyNever(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      );
    });
  });

  group('RefreshExercisesIntent —', () {
    test('reloads the first page of the selected level', () async {
      await loadInitial();
      stubExercises(
        _objectId,
        _beginner.id,
        1,
        const SuccessResponse(_pageOne),
      );

      cubit.doIntent(const RefreshExercisesIntent());
      await pumpEventQueue();

      verify(
        () =>
            getExercises(muscleId: _objectId, difficultyId: 'level-1', page: 1),
      ).called(2);
    });

    test('does nothing without a selected level', () async {
      cubit.doIntent(const RefreshExercisesIntent());
      await pumpEventQueue();

      verifyNever(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      );
    });
  });

  group('RetryExerciseDetailsIntent —', () {
    test('reloads levels and exercises after a difficulty failure', () async {
      var levelCalls = 0;
      when(
        () => getDifficultyLevels(muscleId: any(named: 'muscleId')),
      ).thenAnswer((_) async {
        levelCalls++;
        return levelCalls == 1
            ? ErrorResponse<List<DifficultyLevelEntity>>(
                failure: const NetworkFailure(),
              )
            : const SuccessResponse(_levels);
      });
      when(
        () => getExercises(
          muscleId: any(named: 'muscleId'),
          difficultyId: any(named: 'difficultyId'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => const SuccessResponse(_pageOne));

      cubit.doIntent(const LoadExerciseDetailsIntent(_objectId));
      await pumpEventQueue();
      expect(cubit.state.difficultyLevels.isError, isTrue);

      cubit.doIntent(const RetryExerciseDetailsIntent());
      await pumpEventQueue();

      expect(cubit.state.difficultyLevels.isSuccess, isTrue);
      expect(cubit.state.selectedDifficultyId, 'level-1');
      expect(cubit.state.exercises.isSuccess, isTrue);
      expect(levelCalls, 2);
    });

    test('reloads the exercises after an exercise failure', () async {
      stubLevels();
      when(
        () => getExercises(
          muscleId: _objectId,
          difficultyId: _beginner.id,
          page: 1,
        ),
      ).thenAnswer(
        (_) async => ErrorResponse<ExercisesResultEntity>(
          failure: const NetworkFailure(),
        ),
      );

      cubit.doIntent(const LoadExerciseDetailsIntent(_objectId));
      await pumpEventQueue();
      expect(cubit.state.exercises.isError, isTrue);

      stubExercises(
        _objectId,
        _beginner.id,
        1,
        const SuccessResponse(_pageOne),
      );
      cubit.doIntent(const RetryExerciseDetailsIntent());
      await pumpEventQueue();

      expect(cubit.state.exercises.isSuccess, isTrue);
      expect(cubit.state.exercisesList.single.name, 'Barbell Bench Press');
    });
  });
}
