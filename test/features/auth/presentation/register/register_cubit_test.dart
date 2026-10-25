import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/registration_validation_event.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

late MockRegisterUseCase useCase;

const _goals = {
  RegistrationGoal.gainWeight: 'Gain Weight',
  RegistrationGoal.loseWeight: 'Lose Weight',
  RegistrationGoal.getFitter: 'Get Fitter',
  RegistrationGoal.gainMoreFlexible: 'Gain More Flexible',
  RegistrationGoal.learnTheBasic: 'Learn The Basic',
};

const _activities = {
  RegistrationActivity.rookie: 'Rookie',
  RegistrationActivity.beginner: 'Beginner',
  RegistrationActivity.intermediate: 'Intermediate',
  RegistrationActivity.advance: 'Advance',
  RegistrationActivity.trueBeast: 'True Beast',
};

void main() {
  setUpAll(() => registerFallbackValue(const RegisterParameters()));
  setUp(() => useCase = MockRegisterUseCase());
  registerCubitTests();
}

void registerCubitTests() {
  startsOnGender();
  appliesUnsetDefaults();
  keepsExistingMeasurements();
  acceptsAgeBounds();
  acceptsWeightBounds();
  acceptsHeightBounds();
  storesGender();
  storesGoalAndActivity();
  blocksInvalidNext();
  backFromFirstStep();
  preservesSelections();
  submitStaysBlocked();
  ignoresActiveSubmission();
  ignoresSuccessfulSubmission();
  togglesPasswordVisibility();
}

RegisterCubit openCubit() {
  final cubit = RegisterCubit(useCase);
  addTearDown(cubit.close);
  return cubit;
}

void nextStep(RegisterCubit cubit) => cubit.doIntent(const NextStepIntent());

void startsOnGender() {
  test('starts on gender with no goal, activity, or measurements', () {
    final cubit = openCubit();
    expect(cubit.state, const RegisterState());
    expect(cubit.state.params.gender, isEmpty);
    expect(cubit.state.selectedGoal, isNull);
    expect(cubit.state.selectedActivity, isNull);
  });
}

void appliesUnsetDefaults() {
  test('applies defaults only when a measurement is still unset', () {
    final cubit = openCubit();
    cubit.doIntent(const SelectGenderIntent('male'));
    nextStep(cubit);
    expect(cubit.state.currentStep, 1);
    expect(cubit.state.params.age, 25);
    nextStep(cubit);
    expect(cubit.state.params.weight, 90);
    nextStep(cubit);
    expect(cubit.state.params.height, 167);
    expect(cubit.state.currentStep, 3);
  });
}

void keepsExistingMeasurements() {
  test('keeps an existing age, decimal weight, and height', () {
    final cubit = openCubit();
    _selectExistingMeasurements(cubit);
    nextStep(cubit);
    nextStep(cubit);
    nextStep(cubit);
    expect(cubit.state.params.age, 40);
    expect(cubit.state.params.weight, 70.5);
    expect(cubit.state.params.height, 180);
    expect(FormValidators.validateWeight('70.5'), isNull);
  });
}

void _selectExistingMeasurements(RegisterCubit cubit) {
  cubit.doIntent(const SelectAgeIntent(40));
  cubit.doIntent(const SelectWeightIntent(70.5));
  cubit.doIntent(const SelectHeightIntent(180));
  cubit.doIntent(const SelectGenderIntent('male'));
}

void acceptsAgeBounds() {
  test('accepts age bounds and reports values outside 16 to 100', () async {
    final cubit = openCubit();
    await _expectRejectedAge(cubit, 15, ValidationError.valueBelowMinimum, 0);
    _acceptAge(cubit, 16);
    _acceptAge(cubit, 100);
    await _expectRejectedAge(
      cubit,
      101,
      ValidationError.valueAboveMaximum,
      100,
    );
  });
}

void _acceptAge(RegisterCubit cubit, int age) {
  cubit.doIntent(SelectAgeIntent(age));
  expect(cubit.state.params.age, age);
}

void acceptsWeightBounds() {
  test('accepts weight bounds and reports values outside 20 to 350', () async {
    final cubit = openCubit();
    await _rejectWeight(cubit, 19.9, ValidationError.valueBelowMinimum, 0);
    _acceptWeight(cubit, 20);
    _acceptWeight(cubit, 350);
    await _rejectWeight(cubit, 350.1, ValidationError.valueAboveMaximum, 350);
    _acceptWeight(cubit, 70.5);
    expect(FormValidators.validateWeight('70.5'), isNull);
  });
}

