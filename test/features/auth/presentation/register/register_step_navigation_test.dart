import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/registration_validation_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  setUpAll(() => registerFallbackValue(const RegisterParameters()));

  RegisterCubit open() {
    final cubit = RegisterCubit(MockRegisterUseCase());
    addTearDown(cubit.close);
    return cubit;
  }

  test('next locks paging and emits the destination step', () async {
    final cubit = open();
    final events = await _capture(cubit, () {
      cubit.doIntent(const SelectGenderIntent('male'));
      cubit.doIntent(const NextStepIntent());
    });
    expect(cubit.state.currentStep, 1);
    expect(cubit.state.isPaging, isTrue);
    expect(cubit.state.params.age, 25);
    expect(_step(events), 1);
  });

  test('release paging enables the step without moving it', () async {
    final cubit = open();
    cubit.doIntent(const SelectGenderIntent('male'));
    cubit.doIntent(const NextStepIntent());
    cubit.doIntent(const ReleasePagingIntent());
    expect(cubit.state.isPaging, isFalse);
    expect(cubit.state.currentStep, 1);
    expect(cubit.state.params.gender, 'male');
  });

  test('release paging does nothing while the step is idle', () {
    final cubit = open();
    cubit.doIntent(const ReleasePagingIntent());
    expect(cubit.state, const RegisterState());
  });

  test('back from a later step locks paging and keeps the profile', () async {
    final cubit = open();
    cubit.doIntent(const SelectGenderIntent('male'));
    cubit.doIntent(const NextStepIntent());
    cubit.doIntent(const ReleasePagingIntent());
    final events = await _capture(cubit, () {
      cubit.doIntent(const GoBackIntent());
    });
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.isPaging, isTrue);
    expect(cubit.state.params.gender, 'male');
    expect(cubit.state.params.age, 25);
    expect(events.whereType<PopEvent>(), isEmpty);
    expect(_step(events), 0);
  });
}

Future<List<BaseUiEvent>> _capture(
  RegisterCubit cubit,
  void Function() action,
) async {
  final events = <BaseUiEvent>[];
  final subscription = cubit.eventStream.listen(events.add);
  action();
  await Future<void>.value();
  await subscription.cancel();
  return events;
}

int _step(List<BaseUiEvent> events) {
  final event = events.single as RegistrationStepChangedEvent;
  return event.step;
}
