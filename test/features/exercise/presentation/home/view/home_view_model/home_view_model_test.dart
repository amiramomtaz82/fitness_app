import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_popular_trainings_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_random_muscles_use_case.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_categories_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_intent.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRandomMusclesUseCase extends Mock
    implements GetRandomMusclesUseCase {}

class MockGetMuscleGroupsUseCase extends Mock
    implements GetMuscleGroupsUseCase {}

class MockGetMusclesByGroupIdUseCase extends Mock
    implements GetMusclesByGroupIdUseCase {}

class MockGetMealCategoriesUseCase extends Mock
    implements GetMealCategoriesUseCase {}

class MockGetPopularTrainingsUseCase extends Mock
    implements GetPopularTrainingsUseCase {}

void main() {
  late MockGetRandomMusclesUseCase mockGetRandomMuscles;
  late MockGetMuscleGroupsUseCase mockGetMuscleGroups;
  late MockGetMusclesByGroupIdUseCase mockGetMusclesByGroupId;
  late MockGetMealCategoriesUseCase mockGetMealCategories;
  late MockGetPopularTrainingsUseCase mockGetPopularTrainings;
  late HomeViewModel cubit;

  const group1 = MuscleGroupEntity(id: 'group_1', name: 'Chest');
  const group2 = MuscleGroupEntity(id: 'group_2', name: 'Back');
  const muscle1 = MuscleEntity(id: 'm_1', name: 'Upper Chest', imageUrl: 'u1');
  const muscle2 = MuscleEntity(id: 'm_2', name: 'Lats', imageUrl: 'u2');
  const mealCategory1 = MealCategoryEntity(
    id: '1',
    name: 'Beef',
    thumbnail: 'beef.png',
    description: 'Beef desc',
  );
  const popularTraining1 = PopularTrainingEntity(
    muscleName: 'Chest',
    levelName: 'Beginner',
    exercisesCount: 2,
    imageUrl: 'img',
  );

  const testFailure = ServerFailure(serverMessage: 'server error');

  setUp(() {
    mockGetRandomMuscles = MockGetRandomMusclesUseCase();
    mockGetMuscleGroups = MockGetMuscleGroupsUseCase();
    mockGetMusclesByGroupId = MockGetMusclesByGroupIdUseCase();
    mockGetMealCategories = MockGetMealCategoriesUseCase();
    mockGetPopularTrainings = MockGetPopularTrainingsUseCase();
    cubit = HomeViewModel(
      mockGetRandomMuscles,
      mockGetMuscleGroups,
      mockGetMusclesByGroupId,
      mockGetMealCategories,
      mockGetPopularTrainings,
    );
  });

  tearDown(() => cubit.close());

  group('HomeViewModel', () {
    test('initial state is correct', () {
      expect(cubit.state, const HomeState());
    });

    group('InitHomeIntent', () {
      blocTest<HomeViewModel, HomeState>(
        'emits loading then success for all home sections on success',
        build: () {
          when(
            () => mockGetRandomMuscles(),
          ).thenAnswer((_) async => const SuccessResponse([muscle1]));

          when(
            () => mockGetMuscleGroups(),
          ).thenAnswer((_) async => const SuccessResponse([group1, group2]));

          when(
            () => mockGetMusclesByGroupId(group1.id),
          ).thenAnswer((_) async => const SuccessResponse([muscle1]));

          when(
            () => mockGetMealCategories(),
          ).thenAnswer((_) async => const SuccessResponse([mealCategory1]));

          when(
            () => mockGetPopularTrainings(),
          ).thenAnswer((_) async => const SuccessResponse([popularTraining1]));

          return cubit;
        },
        act: (c) => c.doIntent(const InitHomeIntent()),
        expect: () => [
          const HomeState(
            groupsResource: Resource.initial(),
            randomMusclesResource: Resource.loading(),
            groupMusclesResource: Resource.initial(),
            mealCategoriesResource: Resource.initial(),
            popularTrainingResource: Resource.initial(),
          ),
          const HomeState(
            groupsResource: Resource.loading(),
            randomMusclesResource: Resource.loading(),
            groupMusclesResource: Resource.initial(),
            mealCategoriesResource: Resource.initial(),
            popularTrainingResource: Resource.initial(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.loading(),
            randomMusclesResource: Resource.loading(),
            groupMusclesResource: Resource.initial(),
            mealCategoriesResource: Resource.loading(),
            popularTrainingResource: Resource.initial(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.loading(),
            randomMusclesResource: Resource.loading(),
            groupMusclesResource: Resource.initial(),
            mealCategoriesResource: Resource.loading(),
            popularTrainingResource: Resource.loading(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.loading(),
            randomMusclesResource: Resource.success([muscle1]),
            groupMusclesResource: Resource.initial(),
            mealCategoriesResource: Resource.loading(),
            popularTrainingResource: Resource.loading(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            randomMusclesResource: Resource.success([muscle1]),
            groupMusclesResource: Resource.initial(),
            mealCategoriesResource: Resource.loading(),
            popularTrainingResource: Resource.loading(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            randomMusclesResource: Resource.success([muscle1]),
            groupMusclesResource: Resource.loading(),
            mealCategoriesResource: Resource.loading(),
            popularTrainingResource: Resource.loading(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            randomMusclesResource: Resource.success([muscle1]),
            groupMusclesResource: Resource.loading(),
            mealCategoriesResource: Resource.success([mealCategory1]),
            popularTrainingResource: Resource.loading(),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            randomMusclesResource: Resource.success([muscle1]),
            groupMusclesResource: Resource.loading(),
            mealCategoriesResource: Resource.success([mealCategory1]),
            popularTrainingResource: Resource.success([popularTraining1]),
            selectedGroupIndex: 0,
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            randomMusclesResource: Resource.success([muscle1]),
            groupMusclesResource: Resource.success([muscle1]),
            mealCategoriesResource: Resource.success([mealCategory1]),
            popularTrainingResource: Resource.success([popularTraining1]),
            selectedGroupIndex: 0,
          ),
        ],
        verify: (_) {
          verify(() => mockGetRandomMuscles()).called(1);
          verify(() => mockGetMuscleGroups()).called(1);
          verify(() => mockGetMusclesByGroupId(group1.id)).called(1);
          verify(() => mockGetMealCategories()).called(1);
          verify(() => mockGetPopularTrainings()).called(1);
        },
      );
    });

    group('SelectMuscleGroupIntent', () {
      blocTest<HomeViewModel, HomeState>(
        'emits updated selection and loads muscles for the selected group',
        build: () {
          when(
            () => mockGetMusclesByGroupId(group2.id),
          ).thenAnswer((_) async => const SuccessResponse([muscle2]));

          return cubit;
        },
        seed: () => const HomeState(
          groupsResource: Resource.success([group1, group2]),
          selectedGroupIndex: 0,
          groupMusclesResource: Resource.success([muscle1]),
        ),
        act: (c) => c.doIntent(const SelectMuscleGroupIntent(1)),
        expect: () => [
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            selectedGroupIndex: 1,
            groupMusclesResource: Resource.success([muscle1]),
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            selectedGroupIndex: 1,
            groupMusclesResource: Resource.loading(),
          ),
          const HomeState(
            groupsResource: Resource.success([group1, group2]),
            selectedGroupIndex: 1,
            groupMusclesResource: Resource.success([muscle2]),
          ),
        ],
        verify: (_) =>
            verify(() => mockGetMusclesByGroupId(group2.id)).called(1),
      );

      blocTest<HomeViewModel, HomeState>(
        'does not fetch muscles when the same group is selected again',
        build: () => cubit,
        seed: () => const HomeState(
          groupsResource: Resource.success([group1]),
          selectedGroupIndex: 0,
          groupMusclesResource: Resource.success([muscle1]),
        ),
        act: (c) => c.doIntent(const SelectMuscleGroupIntent(0)),
        expect: () => <HomeState>[],
        verify: (_) => verifyNever(() => mockGetMusclesByGroupId(any())),
      );

      blocTest<HomeViewModel, HomeState>(
        'does not fetch when the group index is out of range',
        build: () => cubit,
        seed: () => const HomeState(
          groupsResource: Resource.success([group1]),
          selectedGroupIndex: 0,
        ),
        act: (c) => c.doIntent(const SelectMuscleGroupIntent(5)),
        expect: () => <HomeState>[],
        verify: (_) => verifyNever(() => mockGetMusclesByGroupId(any())),
      );
    });

    group('failure handling', () {
      test('emits ShowErrorSnackBarEvent when random muscles fail', () async {
        final events = <BaseUiEvent>[];
        final subscription = cubit.eventStream.listen(events.add);

        when(() => mockGetRandomMuscles()).thenAnswer(
          (_) async => ErrorResponse<List<MuscleEntity>>(failure: testFailure),
        );

        when(
          () => mockGetMuscleGroups(),
        ).thenAnswer((_) async => const SuccessResponse([group1, group2]));

        when(
          () => mockGetMusclesByGroupId(group1.id),
        ).thenAnswer((_) async => const SuccessResponse([muscle1]));

        when(
          () => mockGetMealCategories(),
        ).thenAnswer((_) async => const SuccessResponse([mealCategory1]));

        when(
          () => mockGetPopularTrainings(),
        ).thenAnswer((_) async => const SuccessResponse([popularTraining1]));

        cubit.doIntent(const InitHomeIntent());
        await pumpEventQueue();
        await subscription.cancel();

        expect(events, [
          isA<ShowErrorSnackBarEvent>().having(
            (e) => e.failure,
            'failure',
            testFailure,
          ),
        ]);
      });
    });
  });
}
