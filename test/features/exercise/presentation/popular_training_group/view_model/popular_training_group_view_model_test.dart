import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_popular_training_exercises_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_state.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPopularTrainingExercisesUseCase extends Mock
    implements GetPopularTrainingExercisesUseCase {}

void main() {
  late MockGetPopularTrainingExercisesUseCase mockGetExercises;
  late PopularTrainingGroupViewModel viewModel;

  const training = PopularTrainingEntity(
    primeMoverMuscleId: 'm_1',
    difficultyLevelId: 'l_1',
    muscleName: 'Chest',
    levelName: 'Beginner',
    exercisesCount: 1,
    imageUrl: 'u1',
  );

  const exercise = ExerciseEntity(
    id: 'e_1',
    name: 'Bench Press',
    difficultyLevel: 'Beginner',
  );

  const exerciseItem = GroupExerciseItem(
    exercise: exercise,
    name: 'Bench Press',
    subtitle: 'Beginner',
  );

  const preparedState = PopularTrainingGroupState(
    training: training,
    exercisesCount: 1,
    heroImageUrl: 'u1',
  );

  const testFailure = ServerFailure(serverMessage: 'server error');

  setUp(() {
    mockGetExercises = MockGetPopularTrainingExercisesUseCase();
    viewModel = PopularTrainingGroupViewModel(mockGetExercises);
  });

  tearDown(() => viewModel.close());

  group('PopularTrainingGroupViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.state, const PopularTrainingGroupState());
    });

    blocTest<PopularTrainingGroupViewModel, PopularTrainingGroupState>(
      'emits prepared training, loading then mapped exercises on init',
      build: () {
        when(
          () => mockGetExercises(
            primeMoverMuscleId: 'm_1',
            difficultyLevelId: 'l_1',
          ),
        ).thenAnswer((_) async => const SuccessResponse([exercise]));

        return viewModel;
      },
      act: (cubit) =>
          cubit.doIntent(const InitPopularTrainingGroupIntent(training)),
      expect: () => const [
        preparedState,
        PopularTrainingGroupState(
          training: training,
          exercisesResource: Resource.loading(),
          exercisesCount: 1,
          heroImageUrl: 'u1',
        ),
        PopularTrainingGroupState(
          training: training,
          exercisesResource: Resource.success([exerciseItem]),
          exercisesCount: 1,
          heroImageUrl: 'u1',
        ),
      ],
    );

    blocTest<PopularTrainingGroupViewModel, PopularTrainingGroupState>(
      'emits error resource when the use case fails',
      build: () {
        when(
          () => mockGetExercises(
            primeMoverMuscleId: 'm_1',
            difficultyLevelId: 'l_1',
          ),
        ).thenAnswer(
          (_) async =>
              ErrorResponse<List<ExerciseEntity>>(failure: testFailure),
        );

        return viewModel;
      },
      act: (cubit) =>
          cubit.doIntent(const InitPopularTrainingGroupIntent(training)),
      skip: 2,
      expect: () => const [
        PopularTrainingGroupState(
          training: training,
          exercisesResource: Resource.error(testFailure),
          exercisesCount: 1,
          heroImageUrl: 'u1',
        ),
      ],
    );

    blocTest<PopularTrainingGroupViewModel, PopularTrainingGroupState>(
      'emits a validation failure when training identifiers are missing',
      build: () => viewModel,
      expect: () => const [
        PopularTrainingGroupState(
          training: PopularTrainingEntity(
            primeMoverMuscleId: '',
            difficultyLevelId: '',
            muscleName: 'Chest',
            levelName: 'Beginner',
            exercisesCount: 1,
          ),
          exercisesCount: 1,
        ),
        PopularTrainingGroupState(
          training: PopularTrainingEntity(
            primeMoverMuscleId: '',
            difficultyLevelId: '',
            muscleName: 'Chest',
            levelName: 'Beginner',
            exercisesCount: 1,
          ),
          exercisesResource: Resource.loading(),
          exercisesCount: 1,
        ),
        PopularTrainingGroupState(
          training: PopularTrainingEntity(
            primeMoverMuscleId: '',
            difficultyLevelId: '',
            muscleName: 'Chest',
            levelName: 'Beginner',
            exercisesCount: 1,
          ),
          exercisesResource: Resource.error(ValidationFailure()),
          exercisesCount: 1,
        ),
      ],
      act: (cubit) async {
        final events = <BaseUiEvent>[];
        final subscription = cubit.eventStream.listen(events.add);
        cubit.doIntent(
          const InitPopularTrainingGroupIntent(
            PopularTrainingEntity(
              primeMoverMuscleId: '',
              difficultyLevelId: '',
              muscleName: 'Chest',
              levelName: 'Beginner',
              exercisesCount: 1,
            ),
          ),
        );
        await pumpEventQueue();
        expect(events, hasLength(1));
        expect(events.single, isA<ShowErrorSnackBarEvent>());
        await subscription.cancel();
      },
      verify: (_) {
        verifyNever(
          () => mockGetExercises(
            primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
            difficultyLevelId: any(named: 'difficultyLevelId'),
          ),
        );
      },
    );

    test('rejects whitespace training identifiers', () async {
      const invalidTraining = PopularTrainingEntity(
        primeMoverMuscleId: ' ',
        difficultyLevelId: 'l_1',
        muscleName: 'Chest',
        levelName: 'Beginner',
        exercisesCount: 1,
      );

      viewModel.doIntent(const InitPopularTrainingGroupIntent(invalidTraining));
      await pumpEventQueue();

      expect(
        viewModel.state.exercisesResource.failure,
        isA<ValidationFailure>(),
      );
      verifyNever(
        () => mockGetExercises(
          primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
          difficultyLevelId: any(named: 'difficultyLevelId'),
        ),
      );
    });

    blocTest<PopularTrainingGroupViewModel, PopularTrainingGroupState>(
      'emits a snackbar event when loading fails',
      build: () {
        when(
          () => mockGetExercises(
            primeMoverMuscleId: 'm_1',
            difficultyLevelId: 'l_1',
          ),
        ).thenAnswer(
          (_) async =>
              ErrorResponse<List<ExerciseEntity>>(failure: testFailure),
        );

        return viewModel;
      },
      seed: () => const PopularTrainingGroupState(training: training),
      act: (cubit) async {
        final events = <BaseUiEvent>[];
        final subscription = cubit.eventStream.listen(events.add);
        cubit.doIntent(const RetryPopularTrainingGroupIntent());
        await pumpEventQueue();
        expect(events, hasLength(1));
        expect(events.single, isA<ShowErrorSnackBarEvent>());
        await subscription.cancel();
      },
      verify: (cubit) {
        verify(
          () => mockGetExercises(
            primeMoverMuscleId: 'm_1',
            difficultyLevelId: 'l_1',
          ),
        ).called(1);
      },
      expect: () => const [
        PopularTrainingGroupState(
          training: training,
          exercisesResource: Resource.loading(),
        ),
        PopularTrainingGroupState(
          training: training,
          exercisesResource: Resource.error(testFailure),
        ),
      ],
    );

    test('retry without a loaded training does nothing', () async {
      viewModel.doIntent(const RetryPopularTrainingGroupIntent());
      await pumpEventQueue();

      expect(viewModel.state, const PopularTrainingGroupState());
      verifyNever(
        () => mockGetExercises(
          primeMoverMuscleId: any(named: 'primeMoverMuscleId'),
          difficultyLevelId: any(named: 'difficultyLevelId'),
        ),
      );
    });
  });
}
