import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_popular_training.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeViewModel extends Mock implements HomeViewModel {}

void main() {
  late MockHomeViewModel mockHomeViewModel;

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
      // Arrange
      when(() => mockHomeViewModel.state).thenReturn(const HomeState());
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(const HomeState()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(LocaleKeys.home_popular_training.tr()), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      // Arrange
      const loadingState = HomeState(
        popularTrainingResource: Resource.loading(),
      );

      when(() => mockHomeViewModel.state).thenReturn(loadingState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(loadingState));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error', (tester) async {
      // Arrange
      const errorState = HomeState(
        popularTrainingResource: Resource.error(
          ServerFailure(serverMessage: 'Something went wrong'),
        ),
      );

      when(() => mockHomeViewModel.state).thenReturn(errorState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(errorState));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(LocaleKeys.errors_something_went_wrong.tr()),
        findsOneWidget,
      );
    });

    testWidgets('shows nothing when success with empty list', (tester) async {
      // Arrange
      const successState = HomeState(
        popularTrainingResource: Resource.success([]),
      );

      when(() => mockHomeViewModel.state).thenReturn(successState);
      when(
        () => mockHomeViewModel.stream,
      ).thenAnswer((_) => Stream.value(successState));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows popular trainings when success', (tester) async {
      // Arrange
      const successState = HomeState(
        popularTrainingResource: Resource.success([
          PopularTrainingEntity(
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

      // Act
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
    });
  });
}
