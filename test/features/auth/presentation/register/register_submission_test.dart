import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase useCase;

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