void _acceptWeight(RegisterCubit cubit, num weight) {
  cubit.doIntent(SelectWeightIntent(weight));
  expect(cubit.state.params.weight, weight);
}

Future<void> _rejectWeight(
  RegisterCubit cubit,
  num weight,
  ValidationError error,
  num kept,
) {
  return _expectRejectedWeight(cubit, weight, error, kept);
}

void acceptsHeightBounds() {
  test('accepts height bounds and rejects values outside 100 to 250', () {
    final cubit = openCubit();
    _rejectHeight(cubit, 99, 0);
    _acceptHeight(cubit, 100);
    _acceptHeight(cubit, 250);
    _rejectHeight(cubit, 251, 250);
  });
}

void _acceptHeight(RegisterCubit cubit, num height) {
  cubit.doIntent(SelectHeightIntent(height));
  expect(cubit.state.params.height, height);
}

void _rejectHeight(RegisterCubit cubit, num height, num kept) {
  cubit.doIntent(SelectHeightIntent(height));
  expect(cubit.state.params.height, kept);
}

void storesGender() {
  test('stores male or female and replaces the previous gender', () {
    final cubit = openCubit();
    cubit.doIntent(const SelectGenderIntent('other'));
    expect(cubit.state.params.gender, isEmpty);
    cubit.doIntent(const SelectGenderIntent('Male'));
    expect(cubit.state.params.gender, 'male');
    cubit.doIntent(const SelectGenderIntent('Female'));
    expect(cubit.state.params.gender, 'female');
  });
}

void storesGoalAndActivity() {
  test('stores each displayed goal and activity text', () {
    final cubit = openCubit();
    _storeGoals(cubit);
    _storeActivities(cubit);
  });
}

void _storeGoals(RegisterCubit cubit) {
  for (final entry in _goals.entries) {
    cubit.doIntent(SelectGoalIntent(entry.key, entry.value));
    expect(cubit.state.params.goal, entry.value);
  }
}

void _storeActivities(RegisterCubit cubit) {
  for (final entry in _activities.entries) {
    cubit.doIntent(SelectActivityIntent(entry.key, entry.value));
    expect(cubit.state.params.activityLevel, entry.value);
  }
}

void blocksInvalidNext() {
  test('blocks next on an invalid step and stops on the last step', () {
    final cubit = openCubit();
    _stopBeforeMeasurements(cubit);
    _reachGoalStep(cubit);
    _finishLastStep(cubit);
  });
}

void _stopBeforeMeasurements(RegisterCubit cubit) {
  nextStep(cubit);
  expect(cubit.state.currentStep, 0);
  expect(cubit.state.params.age, 0);
}

void _reachGoalStep(RegisterCubit cubit) {
  cubit.doIntent(const SelectGenderIntent('female'));
  nextStep(cubit);
  nextStep(cubit);
  nextStep(cubit);
  expect(cubit.state.currentStep, 3);
  nextStep(cubit);
  nextStep(cubit);
  expect(cubit.state.currentStep, 4);
}

void _finishLastStep(RegisterCubit cubit) {
  cubit.doIntent(
    const SelectGoalIntent(RegistrationGoal.learnTheBasic, 'Learn The Basic'),
  );
  cubit.doIntent(
    const SelectActivityIntent(RegistrationActivity.trueBeast, 'True Beast'),
  );
  nextStep(cubit);
  nextStep(cubit);
  expect(cubit.state.currentStep, 5);
}

void backFromFirstStep() {
  test('back from the first step emits PopEvent and keeps the step', () async {
    final cubit = openCubit();
    final events = <BaseUiEvent>[];
    final subscription = cubit.eventStream.listen(events.add);
    addTearDown(subscription.cancel);
    cubit.doIntent(const GoBackIntent());
    await Future<void>.value();
    expect(events.single, isA<PopEvent>());
    expect(cubit.state.currentStep, 0);
  });
}

void preservesSelections() {
  test('back and next preserve every selection', () {
    final cubit = openCubit();
    cubit.doIntent(const SelectAgeIntent(40));
    cubit.doIntent(const SelectWeightIntent(70.5));
    cubit.doIntent(const SelectHeightIntent(180));
    fillProfile(cubit);
    expect(cubit.state.currentStep, 5);
    _walkBackToStart(cubit);
    expectPreserved(cubit);
    fillProfile(cubit);
    expect(cubit.state.currentStep, 5);
  });
}

