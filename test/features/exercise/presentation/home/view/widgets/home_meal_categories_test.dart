import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_meal_categories.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
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
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<HomeViewModel>.value(
            value: mockHomeViewModel,
            child: const Scaffold(body: HomeMealCategories()),
          ),
        );
      },
    );
  }

  testWidgets('loading meal categories', (tester) async {
    // Arrange
    const loadingState = HomeState(mealCategoriesResource: Resource.loading());

    when(mockHomeViewModel.state).thenReturn(loadingState);
    when(
      mockHomeViewModel.stream,
    ).thenAnswer((_) => Stream.value(loadingState));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('success state displays meal categories', (tester) async {
    // Arrange
    const mealCategory = MealCategoryEntity(
      id: '1',
      name: 'Vegetarian',
      thumbnail: 'https://example.com/vegetarian.png',
      description: 'Vegetarian meals',
    );

    const successState = HomeState(
      mealCategoriesResource: Resource.success([mealCategory]),
    );

    when(mockHomeViewModel.state).thenReturn(successState);
    when(
      mockHomeViewModel.stream,
    ).thenAnswer((_) => Stream.value(successState));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('error state displays error message', (tester) async {
    // Arrange
    const errorState = HomeState(
      mealCategoriesResource: Resource.error(
        ServerFailure(serverMessage: 'Something went wrong'),
      ),
    );

    when(mockHomeViewModel.state).thenReturn(errorState);
    when(mockHomeViewModel.stream).thenAnswer((_) => Stream.value(errorState));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());

    // Assert
    expect(
      find.text(LocaleKeys.errors_something_went_wrong.tr()),
      findsOneWidget,
    );
  });
}
