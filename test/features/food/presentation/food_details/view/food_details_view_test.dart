import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_youtube_video.dart';
import 'package:fitness_app/features/food/presentation/food_details/view/widgets/food_details_back.dart';
import 'package:fitness_app/features/food/presentation/food_details/view/widgets/food_details_media.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_intent.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'food_details_view_harness.dart';

void main() {
  setUpAll(prepareFoodDetailsTests);
  setUp(registerFoodDetailsCubit);
  tearDown(unregisterFoodDetailsCubit);
  registerFoodDetailsWidgetTests();
}

void registerFoodDetailsWidgetTests() {
  testWidgets('shows a loading indicator', showLoading);
  testWidgets('shows the loaded meal and its ingredients', showLoadedMeal);
  testWidgets('plays a supported YouTube URL', showPlayableVideo);
  testWidgets(
    'keeps an unsupported video URL unavailable',
    showUnsupportedVideo,
  );
  testWidgets('shows meal not found without meal details', showMissingMeal);
  testWidgets('shows meal not found when success has no meal', showEmptyMeal);
  testWidgets('shows the use case failure', showFailure);
  testWidgets('dispatches the supplied meal id', showDispatchedMealId);
  testWidgets('pops when the back button is pressed', popOnBack);
  testWidgets('shows the Arabic unavailable nutrition message', showArabicNote);
}

Future<void> showLoading(WidgetTester tester) async {
  await pumpFoodDetails(tester, loadingState(), '52959');
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(progressColor(tester), AppColors.orange);
  expect(find.text('Baked salmon'), findsNothing);
  expectDetailsBackOnly(tester);
}

Future<void> showLoadedMeal(WidgetTester tester) async {
  await pumpFoodDetails(tester, loadedState(), '52959');
  expectSalmonDetails();
  expect(videoWidget(tester).videoUrl, isEmpty);
  expectClearPlayer(tester);
  expect(imageUrls(tester), contains(mealThumb));
  expectDetailsBackOnly(tester);
  expectTitleOnMedia(tester);
}

Future<void> showPlayableVideo(WidgetTester tester) async {
  await pumpFoodDetails(tester, videoState(), '52959');
  expectSalmonDetails();
  expect(videoWidget(tester).videoUrl, watchUrl);
  expect(videoWidget(tester).videoUrl.contains(mealThumb), isFalse);
  expect(imageUrls(tester), contains(mealThumb));
  expect(imageUrls(tester), isNot(contains(foodThumbnailUrl('xvPR2Tfw5k0'))));
  expect(videoWidget(tester).showBackButton, isTrue);
  expect(find.byKey(const Key('app_youtube_video_play')), findsOneWidget);
  expectDetailsBackOnly(tester);
  expectTitleOnMedia(tester);
}

Future<void> showUnsupportedVideo(WidgetTester tester) async {
  await pumpFoodDetails(tester, unsupportedVideoState(), '52959');
  expect(videoWidget(tester).videoUrl, 'https://example.com/watch?v=abc');
  expectClearPlayer(tester);
  expect(imageUrls(tester), isEmpty);
  expect(videoWidget(tester).showBackButton, isTrue);
  expectDetailsBackOnly(tester);
  expectTitleOnMedia(tester);
}

Future<void> showMissingMeal(WidgetTester tester) async {
  await pumpFoodDetails(
    tester,
    const FoodDetailsState(isMealNotFound: true),
    '8',
  );
  expectMealMissing();
  expectDetailsBackOnly(tester);
}

Future<void> showEmptyMeal(WidgetTester tester) async {
  await pumpFoodDetails(tester, emptySuccessState(), '8');
  expectMealMissing();
  expectDetailsBackOnly(tester);
}

Future<void> showFailure(WidgetTester tester) async {
  await pumpFoodDetails(tester, offlineState(), '9');
  expect(find.text('offline'), findsOneWidget);
  expect(messageColor(tester, 'offline'), AppColors.white);
  expect(find.text('Baked salmon'), findsNothing);
  expectDetailsBackOnly(tester);
}

Future<void> showDispatchedMealId(WidgetTester tester) async {
  await pumpFoodDetails(tester, loadingState(), '8604');
  expectRequestedMeal('8604');
}

void expectSalmonDetails() {
  expectMealCopy();
  expectMealIngredients();
  expectNutritionUnavailable();
}

void expectMealCopy() {
  expect(find.text('Baked salmon'), findsOneWidget);
  expect(find.text('Bake until flaky.'), findsOneWidget);
  expect(find.text(LocaleKeys.food_instructions.tr()), findsNothing);
  expect(find.text(LocaleKeys.food_ingredients.tr()), findsOneWidget);
}

