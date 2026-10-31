import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/food/domain/entities/meal_details_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_ingredient.dart';
import 'package:fitness_app/features/food/presentation/food_details/view/food_details_view.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_cubit.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_intent.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFoodDetailsCubit extends MockCubit<FoodDetailsState>
    implements FoodDetailsCubit {}

class InMemoryAssetLoader extends AssetLoader {
  final Map<String, dynamic> data;

  const InMemoryAssetLoader(this.data);

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return data;
  }
}

const watchUrl = 'https://www.youtube.com/watch?v=xvPR2Tfw5k0';

const mealThumb = 'https://www.themealdb.com/images/media/meals/1548772327.jpg';

const salmon = MealDetailsEntity(
  id: '52959',
  name: 'Baked salmon',
  thumbnailUrl: mealThumb,
  instructions: 'Bake until flaky.',
  ingredients: [
    MealIngredient(name: 'Salmon', measure: '350g'),
    MealIngredient(name: 'Fennel', measure: '2 medium'),
  ],
);

const salmonVideo = MealDetailsEntity(
  id: '52959',
  name: 'Baked salmon',
  thumbnailUrl: mealThumb,
  youtubeUrl: watchUrl,
  instructions: 'Bake until flaky.',
  ingredients: [
    MealIngredient(name: 'Salmon', measure: '350g'),
    MealIngredient(name: 'Fennel', measure: '2 medium'),
  ],
);

late Map<String, dynamic> enTranslations;
late Map<String, dynamic> arTranslations;
late MockFoodDetailsCubit cubit;

Future<void> prepareFoodDetailsTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  enTranslations = await readTranslations('assets/translations/en.json');
  arTranslations = await readTranslations('assets/translations/ar.json');
  await EasyLocalization.ensureInitialized();
  registerFallbackValue(const LoadMealDetailsIntent('0'));
}

Future<Map<String, dynamic>> readTranslations(String path) async {
  final json = await File(path).readAsString();
  return jsonDecode(json) as Map<String, dynamic>;
}

void registerFoodDetailsCubit() {
  cubit = MockFoodDetailsCubit();
  when(() => cubit.eventStream).thenAnswer((invocation) {
    return const Stream<BaseUiEvent>.empty();
  });
  when(() => cubit.doIntent(any())).thenAnswer((invocation) {});
}

FoodDetailsState loadingState() {
  return const FoodDetailsState(mealResource: Resource.loading());
}

FoodDetailsState loadedState() {
  return const FoodDetailsState(mealResource: Resource.success(salmon));
}

FoodDetailsState videoState() {
  return const FoodDetailsState(mealResource: Resource.success(salmonVideo));
}

FoodDetailsState unsupportedVideoState() {
  return const FoodDetailsState(
    mealResource: Resource.success(
      MealDetailsEntity(
        name: 'Baked salmon',
        youtubeUrl: 'https://example.com/watch?v=abc',
      ),
    ),
  );
}

FoodDetailsState emptySuccessState() {
  return const FoodDetailsState(
    mealResource: Resource<MealDetailsEntity>.success(null),
  );
}

FoodDetailsState offlineState() {
  return const FoodDetailsState(
    mealResource: Resource.error(NetworkFailure(serverMessage: 'offline')),
  );
}

Future<void> pumpFoodDetails(
  WidgetTester tester,
  FoodDetailsState state,
  String mealId, {
  Locale locale = const Locale('en'),
  Map<String, dynamic>? translations,
}) async {
  await tester.binding.setSurfaceSize(const Size(375, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  whenListen(
    cubit,
    const Stream<FoodDetailsState>.empty(),
    initialState: state,
  );
  await tester.pumpWidget(foodDetailsApp(mealId, locale, translations));
  await tester.pump();
  await tester.pump();
}

Widget foodDetailsApp(
  String mealId,
  Locale locale,
  Map<String, dynamic>? translations,
) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: locale,
    startLocale: locale,
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: InMemoryAssetLoader(translations ?? enTranslations),
    child: FoodDetailsHarness(mealId: mealId),
  );
}

class FoodDetailsHarness extends StatelessWidget {
  const FoodDetailsHarness({super.key, required this.mealId});

  final String mealId;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => foodDetailsMaterialApp(context, mealId),
    );
  }
}

Widget foodDetailsMaterialApp(BuildContext context, String mealId) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    home: FoodDetailsView(mealId: mealId, createCubit: () => cubit),
  );
}

Future<void> pumpFoodDetailsRoute(
  WidgetTester tester,
  FoodDetailsState state,
  String mealId,
) async {
  await prepareDetailsSurface(tester);
  whenListen(
    cubit,
    const Stream<FoodDetailsState>.empty(),
    initialState: state,
  );
  final router = foodDetailsRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(foodDetailsRouterApp(router));
  await openMealDetails(tester, router, mealId);
}

Future<void> prepareDetailsSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(375, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Future<void> openMealDetails(
  WidgetTester tester,
  GoRouter router,
  String mealId,
) async {
  await tester.pump();
  await tester.pump();
  router.push('${AppRoutes.food}/meal/$mealId');
  await tester.pump();
  await tester.pump();
}

GoRouter foodDetailsRouter() {
  return GoRouter(
    initialLocation: AppRoutes.food,
    routes: [foodDetailsBranch()],
  );
}

GoRoute foodDetailsBranch() {
  return GoRoute(
    path: AppRoutes.food,
    builder: (context, state) => const Scaffold(body: Text('food-browse')),
    routes: [foodDetailsMealRoute()],
  );
}

GoRoute foodDetailsMealRoute() {
  return GoRoute(
    path: 'meal/:mealId',
    builder: (context, state) {
      final mealId = state.pathParameters['mealId']?.trim() ?? '';
      return FoodDetailsView(mealId: mealId, createCubit: () => cubit);
    },
  );
}

Widget foodDetailsRouterApp(GoRouter router) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: InMemoryAssetLoader(enTranslations),
    child: FoodDetailsRouterHarness(router: router),
  );
}

class FoodDetailsRouterHarness extends StatelessWidget {
  const FoodDetailsRouterHarness({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => routerMaterialApp(context, router),
    );
  }
}

Widget routerMaterialApp(BuildContext context, GoRouter router) {
  return MaterialApp.router(
    theme: AppTheme.darkTheme,
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,
    routerConfig: router,
  );
}
