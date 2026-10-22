import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase useCase;
  late List<BaseUiEvent> events;

  setUpAll(() => registerFallbackValue(const RegisterParameters()));

  setUp(() => useCase = MockRegisterUseCase());

  test('filled steps do not call register', () {
    final cubit = RegisterCubit(useCase);
    addTearDown(cubit.close);
    _fillProfile(cubit);

    cubit.doIntent(const SubmitRegistrationIntent());

    expect(cubit.state.registerResource.isInitial, isTrue);
    expect(cubit.state.params.firstName, isEmpty);
    expect(cubit.state.params.lastName, isEmpty);
    expect(cubit.state.params.email, isEmpty);
    expect(cubit.state.params.password, isEmpty);
    expect(cubit.state.params.goal, 'Lose Weight');
    expect(cubit.state.params.activityLevel, 'Intermediate');
    verifyNever(() => useCase.call(any()));
  });

  blocTest<RegisterCubit, RegisterState>(
    'a thrown registration error is stored instead of escaping',
    setUp: () {
      events = [];
      when(() => useCase.call(any())).thenAnswer((_) async {
        throw Exception('offline');
      });
    },
    build: () {
      final cubit = RegisterCubit(useCase);
      cubit.eventStream.listen(events.add);
      return cubit;
    },
    seed: _readyToSubmit,
    act: (cubit) => cubit.doIntent(const SubmitRegistrationIntent()),
    wait: Duration.zero,
    expect: () => [
      isA<RegisterState>().having(
        (state) => state.registerResource.isLoading,
        'loading',
        isTrue,
      ),
      isA<RegisterState>().having(
        (state) => state.registerResource.errorMessage,
        'error',
        'Exception: offline',
      ),
    ],
    verify: (_) {
      final event = events.single as ShowSnackBarEvent;
      expect(event.isError, isTrue);
      expect(event.message, 'Exception: offline');
    },
  );
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
      password: 'Secret1',
      gender: 'female',
      age: 40,
      weight: 70.5,
      height: 180,
      goal: 'Lose Weight',
      activityLevel: 'Intermediate',
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
