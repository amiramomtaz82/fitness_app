import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_recommendations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_recommendations_test.mocks.dart';

@GenerateMocks([HomeViewModel])
void main() {
  late MockHomeViewModel mockHomeViewModel;

  setUp(() {
    mockHomeViewModel = MockHomeViewModel();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<HomeViewModel>.value(
            value: mockHomeViewModel,
            child: const Scaffold(body: HomeRecommendations()),
          ),
        );
      },
    );
  }

  testWidgets('loading home recommendations', (tester) async {
    // Arrange
    const loadingState = HomeState(randomMusclesResource: Resource.loading());

    when(mockHomeViewModel.state).thenReturn(loadingState);
    when(
      mockHomeViewModel.stream,
    ).thenAnswer((_) => Stream.value(loadingState));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('initial state shows no muscles', (tester) async {
    // Arrange
    const initialState = HomeState(randomMusclesResource: Resource.initial());

    when(mockHomeViewModel.state).thenReturn(initialState);
    when(
      mockHomeViewModel.stream,
    ).thenAnswer((_) => Stream.value(initialState));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('success state displays muscles', (tester) async {
    // Arrange
    const muscle = MuscleEntity(
      id: '1',
      name: 'Chest',
      imageUrl: 'https://example.com/chest.png',
    );

    const successState = HomeState(
      randomMusclesResource: Resource.success([muscle]),
    );

    when(mockHomeViewModel.state).thenReturn(successState);
    when(
      mockHomeViewModel.stream,
    ).thenAnswer((_) => Stream.value(successState));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Chest'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}
