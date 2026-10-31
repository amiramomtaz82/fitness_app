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
  expect(current.state.mealResource.data, salmon);
}

void marksANullMealAsNotFound() {
  blocTest<FoodDetailsCubit, FoodDetailsState>(
    'keeps an empty success when the meal is missing',
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
    FoodDetailsState(mealResource: Resource.success(null)),
  ];
}

void verifyMissingMeal(FoodDetailsCubit current) {
  verify(() => useCase.call('8')).called(1);
  expect(current.state.mealResource.isSuccess, isTrue);
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
    FoodDetailsState(mealResource: Resource.error(offline)),
  ];
}

void verifyOfflineMeal(FoodDetailsCubit current) {
  expect(current.state.mealResource.failure, offline);
  expect(current.state.mealResource.isSuccess, isFalse);
  expect(current.state.mealResource.data, isNull);
}

Future<void> publishesTheFailure() async {
  stubOfflineMeal();
  final firstEvent = cubit.eventStream.first;
  cubit.doIntent(const LoadMealDetailsIntent('9'));
  final event = await firstEvent;
  expect(event, offlineFailure());
  expect(event, isA<ShowErrorSnackBarEvent>());
  expect((event as ShowErrorSnackBarEvent).failure, offline);
}

Matcher offlineFailure() {
  return isA<ShowErrorSnackBarEvent>().having(
    (event) => event.failure,
    'failure',
    offline,
  );
}
