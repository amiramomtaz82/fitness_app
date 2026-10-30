import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/food/domain/entities/meal_details_entity.dart';
import 'package:fitness_app/features/food/domain/use_cases/get_meal_details_use_case.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_cubit.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_intent.dart';
import 'package:fitness_app/features/food/presentation/food_details/view_model/food_details_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMealDetailsUseCase extends Mock implements GetMealDetailsUseCase {}

const salmon = MealDetailsEntity(id: '52959', name: 'Baked salmon');

const missingMeal = SuccessResponse<MealDetailsEntity?>(null);

const offline = NetworkFailure(serverMessage: 'offline');

late MockGetMealDetailsUseCase useCase;
late FoodDetailsCubit cubit;

void main() {
  setUp(createFoodDetailsCubit);
  tearDown(closeFoodDetailsCubit);
  registerFoodDetailsCubitTests();
}

void registerFoodDetailsCubitTests() {
  loadsTheRequestedMeal();
  marksANullMealAsNotFound();
  keepsTheUseCaseFailure();
  test('publishes the failure on the event stream', publishesTheFailure);
}

void createFoodDetailsCubit() {
  useCase = MockGetMealDetailsUseCase();
  cubit = FoodDetailsCubit(useCase);
}

Future<void> closeFoodDetailsCubit() {
  return cubit.close();
}

void loadsTheRequestedMeal() {
  blocTest<FoodDetailsCubit, FoodDetailsState>(
    'loads the requested meal',
    build: () => cubit,
    setUp: stubSalmonMeal,
    act: requestSalmon,
    expect: salmonMealStates,
    verify: verifyLoadedSalmon,
  );
}

void stubSalmonMeal() {
  when(
    () => useCase.call('52959'),
  ).thenAnswer((invocation) async => const SuccessResponse(salmon));
}

void requestSalmon(FoodDetailsCubit current) {
  current.doIntent(const LoadMealDetailsIntent('52959'));
}

List<FoodDetailsState> salmonMealStates() {
  return const [
    FoodDetailsState(mealResource: Resource.loading()),
    FoodDetailsState(mealResource: Resource.success(salmon)),
  ];
}

void verifyLoadedSalmon(FoodDetailsCubit current) {
  verify(() => useCase.call('52959')).called(1);
  expect(current.state.mealResource.isSuccess, isTrue);
  expect(current.state.isMealNotFound, isFalse);
}

void marksANullMealAsNotFound() {
  blocTest<FoodDetailsCubit, FoodDetailsState>(
    'marks a null meal as not found',
    build: () => cubit,
    setUp: stubMissingMeal,
    act: requestMissingMeal,
    expect: missingMealStates,
    verify: verifyMissingMeal,
  );
}

void stubMissingMeal() {
  when(() => useCase.call('8')).thenAnswer((invocation) async => missingMeal);
}

void requestMissingMeal(FoodDetailsCubit current) {
  current.doIntent(const LoadMealDetailsIntent('8'));
}

List<FoodDetailsState> missingMealStates() {
  return const [
    FoodDetailsState(mealResource: Resource.loading()),
    FoodDetailsState(isMealNotFound: true),
  ];
}

void verifyMissingMeal(FoodDetailsCubit current) {
  verify(() => useCase.call('8')).called(1);
  expect(current.state.mealResource.isSuccess, isFalse);
  expect(current.state.mealResource.isError, isFalse);
  expect(current.state.mealResource.data, isNull);
}

void keepsTheUseCaseFailure() {
  blocTest<FoodDetailsCubit, FoodDetailsState>(
    'keeps the use case failure',
    build: () => cubit,
    setUp: stubOfflineMeal,
    act: requestOfflineMeal,
    expect: offlineMealStates,
    verify: verifyOfflineMeal,
  );
}

void stubOfflineMeal() {
  when(() => useCase.call('9')).thenAnswer(
    (invocation) async => ErrorResponse<MealDetailsEntity?>(failure: offline),
  );
}

void requestOfflineMeal(FoodDetailsCubit current) {
  current.doIntent(const LoadMealDetailsIntent('9'));
}

List<FoodDetailsState> offlineMealStates() {
  return const [
    FoodDetailsState(mealResource: Resource.loading()),
    FoodDetailsState(
      mealResource: Resource.error(offline),
      isMealNotFound: false,
    ),
  ];
}

void verifyOfflineMeal(FoodDetailsCubit current) {
  expect(current.state.mealResource.failure, offline);
  expect(current.state.mealResource.isSuccess, isFalse);
  expect(current.state.isMealNotFound, isFalse);
}

Future<void> publishesTheFailure() async {
  stubOfflineMeal();
  final events = <BaseUiEvent>[];
  final subscription = cubit.eventStream.listen(events.add);
  final published = expectLater(cubit.eventStream, emits(offlineFailure()));
  await cubit.loadMealDetails('9');
  await published;
  expectPublishedFailure(events);
  await subscription.cancel();
}

Matcher offlineFailure() {
  return isA<ShowErrorSnackBarEvent>().having(
    (event) => event.failure,
    'failure',
    offline,
  );
}

void expectPublishedFailure(List<BaseUiEvent> events) {
  expect(events, hasLength(1));
  expect(events.single, isA<ShowErrorSnackBarEvent>());
  expect((events.single as ShowErrorSnackBarEvent).failure, offline);
}
