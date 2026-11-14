import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_cubit.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_intent.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMuscleGroupsUseCase extends Mock
    implements GetMuscleGroupsUseCase {}

class MockGetMusclesByGroupIdUseCase extends Mock
    implements GetMusclesByGroupIdUseCase {}

void main() {
  late MockGetMuscleGroupsUseCase mockGetGroups;
  late MockGetMusclesByGroupIdUseCase mockGetMuscles;
  late WorkoutCubit cubit;

  const group1 = MuscleGroupEntity(id: 'group_1', name: 'Chest');
  const group2 = MuscleGroupEntity(id: 'group_2', name: 'Back');
  const muscle1 = MuscleEntity(id: 'm_1', name: 'Upper Chest', imageUrl: 'u1');
  const muscle2 = MuscleEntity(id: 'm_2', name: 'Lats', imageUrl: 'u2');
  const testFailure = ServerFailure(serverMessage: 'server error');

  const sLoadingGroups = WorkoutState(groupsResource: Resource.loading());
  const sGroupsSuccess = WorkoutState(
    groupsResource: Resource.success([group1, group2]),
  );
  const sGroup1Selected = WorkoutState(
    groupsResource: Resource.success([group1, group2]),
    selectedGroup: group1,
  );
  const sLoadingMuscles = WorkoutState(
    groupsResource: Resource.success([group1, group2]),
    selectedGroup: group1,
    musclesResource: Resource.loading(),
  );
  const sMusclesSuccess = WorkoutState(
    groupsResource: Resource.success([group1, group2]),
    selectedGroup: group1,
    musclesResource: Resource.success([muscle1]),
  );

  setUp(() {
    mockGetGroups = MockGetMuscleGroupsUseCase();
    mockGetMuscles = MockGetMusclesByGroupIdUseCase();
    cubit = WorkoutCubit(mockGetGroups, mockGetMuscles);
  });

  tearDown(() => cubit.close());

  group('WorkoutCubit', () {
    test('initial state is correct', () {
      expect(cubit.state, const WorkoutState());
    });

    group('InitWorkoutsIntent', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'emits loading and success for groups and muscles',
        build: () {
          when(
            () => mockGetGroups(),
          ).thenAnswer((_) async => const SuccessResponse([group1, group2]));
          when(
            () => mockGetMuscles(group1.id),
          ).thenAnswer((_) async => const SuccessResponse([muscle1]));
          return cubit;
        },
        act: (c) => c.doIntent(const InitWorkoutsIntent()),
        expect: () => [
          sLoadingGroups,
          sGroupsSuccess,
          sGroup1Selected,
          sLoadingMuscles,
          sMusclesSuccess,
        ],
        verify: (_) {
          verify(() => mockGetGroups()).called(1);
          verify(() => mockGetMuscles(group1.id)).called(1);
        },
      );

      blocTest<WorkoutCubit, WorkoutState>(
        'does not fetch muscles when group list is empty',
        build: () {
          when(() => mockGetGroups()).thenAnswer(
            (_) async => const SuccessResponse(<MuscleGroupEntity>[]),
          );
          return cubit;
        },
        act: (c) => c.doIntent(const InitWorkoutsIntent()),
        expect: () => [
          sLoadingGroups,
          const WorkoutState(
            groupsResource: Resource.success(<MuscleGroupEntity>[]),
          ),
        ],
        verify: (_) {
          verify(() => mockGetGroups()).called(1);
          verifyNever(() => mockGetMuscles(any()));
        },
      );

      blocTest<WorkoutCubit, WorkoutState>(
        'emits error when fetching groups fails',
        build: () {
          when(() => mockGetGroups()).thenAnswer(
            (_) async =>
                ErrorResponse<List<MuscleGroupEntity>>(failure: testFailure),
          );
          return cubit;
        },
        act: (c) => c.doIntent(const InitWorkoutsIntent()),
        expect: () => [
          sLoadingGroups,
          const WorkoutState(groupsResource: Resource.error(testFailure)),
        ],
        verify: (_) => verify(() => mockGetGroups()).called(1),
      );

      test('emits ShowErrorSnackBarEvent when groups fetch fails', () async {
        when(() => mockGetGroups()).thenAnswer(
          (_) async =>
              ErrorResponse<List<MuscleGroupEntity>>(failure: testFailure),
        );
        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doIntent(const InitWorkoutsIntent());
        await pumpEventQueue();

        expect(events, [
          isA<ShowErrorSnackBarEvent>().having(
            (e) => e.failure,
            'failure',
            testFailure,
          ),
        ]);
      });

      blocTest<WorkoutCubit, WorkoutState>(
        'emits error when muscles fetch fails',
        build: () {
          when(
            () => mockGetGroups(),
          ).thenAnswer((_) async => const SuccessResponse([group1]));
          when(() => mockGetMuscles(group1.id)).thenAnswer(
            (_) async =>
                ErrorResponse<List<MuscleEntity>>(failure: testFailure),
          );
          return cubit;
        },
        act: (c) => c.doIntent(const InitWorkoutsIntent()),
        expect: () => [
          sLoadingGroups,
          const WorkoutState(groupsResource: Resource.success([group1])),
          const WorkoutState(
            groupsResource: Resource.success([group1]),
            selectedGroup: group1,
          ),
          const WorkoutState(
            groupsResource: Resource.success([group1]),
            selectedGroup: group1,
            musclesResource: Resource.loading(),
          ),
          const WorkoutState(
            groupsResource: Resource.success([group1]),
            selectedGroup: group1,
            musclesResource: Resource.error(testFailure),
          ),
        ],
      );
    });

    group('SelectMuscleGroupIntent', () {
      blocTest<WorkoutCubit, WorkoutState>(
        'fetches muscles for selected group',
        build: () {
          when(
            () => mockGetMuscles(group2.id),
          ).thenAnswer((_) async => const SuccessResponse([muscle2]));
          return cubit;
        },
        seed: () => sMusclesSuccess,
        act: (c) => c.doIntent(const SelectMuscleGroupIntent(group2)),
        expect: () => [
          const WorkoutState(
            groupsResource: Resource.success([group1, group2]),
            selectedGroup: group2,
            musclesResource: Resource.success([muscle1]),
          ),
          const WorkoutState(
            groupsResource: Resource.success([group1, group2]),
            selectedGroup: group2,
            musclesResource: Resource.loading(),
          ),
          const WorkoutState(
            groupsResource: Resource.success([group1, group2]),
            selectedGroup: group2,
            musclesResource: Resource.success([muscle2]),
          ),
        ],
        verify: (_) => verify(() => mockGetMuscles(group2.id)).called(1),
      );

      blocTest<WorkoutCubit, WorkoutState>(
        'does not re-fetch when selecting already selected group',
        build: () => cubit,
        seed: () => const WorkoutState(
          groupsResource: Resource.success([group1]),
          selectedGroup: group1,
          musclesResource: Resource.success([muscle1]),
        ),
        act: (c) => c.doIntent(const SelectMuscleGroupIntent(group1)),
        expect: () => <WorkoutState>[],
        verify: (_) => verifyZeroInteractions(mockGetMuscles),
      );
    });

    group('RetryFetchMusclesIntent', () {
      blocTest<WorkoutCubit, WorkoutState>(
        're-initializes when groups resource is in error',
        build: () {
          when(
            () => mockGetGroups(),
          ).thenAnswer((_) async => const SuccessResponse([group1, group2]));
          when(
            () => mockGetMuscles(group1.id),
          ).thenAnswer((_) async => const SuccessResponse([muscle1]));
          return cubit;
        },
        seed: () =>
            const WorkoutState(groupsResource: Resource.error(testFailure)),
        act: (c) => c.doIntent(const RetryFetchMusclesIntent()),
        expect: () => [
          sLoadingGroups,
          sGroupsSuccess,
          sGroup1Selected,
          sLoadingMuscles,
          sMusclesSuccess,
        ],
        verify: (_) {
          verify(() => mockGetGroups()).called(1);
          verify(() => mockGetMuscles(group1.id)).called(1);
        },
      );

      blocTest<WorkoutCubit, WorkoutState>(
        're-fetches muscles when selected group exists and muscles is error',
        build: () {
          when(
            () => mockGetMuscles(group1.id),
          ).thenAnswer((_) async => const SuccessResponse([muscle1]));
          return cubit;
        },
        seed: () => const WorkoutState(
          groupsResource: Resource.success([group1]),
          selectedGroup: group1,
          musclesResource: Resource.error(testFailure),
        ),
        act: (c) => c.doIntent(const RetryFetchMusclesIntent()),
        expect: () => [
          const WorkoutState(
            groupsResource: Resource.success([group1]),
            selectedGroup: group1,
            musclesResource: Resource.loading(),
          ),
          const WorkoutState(
            groupsResource: Resource.success([group1]),
            selectedGroup: group1,
            musclesResource: Resource.success([muscle1]),
          ),
        ],
        verify: (_) {
          verify(() => mockGetMuscles(group1.id)).called(1);
          verifyNever(() => mockGetGroups());
        },
      );
    });
  });
}
