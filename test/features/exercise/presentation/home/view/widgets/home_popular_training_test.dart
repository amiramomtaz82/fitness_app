import 'package:fitness_app/app/routes_names.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_popular_training.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/popular_training_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../helpers/test_app.dart';

class MockHomeViewModel extends Mock implements HomeViewModel {}

void main() {
  late MockHomeViewModel mockHomeViewModel;

  setUpAll(loadTestTranslations);

  setUp(() {
    mockHomeViewModel = MockHomeViewModel();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<HomeViewModel>.value(
            value: mockHomeViewModel,
            child: const Scaffold(body: HomePopularTraining()),
          ),
        );
      },
    );
  }

  group('HomePopularTraining', () {
    testWidgets('renders title when initial', (tester) async {
      when(() => mockHomeViewModel.state).thenReturn(const HomeState());
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(const HomeState()));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(LocaleKeys.home_popular_training.tr()), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      const loadingState = HomeState(
        popularTrainingResource: Resource.loading(),
      );

      when(() => mockHomeViewModel.state).thenReturn(loadingState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(loadingState));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error', (tester) async {
      const errorState = HomeState(
        popularTrainingResource: Resource.error(
          ServerFailure(serverMessage: 'Something went wrong'),
        ),
      );

      when(() => mockHomeViewModel.state).thenReturn(errorState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(errorState));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.text(LocaleKeys.errors_something_went_wrong.tr()),
        findsOneWidget,
      );
    });

    testWidgets('shows nothing when success with empty list', (tester) async {
      const successState = HomeState(
        popularTrainingResource: Resource.success([]),
      );

      when(() => mockHomeViewModel.state).thenReturn(successState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(successState));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows popular trainings when success', (tester) async {
      const successState = HomeState(
        popularTrainingResource: Resource.success([
          PopularTrainingEntity(
            primeMoverMuscleId: 'muscle_1',
            difficultyLevelId: 'level_1',
            muscleName: 'Chest',
            levelName: 'Pro',
            exercisesCount: 2,
            imageUrl: 'https://example.com/chest.png',
          ),
        ]),
      );

      when(() => mockHomeViewModel.state).thenReturn(successState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(successState));

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
    });

    testWidgets('opens the selected training group when tapped', (
      tester,
    ) async {
      const training = PopularTrainingEntity(
        primeMoverMuscleId: 'muscle_1',
        difficultyLevelId: 'level_1',
        muscleName: 'Chest',
        levelName: 'Beginner',
        exercisesCount: 2,
      );
      const successState = HomeState(
        popularTrainingResource: Resource.success([training]),
      );
      when(() => mockHomeViewModel.state).thenReturn(successState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(successState));

      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => BlocProvider<HomeViewModel>.value(
              value: mockHomeViewModel,
              child: const Scaffold(body: HomePopularTraining()),
            ),
          ),
          GoRoute(
            path: AppRoutes.popularTrainingGroup,
            builder: (context, state) {
              final selectedTraining = state.extra! as PopularTrainingEntity;
              return Scaffold(
                body: Text(
                  '${selectedTraining.primeMoverMuscleId}:'
                  '${selectedTraining.difficultyLevelId}',
                ),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      usePhoneScreenSize(tester);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chest').last);
      await tester.pumpAndSettle();

      expect(find.text('muscle_1:level_1'), findsOneWidget);
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.popularTrainingGroup,
      );
    });
  });
}