void expectMealIngredients() {
  expect(find.text('Salmon'), findsOneWidget);
  expect(find.text('350g'), findsOneWidget);
  expect(find.text('Fennel'), findsOneWidget);
  expect(find.text('2 medium'), findsOneWidget);
}

void expectNutritionUnavailable() {
  expect(find.text(LocaleKeys.food_nutrition_note.tr()), findsOneWidget);
  expectSampleNutritionAbsent();
}

void expectSampleNutritionAbsent() {
  expect(find.text('350 kcal'), findsNothing);
  expect(find.text('25 g'), findsNothing);
  expect(find.text('40 g'), findsNothing);
  expect(find.text('12 g'), findsNothing);
  expect(find.text(LocaleKeys.food_energy.tr()), findsNothing);
  expect(find.text(LocaleKeys.food_protein.tr()), findsNothing);
  expect(find.text(LocaleKeys.food_carbs.tr()), findsNothing);
  expect(find.text(LocaleKeys.food_fat.tr()), findsNothing);
  expect(find.text(LocaleKeys.food_sample.tr()), findsNothing);
}

void expectClearPlayer(WidgetTester tester) {
  final surface = tester.widget<ColoredBox>(
    find.byKey(const Key('app_youtube_video_unavailable')),
  );
  expect(surface.color, const Color(0x00000000));
  expect(find.byKey(const Key('app_youtube_video_play')), findsNothing);
}

Future<void> showArabicNote(WidgetTester tester) async {
  await pumpFoodDetails(
    tester,
    videoState(),
    '52959',
    locale: const Locale('ar'),
    translations: arabicTranslations(),
  );
  expect(find.text('لا تتوفر معلومات غذائية لهذه الوجبة.'), findsOneWidget);
  expect(find.text('الكربوهيدرات'), findsNothing);
  expect(find.text('عينة'), findsNothing);
  expect(tester.takeException(), isNull);
}

Future<void> popOnBack(WidgetTester tester) async {
  await pumpFoodDetailsRoute(tester, loadingState(), '52959');
  expect(find.byType(FoodDetailsBackButton), findsOneWidget);
  await tester.tap(find.byType(FoodDetailsBackButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.text('food-browse'), findsOneWidget);
  expect(find.byType(FoodDetailsBackButton), findsNothing);
}

List<String> imageUrls(WidgetTester tester) {
  return [
    for (final image in tester.widgetList<Image>(find.byType(Image)))
      if (image.image case NetworkImage(:final url)) url,
  ];
}

void expectTitleOnMedia(WidgetTester tester) {
  final video = tester.getRect(find.byType(AppYoutubeVideo));
  final title = tester.getRect(find.text('Baked salmon'));
  final player = tester.widget<AppYoutubeVideo>(find.byType(AppYoutubeVideo));
  expect(player.aspectRatio, 16 / 9);
  expect(title.top >= video.bottom - 1, isTrue);
  expectPlayClearOfTitle(tester, title);
}

void expectPlayClearOfTitle(WidgetTester tester, Rect title) {
  final play = find.byKey(const Key('app_youtube_video_play'));
  if (play.evaluate().isEmpty) return;
  expect(tester.getRect(play).overlaps(title), isFalse);
}

void expectDetailsBackOnly(WidgetTester tester) {
  expect(find.byType(FoodDetailsBackButton), findsOneWidget);
  expect(find.byTooltip(LocaleKeys.common_back.tr()), findsOneWidget);
  expect(find.byKey(const Key('app_youtube_video_back')), findsNothing);
}

void expectMealMissing() {
  expect(find.text(LocaleKeys.errors_data_not_found.tr()), findsOneWidget);
  expect(find.text('Baked salmon'), findsNothing);
  expect(find.text('Salmon'), findsNothing);
}

AppYoutubeVideo videoWidget(WidgetTester tester) {
  return tester.widget<AppYoutubeVideo>(find.byType(AppYoutubeVideo));
}

Color? progressColor(WidgetTester tester) {
  final finder = find.byType(CircularProgressIndicator);
  return tester.widget<CircularProgressIndicator>(finder).color;
}

Color? messageColor(WidgetTester tester, String message) {
  return tester.widget<Text>(find.text(message)).style?.color;
}

void expectRequestedMeal(String mealId) {
  final captured = verify(() => cubit.doIntent(captureAny())).captured;
  final intent = captured.single as LoadMealDetailsIntent;
  expect(intent.mealId, mealId);
}
