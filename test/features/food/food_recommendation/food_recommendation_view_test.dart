import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view/food_recommendation_view.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view_model/food_recommendation_cubit.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view_model/food_recommendation_intent.dart';
import 'package:fitness_app/features/food/presentation/food_recommendation/view_model/food_recommendation_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_app.dart';

class MockFoodRecommendationCubit extends Mock
    implements FoodRecommendationCubit {}

const _categories = [
  MealCategoryEntity(id: '1', name: 'Beef', thumbnail: '', description: ''),
  MealCategoryEntity(id: '2', name: 'Chicken', thumbnail: '', description: ''),
];

const _meals = [
  MealSummaryEntity(id: '1', name: 'Beef Stew', thumbnail: ''),
  MealSummaryEntity(id: '2', name: 'Beef Pie', thumbnail: ''),
];

const _loaded = FoodRecommendationState(
  categories: Resource.success(_categories),
  meals: Resource.success(_meals),
);

void main() {
  late MockFoodRecommendationCubit mockCubit;
  late StreamController<BaseUiEvent> events;

  setUpAll(() => registerFallbackValue(const RetryIntent()));

  void givenStates(
    FoodRecommendationState initialState, [
    List<FoodRecommendationState> states = const [],
  ]) {
    whenListen(
      mockCubit,
      Stream<FoodRecommendationState>.fromIterable(states),
      initialState: initialState,
    );
  }

  Widget makeTestable() {
    return makeTestableWidget(
      BlocProvider<FoodRecommendationCubit>.value(
        value: mockCubit,
        child: const FoodRecommendationView(),
      ),
    );
  }

  setUp(() {
    mockCubit = MockFoodRecommendationCubit();
    events = StreamController<BaseUiEvent>.broadcast();
    when(() => mockCubit.eventStream).thenAnswer((_) => events.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
    givenStates(const FoodRecommendationState());
  });

  tearDown(() => events.close());

  group('FoodRecommendationView Widget Tests —', () {
    testWidgets('requests the data when opened', (tester) async {
      await tester.pumpWidget(makeTestable());

      verify(
        () =>
            mockCubit.doIntent(any(that: isA<LoadFoodRecommendationIntent>())),
      ).called(1);
    });

    testWidgets('renders the header with back button and title', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable());

      expect(find.byKey(const Key('foodBackBtn')), findsOneWidget);
      expect(find.text(LocaleKeys.food_food_recommendation), findsOneWidget);
    });

    testWidgets('shows a loader while loading', (tester) async {
      givenStates(
        const FoodRecommendationState(categories: Resource.loading()),
      );

      await tester.pumpWidget(makeTestable());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('mealsGrid')), findsNothing);
    });

    testWidgets('renders the category tabs and the meals grid', (tester) async {
      givenStates(_loaded);

      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.byKey(const Key('mealCategoriesTabs')), findsOneWidget);
      expect(find.text('Beef'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.byKey(const Key('mealsGrid')), findsOneWidget);
      expect(find.text('Beef Stew'), findsOneWidget);
      expect(find.text('Beef Pie'), findsOneWidget);
    });

    testWidgets('tapping a tab sends SelectCategoryIntent with its index', (
      tester,
    ) async {
      givenStates(_loaded);
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      await tester.tap(find.text('Chicken'));

      expect(
        verify(
          () =>
              mockCubit.doIntent(captureAny(that: isA<SelectCategoryIntent>())),
        ).captured.single,
        isA<SelectCategoryIntent>().having((i) => i.index, 'index', 1),
      );
    });

    testWidgets('shows an empty message when the category has no meals', (
      tester,
    ) async {
      givenStates(
        const FoodRecommendationState(
          categories: Resource.success(_categories),
          meals: Resource.success([]),
        ),
      );

      await tester.pumpWidget(makeTestable());

      expect(find.text(LocaleKeys.food_no_meals_found), findsOneWidget);
    });

    testWidgets('shows retry on error and sends RetryIntent when tapped', (
      tester,
    ) async {
      givenStates(
        const FoodRecommendationState(
          categories: Resource.error(NetworkFailure()),
        ),
      );
      await tester.pumpWidget(makeTestable());

      await tester.tap(find.byKey(const Key('mealsRetryBtn')));

      verify(() => mockCubit.doIntent(any(that: isA<RetryIntent>()))).called(1);
    });
  });
}
