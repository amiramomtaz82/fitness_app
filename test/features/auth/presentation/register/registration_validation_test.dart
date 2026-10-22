import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/registration_validation_event.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase useCase;
  late List<BaseUiEvent> events;

  setUpAll(() => registerFallbackValue(const RegisterParameters()));

  setUp(() {
    useCase = MockRegisterUseCase();
    events = [];
  });

  RegisterCubit open() {
    final cubit = RegisterCubit(useCase);
    addTearDown(cubit.close);
    return cubit;
  }

  RegisterCubit listen() {
    final cubit = RegisterCubit(useCase);
    cubit.eventStream.listen(events.add);
    return cubit;
  }

  void blocks(String name, RegisterState seed, ValidationError error) {
    blocTest<RegisterCubit, RegisterState>(
      name,
      build: listen,
      seed: () => seed,
      act: (cubit) => cubit.doIntent(const NextStepIntent()),
      expect: () => const <RegisterState>[],
      verify: (cubit) => _expectBlock(cubit, events, seed, error, useCase),
    );
  }

  test('next without gender stays on the step', () async {
    final cubit = open();
    await _expectNextBlocked(cubit, ValidationError.empty);
    expect(cubit.state.currentStep, 0);
    verifyNever(() => useCase.call(any()));
  });

  test('next without a goal or activity stays on that step', () async {
    final cubit = open();
    _reachGoal(cubit);
    await _expectNextBlocked(cubit, ValidationError.empty);
    expect(cubit.state.currentStep, 4);
    _selectGoal(cubit);
    await _expectNextBlocked(cubit, ValidationError.empty);
    expect(cubit.state.currentStep, 5);
    verifyNever(() => useCase.call(any()));
  });

  test('next on the last step does not emit an event', () async {
    final cubit = open();
    _reachGoal(cubit);
    _selectGoal(cubit);
    _selectActivity(cubit);
    final seen = <BaseUiEvent>[];
    final subscription = cubit.eventStream.listen(seen.add);
    cubit.doIntent(const NextStepIntent());
    await Future<void>.value();
    await subscription.cancel();
    expect(seen, isEmpty);
    expect(cubit.state.currentStep, 5);
    verifyNever(() => useCase.call(any()));
  });

  blocks(
    'invalid gender stays on the step',
    const RegisterState(params: RegisterParameters(gender: 'other')),
    ValidationError.invalidGender,
  );
  blocks(
    'age below the minimum stays on the step',
    const RegisterState(
      currentStep: 1,
      params: RegisterParameters(gender: 'male', age: 10),
    ),
    ValidationError.valueBelowMinimum,
  );
  blocks(
    'unset weight stays on the step',
    const RegisterState(
      currentStep: 2,
      params: RegisterParameters(gender: 'male', age: 25),
    ),
    ValidationError.empty,
  );
  blocks(
    'weight below the minimum stays on the step',
    const RegisterState(
      currentStep: 2,
      params: RegisterParameters(gender: 'male', age: 25, weight: 10),
    ),
    ValidationError.valueBelowMinimum,
  );
  blocks(
    'weight above the maximum stays on the step',
    const RegisterState(
      currentStep: 2,
      params: RegisterParameters(gender: 'male', age: 25, weight: 400),
    ),
    ValidationError.valueAboveMaximum,
  );
  blocks(
    'height above the maximum stays on the step',
    const RegisterState(
      currentStep: 3,
      params: RegisterParameters(
        gender: 'male',
        age: 25,
        weight: 90,
        height: 260,
      ),
    ),
    ValidationError.valueAboveMaximum,
  );
}

void _expectBlock(
  RegisterCubit cubit,
  List<BaseUiEvent> events,
  RegisterState seed,
  ValidationError error,
  MockRegisterUseCase useCase,
) {
  final event = events.single as RegistrationValidationEvent;
  expect(event.error, error);
  expect(cubit.state.currentStep, seed.currentStep);
  verifyNever(() => useCase.call(any()));
}

Future<void> _expectNextBlocked(
  RegisterCubit cubit,
  ValidationError error,
) async {
  final seen = <BaseUiEvent>[];
  final subscription = cubit.eventStream.listen(seen.add);
  cubit.doIntent(const NextStepIntent());
  await Future<void>.value();
  await subscription.cancel();
  final event = seen.single as RegistrationValidationEvent;
  expect(event.error, error);
}

void _reachGoal(RegisterCubit cubit) {
  cubit.doIntent(const SelectGenderIntent('female'));
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(const NextStepIntent());
}

void _selectGoal(RegisterCubit cubit) {
  cubit.doIntent(
    const SelectGoalIntent(RegistrationGoal.loseWeight, 'Lose Weight'),
  );
  cubit.doIntent(const NextStepIntent());
}

void _selectActivity(RegisterCubit cubit) {
  cubit.doIntent(
    const SelectActivityIntent(RegistrationActivity.beginner, 'Beginner'),
  );
}
