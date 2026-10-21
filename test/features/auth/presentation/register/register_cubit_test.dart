import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
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

  setUpAll(() => registerFallbackValue(const RegisterParameters()));

  setUp(() => useCase = MockRegisterUseCase());

  RegisterCubit open() {
    final cubit = RegisterCubit(useCase);
    addTearDown(cubit.close);
    return cubit;
  }

  void next(RegisterCubit cubit) => cubit.doIntent(const NextStepIntent());

  void fillProfile(RegisterCubit cubit) {
    cubit.doIntent(const SelectGenderIntent('male'));
    next(cubit);
    next(cubit);
    next(cubit);
    cubit.doIntent(
      const SelectGoalIntent(RegistrationGoal.gainWeight, 'Gain Weight'),
    );
    next(cubit);
    cubit.doIntent(
      const SelectActivityIntent(RegistrationActivity.rookie, 'Rookie'),
    );
    next(cubit);
  }

  void expectPreserved(RegisterCubit cubit) {
    expect(cubit.state.params.firstName, isEmpty);
    expect(cubit.state.params.email, isEmpty);
    expect(cubit.state.params.password, isEmpty);
    expect(cubit.state.params.gender, 'male');
    expect(cubit.state.params.age, 40);
    expect(cubit.state.params.weight, 70.5);
    expect(cubit.state.params.height, 180);
    expect(cubit.state.selectedGoal, RegistrationGoal.gainWeight);
    expect(cubit.state.selectedActivity, RegistrationActivity.rookie);
    expect(cubit.state.params.goal, 'Gain Weight');
    expect(cubit.state.params.activityLevel, 'Rookie');
  }

  test('starts on gender with no goal, activity, or measurements', () {
    final cubit = open();
    expect(cubit.state, const RegisterState());
    expect(cubit.state.params.gender, isEmpty);
    expect(cubit.state.selectedGoal, isNull);
    expect(cubit.state.selectedActivity, isNull);
  });

  test('applies defaults only when a measurement is still unset', () {
    final cubit = open();
    cubit.doIntent(const SelectGenderIntent('male'));
    next(cubit);
    expect(cubit.state.currentStep, 1);
    expect(cubit.state.params.age, 25);
    next(cubit);
    expect(cubit.state.params.weight, 90);
    next(cubit);
    expect(cubit.state.params.height, 167);
    expect(cubit.state.currentStep, 3);
  });

  test('keeps an existing age, decimal weight, and height', () {
    final cubit = open();
    cubit.doIntent(const SelectAgeIntent(40));
    cubit.doIntent(const SelectWeightIntent(70.5));
    cubit.doIntent(const SelectHeightIntent(180));
    cubit.doIntent(const SelectGenderIntent('male'));
    next(cubit);
    next(cubit);
    next(cubit);
    expect(cubit.state.params.age, 40);
    expect(cubit.state.params.weight, 70.5);
    expect(cubit.state.params.height, 180);
    expect(FormValidators.validateWeight('70.5'), isNull);
  });

  test('accepts age bounds and rejects values outside 16 to 100', () {
    final cubit = open();
    cubit.doIntent(const SelectAgeIntent(15));
    expect(cubit.state.params.age, 0);
    cubit.doIntent(const SelectAgeIntent(16));
    expect(cubit.state.params.age, 16);
    cubit.doIntent(const SelectAgeIntent(100));
    expect(cubit.state.params.age, 100);
    cubit.doIntent(const SelectAgeIntent(101));
    expect(cubit.state.params.age, 100);
  });

  test('accepts weight bounds and keeps validator decimals', () {
    final cubit = open();
    cubit.doIntent(const SelectWeightIntent(19.9));
    expect(cubit.state.params.weight, 0);
    cubit.doIntent(const SelectWeightIntent(20));
    expect(cubit.state.params.weight, 20);
    cubit.doIntent(const SelectWeightIntent(350));
    expect(cubit.state.params.weight, 350);
    cubit.doIntent(const SelectWeightIntent(350.1));
    expect(cubit.state.params.weight, 350);
    cubit.doIntent(const SelectWeightIntent(70.5));
    expect(cubit.state.params.weight, 70.5);
    expect(FormValidators.validateWeight('70.5'), isNull);
  });

  test('accepts height bounds and rejects values outside 100 to 250', () {
    final cubit = open();
    cubit.doIntent(const SelectHeightIntent(99));
    expect(cubit.state.params.height, 0);
    cubit.doIntent(const SelectHeightIntent(100));
    expect(cubit.state.params.height, 100);
    cubit.doIntent(const SelectHeightIntent(250));
    expect(cubit.state.params.height, 250);
    cubit.doIntent(const SelectHeightIntent(251));
    expect(cubit.state.params.height, 250);
  });

  test('stores male or female and replaces the previous gender', () {
    final cubit = open();
    cubit.doIntent(const SelectGenderIntent('other'));
    expect(cubit.state.params.gender, isEmpty);
    cubit.doIntent(const SelectGenderIntent('Male'));
    expect(cubit.state.params.gender, 'male');
    cubit.doIntent(const SelectGenderIntent('Female'));
    expect(cubit.state.params.gender, 'female');
  });

  test('stores each displayed goal and activity text', () {
    final cubit = open();
    const goals = {
      RegistrationGoal.gainWeight: 'Gain Weight',
      RegistrationGoal.loseWeight: 'Lose Weight',
      RegistrationGoal.getFitter: 'Get Fitter',
      RegistrationGoal.gainMoreFlexible: 'Gain More Flexible',
      RegistrationGoal.learnTheBasic: 'Learn The Basic',
    };
    const activities = {
      RegistrationActivity.rookie: 'Rookie',
      RegistrationActivity.beginner: 'Beginner',
      RegistrationActivity.intermediate: 'Intermediate',
      RegistrationActivity.advance: 'Advance',
      RegistrationActivity.trueBeast: 'True Beast',
    };
    for (final entry in goals.entries) {
      cubit.doIntent(SelectGoalIntent(entry.key, entry.value));
      expect(cubit.state.params.goal, entry.value);
    }
    for (final entry in activities.entries) {
      cubit.doIntent(SelectActivityIntent(entry.key, entry.value));
      expect(cubit.state.params.activityLevel, entry.value);
    }
  });

  test('blocks next on an invalid step and stops on the last step', () {
    final cubit = open();
    next(cubit);
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.params.age, 0);
    cubit.doIntent(const SelectGenderIntent('female'));
    next(cubit);
    next(cubit);
    next(cubit);
    expect(cubit.state.currentStep, 3);
    next(cubit);
    next(cubit);
    expect(cubit.state.currentStep, 4);
    cubit.doIntent(
      const SelectGoalIntent(RegistrationGoal.learnTheBasic, 'Learn The Basic'),
    );
    cubit.doIntent(
      const SelectActivityIntent(RegistrationActivity.trueBeast, 'True Beast'),
    );
    next(cubit);
    next(cubit);
    expect(cubit.state.currentStep, 5);
  });

  test('back from the first step emits PopEvent and keeps the step', () async {
    final cubit = open();
    final events = <BaseUiEvent>[];
    final subscription = cubit.eventStream.listen(events.add);
    addTearDown(subscription.cancel);
    cubit.doIntent(const GoBackIntent());
    await Future<void>.value();
    expect(events.single, isA<PopEvent>());
    expect(cubit.state.currentStep, 0);
  });

  test('back and next preserve every selection', () {
    final cubit = open();
    cubit.doIntent(const SelectAgeIntent(40));
    cubit.doIntent(const SelectWeightIntent(70.5));
    cubit.doIntent(const SelectHeightIntent(180));
    fillProfile(cubit);
    expect(cubit.state.currentStep, 5);
    while (cubit.state.currentStep > 0) {
      cubit.doIntent(const GoBackIntent());
    }
    expectPreserved(cubit);
    fillProfile(cubit);
    expect(cubit.state.currentStep, 5);
  });

  test('submit stays blocked without account credentials', () {
    final cubit = open();
    cubit.doIntent(const SubmitRegistrationIntent());
    fillProfile(cubit);
    cubit.doIntent(const SubmitRegistrationIntent());
    expect(cubit.state.registerResource.isInitial, isTrue);
    verifyNever(() => useCase.call(any()));
  });

  blocTest<RegisterCubit, RegisterState>(
    'submit does nothing while a submission is already active',
    build: () => RegisterCubit(useCase),
    seed: () => const RegisterState(registerResource: Resource.loading()),
    act: (cubit) => cubit.doIntent(const SubmitRegistrationIntent()),
    expect: () => const <RegisterState>[],
    verify: (_) => verifyNever(() => useCase.call(any())),
  );

  blocTest<RegisterCubit, RegisterState>(
    'submit does nothing after registration already succeeded',
    build: () => RegisterCubit(useCase),
    seed: () =>
        const RegisterState(registerResource: Resource.success(UserEntity())),
    act: (cubit) => cubit.doIntent(const SubmitRegistrationIntent()),
    expect: () => const <RegisterState>[],
    verify: (_) => verifyNever(() => useCase.call(any())),
  );

  test('password visibility still toggles', () {
    final cubit = open();
    cubit.doIntent(const TogglePasswordVisibilityIntent());
    expect(cubit.state.isPasswordObscured, isFalse);
    cubit.doIntent(const TogglePasswordVisibilityIntent());
    expect(cubit.state.isPasswordObscured, isTrue);
    verifyNever(() => useCase.call(any()));
  });
}
