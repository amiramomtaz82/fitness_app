import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/popular_training_group_body.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/popular_training_group_view.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_state.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_hero.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/test_app.dart';
import '../../presentation_fixtures.dart';

class MockPopularTrainingGroupViewModel extends Mock
    implements PopularTrainingGroupViewModel {}

void main() {
  late MockPopularTrainingGroupViewModel viewModel;
  late StreamController<BaseUiEvent> uiEvents;

  setUpAll(() async {
    await loadTestTranslations();
    registerFallbackValue(const InitPopularTrainingGroupIntent(kTraining));
  });

  setUp(() {
    viewModel = MockPopularTrainingGroupViewModel();
    uiEvents = StreamController<BaseUiEvent>.broadcast();
    when(() => viewModel.eventStream).thenAnswer((_) => uiEvents.stream);
    when(() => viewModel.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<PopularTrainingGroupViewModel>()) {
      getIt.unregister<PopularTrainingGroupViewModel>();
    }
    getIt.registerFactory<PopularTrainingGroupViewModel>(() => viewModel);
  });

  tearDown(() async {
    await uiEvents.close();
    if (getIt.isRegistered<PopularTrainingGroupViewModel>()) {
      getIt.unregister<PopularTrainingGroupViewModel>();
    }
  });

  Future<void> pumpView(
    WidgetTester tester,
    PopularTrainingGroupState state,
  ) async {
    usePhoneScreenSize(tester);
    whenListen(
      viewModel,
      const Stream<PopularTrainingGroupState>.empty(),
      initialState: state,
    );

    await tester.pumpWidget(
      makeTestableWidget(const PopularTrainingGroupView(training: kTraining)),
    );
    await tester.pump();
  }

  group('PopularTrainingGroupView', () {
    testWidgets('creates the cubit from the injection container', (
      tester,
    ) async {
      await pumpView(tester, const PopularTrainingGroupState());

      expect(find.byType(PopularTrainingGroupBody), findsOneWidget);
    });

    testWidgets('loads the tapped training through the init intent', (
      tester,
    ) async {
      await pumpView(tester, const PopularTrainingGroupState());

      verify(
        () => viewModel.doIntent(
          any(
            that: isA<InitPopularTrainingGroupIntent>().having(
              (intent) => intent.training,
              'training',
              kTraining,
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('keeps the screen empty until the training is prepared', (
      tester,
    ) async {
      await pumpView(tester, const PopularTrainingGroupState());

      expect(find.byType(AppBackgroundScaffold), findsNothing);
      expect(find.byType(ExerciseHero), findsNothing);
    });

    testWidgets('shows the prepared training in the body', (tester) async {
      await pumpView(
        tester,
        const PopularTrainingGroupState(training: kTraining),
      );

      expect(find.byType(ExerciseHero), findsOneWidget);
      expect(
        find.text(LocaleKeys.exercises_group_title.tr(args: ['Chest'])),
        findsOneWidget,
      );
    });
  });
}
