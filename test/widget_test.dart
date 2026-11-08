import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_screen.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
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
    when(() => mockHomeViewModel.state).thenReturn(const HomeState());
    when(
      () => mockHomeViewModel.stream,
    ).thenAnswer((_) => Stream.value(const HomeState()));
    when(
      () => mockHomeViewModel.eventStream,
    ).thenAnswer((_) => const Stream<BaseUiEvent>.empty());
  });

  testWidgets('HomeScreen renders successfully', (tester) async {
    // Arrange & Act
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) {
          return MaterialApp(
            home: BlocProvider<HomeViewModel>.value(
              value: mockHomeViewModel,
              child: const HomeScreen(),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