void _walkBackToStart(RegisterCubit cubit) {
  while (cubit.state.currentStep > 0) {
    cubit.doIntent(const GoBackIntent());
  }
}

void submitStaysBlocked() {
  test('submit stays blocked without account credentials', () {
    final cubit = openCubit();
    cubit.doIntent(const SubmitRegistrationIntent());
    fillProfile(cubit);
    cubit.doIntent(const SubmitRegistrationIntent());
    expect(cubit.state.registerResource.isInitial, isTrue);
    verifyNever(() => useCase.call(any()));
  });
}

void ignoresActiveSubmission() {
  blocTest<RegisterCubit, RegisterState>(
    'submit does nothing while a submission is already active',
    build: () => RegisterCubit(useCase),
    seed: () => const RegisterState(registerResource: Resource.loading()),
    act: (cubit) => cubit.doIntent(const SubmitRegistrationIntent()),
    expect: () => const <RegisterState>[],
    verify: (_) => verifyNever(() => useCase.call(any())),
  );
}

void ignoresSuccessfulSubmission() {
  blocTest<RegisterCubit, RegisterState>(
    'submit does nothing after registration already succeeded',
    build: () => RegisterCubit(useCase),
    seed: () =>
        const RegisterState(registerResource: Resource.success(UserEntity())),
    act: (cubit) => cubit.doIntent(const SubmitRegistrationIntent()),
    expect: () => const <RegisterState>[],
    verify: (_) => verifyNever(() => useCase.call(any())),
  );
}

void togglesPasswordVisibility() {
  test('password visibility still toggles', () {
    final cubit = openCubit();
    cubit.doIntent(const TogglePasswordVisibilityIntent());
    expect(cubit.state.isPasswordObscured, isFalse);
    cubit.doIntent(const TogglePasswordVisibilityIntent());
    expect(cubit.state.isPasswordObscured, isTrue);
    verifyNever(() => useCase.call(any()));
  });
}

void fillProfile(RegisterCubit cubit) {
  cubit.doIntent(const SelectGenderIntent('male'));
  nextStep(cubit);
  nextStep(cubit);
  nextStep(cubit);
  cubit.doIntent(
    const SelectGoalIntent(RegistrationGoal.gainWeight, 'Gain Weight'),
  );
  nextStep(cubit);
  cubit.doIntent(
    const SelectActivityIntent(RegistrationActivity.rookie, 'Rookie'),
  );
  nextStep(cubit);
}

void expectPreserved(RegisterCubit cubit) {
  expect(cubit.state.params.firstName, isEmpty);
  expect(cubit.state.params.email, isEmpty);
  expect(cubit.state.params.password, isEmpty);
  expect(cubit.state.params.gender, 'male');
  expect(cubit.state.params.age, 40);
  expect(cubit.state.params.weight, 70.5);
  expect(cubit.state.params.height, 180);
  _expectGoalAndActivity(cubit);
}

void _expectGoalAndActivity(RegisterCubit cubit) {
  expect(cubit.state.selectedGoal, RegistrationGoal.gainWeight);
  expect(cubit.state.selectedActivity, RegistrationActivity.rookie);
  expect(cubit.state.params.goal, 'Gain Weight');
  expect(cubit.state.params.activityLevel, 'Rookie');
}

Future<void> _expectRejectedAge(
  RegisterCubit cubit,
  int age,
  ValidationError error,
  int kept,
) async {
  final events = <BaseUiEvent>[];
  final subscription = cubit.eventStream.listen(events.add);
  cubit.doIntent(SelectAgeIntent(age));
  await Future<void>.value();
  await subscription.cancel();
  expect(cubit.state.params.age, kept);
  final event = events.single as RegistrationValidationEvent;
  expect(event.error, error);
}

Future<void> _expectRejectedWeight(
  RegisterCubit cubit,
  num weight,
  ValidationError error,
  num kept,
) async {
  final events = <BaseUiEvent>[];
  final subscription = cubit.eventStream.listen(events.add);
  cubit.doIntent(SelectWeightIntent(weight));
  await Future<void>.value();
  await subscription.cancel();
  expect(cubit.state.params.weight, kept);
  final event = events.single as RegistrationValidationEvent;
  expect(event.error, error);
}
