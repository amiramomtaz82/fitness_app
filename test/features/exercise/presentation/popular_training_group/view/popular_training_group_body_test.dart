import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/popular_training_group_body.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercise_rows.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercises_list.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_muscles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_stats.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_state.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_hero.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_app.dart';
import '../../presentation_fixtures.dart';

class MockPopularTrainingGroupViewModel extends Mock
    implements PopularTrainingGroupViewModel {}

final kLoadedState = PopularTrainingGroupState(
  training: kTraining,
  exercisesResource: const Resource.success([
    kExerciseItem,
    kExerciseItemWithoutVideo,
  ]),
  relatedMuscles: const ['Chest', 'Triceps Brachii'],
  exercisesCount: 2,
  heroImageUrl: kTraining.imageUrl,
);

void main() {
  late MockPopularTrainingGroupViewModel viewModel;
  late StreamController<BaseUiEvent> uiEvents;

  setUpAll(loadTestTranslations);

  setUp(() {
    viewModel = MockPopularTrainingGroupViewModel();
    uiEvents = StreamController<BaseUiEvent>.broadcast();
    when(() => viewModel.eventStream).thenAnswer((_) => uiEvents.stream);
    when(() => viewModel.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await uiEvents.close();
  });

  Future<void> pumpBody(
    WidgetTester tester,
    PopularTrainingGroupState state,
  ) async {
    usePhoneScreenSize(tester);
    whenListen(
      viewModel,
      const Stream<PopularTrainingGroupState>.empty(),
      initialState: state,
    );

    final router = GoRouter(
      initialLocation: AppRoutes.popularTrainingGroup,
      routes: [
        GoRoute(
          path: AppRoutes.popularTrainingGroup,
          builder: (context, settings) =>
              BlocProvider<PopularTrainingGroupViewModel>(
                create: (_) => viewModel,
                child: const PopularTrainingGroupBody(),
              ),
        ),
        GoRoute(
          path: AppRoutes.popularTrainingExercise,
          builder: (context, settings) {
            final exercise = settings.extra! as ExerciseEntity;
            return Scaffold(body: Text('detail-${exercise.id}'));
          },
        ),
      ],
    );

    await tester.pumpWidget(makeTestableRouterWidget(router));
    await tester.pump();
  }

  group('PopularTrainingGroupBody', () {
    testWidgets('renders nothing until a training is prepared', (tester) async {
      await pumpBody(tester, const PopularTrainingGroupState());

      expect(find.byType(AppBackgroundScaffold), findsNothing);
      expect(find.byType(ExerciseHero), findsNothing);
    });

    testWidgets('shows the hero with the localized training title', (
      tester,
    ) async {
      await pumpBody(tester, kLoadedState);

      expect(find.byType(ExerciseHero), findsOneWidget);
      expect(
        find.text(LocaleKeys.exercises_group_title.tr(args: ['Chest'])),
        findsOneWidget,
      );
    });

    testWidgets('shows the stats, the muscles and the exercises sections', (
      tester,
    ) async {
      await pumpBody(tester, kLoadedState);

      expect(find.byType(PopularTrainingGroupStats), findsOneWidget);
      expect(find.byType(PopularTrainingGroupMuscles), findsOneWidget);
      expect(find.byType(PopularTrainingGroupExercisesList), findsOneWidget);
      expect(find.byType(ExerciseItemCard), findsNWidgets(2));
      expect(find.text('Triceps Brachii'), findsOneWidget);
    });

    testWidgets('shows the progress indicator while exercises are loading', (
      tester,
    ) async {
      await pumpBody(
        tester,
        kLoadedState.copyWith(exercisesResource: const Resource.loading()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(PopularTrainingGroupExerciseRows), findsNothing);
    });

    testWidgets('shows the failure message when exercises could not load', (
      tester,
    ) async {
      await pumpBody(
        tester,
        kLoadedState.copyWith(
          exercisesResource: const Resource.error(ServerFailure()),
        ),
      );

      expect(
        find.text(LocaleKeys.errors_something_went_wrong.tr()),
        findsOneWidget,
      );
    });

    testWidgets('dispatches the retry intent when the retry action is tapped', (
      tester,
    ) async {
      await pumpBody(
        tester,
        kLoadedState.copyWith(
          exercisesResource: const Resource.error(ServerFailure()),
        ),
      );

      await tester.tap(find.text(LocaleKeys.common_retry.tr()));
      await tester.pump();

      verify(
        () => viewModel.doIntent(const RetryPopularTrainingGroupIntent()),
      ).called(1);
    });

    testWidgets('opens the exercise details with the tapped exercise', (
      tester,
    ) async {
      await pumpBody(tester, kLoadedState);

      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      expect(find.text('detail-e_2'), findsOneWidget);
    });
  });
}
