import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'register_test_helper.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

late MockRegisterUseCase useCase;
late List<BaseUiEvent> events;

void main() {
  setUpAll(() => registerFallbackValue(const RegisterParameters()));
  setUp(() => useCase = MockRegisterUseCase());
  filledStepsDoNotRegister();
  repositoryFailureIsStored();
  thrownRegistrationErrorEscapes();
}

void filledStepsDoNotRegister() {
  test('filled steps do not call register', () {
    final cubit = createTestRegisterCubit(registerUseCase: useCase);
    addTearDown(cubit.close);
    _fillProfile(cubit);
    cubit.doIntent(const SubmitRegistrationIntent());
    _expectUnsubmittedProfile(cubit);
    verifyNever(() => useCase.call(any()));
  });
}

void _expectUnsubmittedProfile(RegisterCubit cubit) {
  expect(cubit.state.registerResource.isInitial, isTrue);
  expect(cubit.state.params.firstName, isEmpty);
  expect(cubit.state.params.lastName, isEmpty);
  expect(cubit.state.params.email, isEmpty);
  expect(cubit.state.params.password, isEmpty);
  expect(cubit.state.params.goal, 'Lose Weight');
  expect(cubit.state.params.activityLevel, 'Intermediate');
}

void repositoryFailureIsStored() {
  blocTest<RegisterCubit, RegisterState>(
    'a repository failure is stored',
    setUp: _returnRepositoryFailure,
    build: _listenToRegistration,
    seed: _readyToSubmit,
    act: (cubit) => cubit.doIntent(const SubmitRegistrationIntent()),
    wait: Duration.zero,
    expect: _repositoryFailureStates,
    verify: (_) => _expectFailureSnackBar(),
  );
}

void thrownRegistrationErrorEscapes() {
  test('a thrown registration error escapes', () async {
    _throwOffline();
    final cubit = createTestRegisterCubit(registerUseCase: useCase);
    addTearDown(cubit.close);
    cubit.emit(_readyToSubmit());
    final error = await _captureSubmitError(cubit);
    _expectEscaped(cubit, error);
  });
}

void _returnRepositoryFailure() {
  events = [];
  when(() => useCase.call(any())).thenAnswer((_) async {
    return ErrorResponse<UserEntity>(
      failure: const UnknownFailure(serverMessage: 'offline'),
    );
  });
}

void _throwOffline() {
  when(() => useCase.call(any())).thenAnswer((_) async {
    throw Exception('offline');
  });
}

RegisterCubit _listenToRegistration() {
  final cubit = createTestRegisterCubit(registerUseCase: useCase);
  cubit.eventStream.listen(events.add);
  return cubit;
}

List<Matcher> _repositoryFailureStates() {
  return [_loadingRegistration(), _offlineRegistration()];
}

Matcher _loadingRegistration() {
  return isA<RegisterState>().having(
    (state) => state.registerResource.isLoading,
    'loading',
    isTrue,
  );
}

Matcher _offlineRegistration() {
  return isA<RegisterState>().having(
    (state) => state.registerResource.failure?.serverMessage,
    'failure',
    'offline',
  );
}

void _expectFailureSnackBar() {
  final event = events.single as ShowErrorSnackBarEvent;
  expect(event.failure, isA<UnknownFailure>());
  expect(event.failure.serverMessage, 'offline');
}

Future<Object> _captureSubmitError(RegisterCubit cubit) {
  final captured = Completer<Object>();
  runZonedGuarded(
    () {
      cubit.doIntent(const SubmitRegistrationIntent());
    },
    (error, _) {
      if (!captured.isCompleted) captured.complete(error);
    },
  );
  return captured.future;
}

void _expectEscaped(RegisterCubit cubit, Object error) {
  expect(error, isA<Exception>());
  expect(error.toString(), 'Exception: offline');
  expect(cubit.state.registerResource.isLoading, isTrue);
  expect(cubit.state.registerResource.failure, isNull);
}

RegisterState _readyToSubmit() {
  return const RegisterState(
    currentStep: 5,
    selectedGoal: RegistrationGoal.loseWeight,
    selectedActivity: RegistrationActivity.intermediate,
    params: RegisterParameters(
      firstName: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
      password: 'Secret1@#',
      gender: 'female',
      age: 40,
      weight: 70.5,
      height: 180,
      goal: 'Lose weight',
      activityLevel: 'level3',
    ),
  );
}

void _fillProfile(RegisterCubit cubit) {
  _selectBody(cubit);
  cubit.doIntent(
    const SelectGoalIntent(RegistrationGoal.loseWeight, 'Lose Weight'),
  );
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(
    const SelectActivityIntent(
      RegistrationActivity.intermediate,
      'Intermediate',
    ),
  );
}

void _selectBody(RegisterCubit cubit) {
  cubit.doIntent(const SelectGenderIntent('female'));
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(const SelectAgeIntent(40));
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(const SelectWeightIntent(70.5));
  cubit.doIntent(const NextStepIntent());
  cubit.doIntent(const SelectHeightIntent(180));
  cubit.doIntent(const NextStepIntent());
}
