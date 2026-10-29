import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:fitness_app/features/food/presentation/food_browse/view/food_browse_view.dart';
import 'package:fitness_app/features/food/presentation/food_browse/view_model/food_browse_cubit.dart';
import 'package:fitness_app/features/food/presentation/food_browse/view_model/food_browse_intent.dart';
import 'package:fitness_app/features/food/presentation/food_browse/view_model/food_browse_state.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodBrowseCubit extends MockCubit<FoodBrowseState>
    implements FoodBrowseCubit {}

const seafood = MealCategoryEntity(
  id: '1',
  name: 'Seafood',
  thumbnail: 'assets/images/food.png',
  description: '',
);

const beef = MealCategoryEntity(
  id: '2',
  name: 'Beef',
  thumbnail: 'assets/images/food.png',
  description: '',
);

const salmon = MealSummaryEntity(
  id: '52959',
  name: 'Baked salmon',
  thumbnail: 'assets/images/food.png',
);

void main() {
  late MockFoodBrowseCubit cubit;

  setUpAll(() {
    registerFallbackValue(const LoadFoodBrowseIntent());
  });

  setUp(() {
    cubit = MockFoodBrowseCubit();
    showBrowse(cubit, loadedBrowse());
  });

  testWidgets('opens the selected meal and category', (tester) async {
    await pumpBrowse(tester, cubit);

    expect(find.text('Seafood'), findsOneWidget);
    expect(find.text('Beef'), findsOneWidget);
    expect(find.text('Baked salmon'), findsOneWidget);

    await tester.tap(find.text('Beef'));
    await tester.pump();
    verify(
      () => cubit.doIntent(any(that: isA<SelectFoodCategoryIntent>())),
    ).called(1);
    verify(
      () => cubit.doIntent(any(that: isA<LoadFoodBrowseIntent>())),
    ).called(1);

    await tester.tap(find.text('Baked salmon'));
    await tester.pump();
    await tester.pump();
    expect(find.text('details 52959'), findsOneWidget);
  });
}

void showBrowse(MockFoodBrowseCubit cubit, FoodBrowseState state) {
  whenListen(cubit, const Stream<FoodBrowseState>.empty(), initialState: state);
  when(() => cubit.doIntent(any())).thenReturn(null);
}

FoodBrowseState loadedBrowse() {
  return const FoodBrowseState(
    categories: Resource.success([seafood, beef]),
    meals: Resource.success([salmon]),
    selectedCategory: 'Seafood',
    mealsToken: 1,
  );
}

Future<void> pumpBrowse(WidgetTester tester, FoodBrowseCubit cubit) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = browseRouter(cubit);
  addTearDown(router.dispose);
  await tester.pumpWidget(browseApp(router));
  for (var frame = 0; frame < 8; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.text('Seafood').evaluate().isNotEmpty) return;
  }
}

GoRouter browseRouter(FoodBrowseCubit cubit) {
  return GoRouter(
    initialLocation: AppRoutes.food,
    routes: [
      GoRoute(
        path: AppRoutes.food,
        builder: (context, state) => browseScreen(cubit),
        routes: [
          GoRoute(
            path: 'meal/:mealId',
            builder: (context, state) {
              return Text('details ${state.pathParameters['mealId']}');
            },
          ),
        ],
      ),
    ],
  );
}

Widget browseApp(GoRouter router) {
  return EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    useOnlyLangCode: true,
    child: BrowseHarness(router: router),
  );
}

class BrowseHarness extends StatelessWidget {
  const BrowseHarness({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp.router(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routerConfig: router,
        );
      },
    );
  }
}

Widget browseScreen(FoodBrowseCubit cubit) {
  return BlocProvider.value(value: cubit, child: const FoodBrowseScreen());
}
