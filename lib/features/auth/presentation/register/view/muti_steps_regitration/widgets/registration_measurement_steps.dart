import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../generated/locale_keys.g.dart';
import '../../../manager/cubit/register_cubit.dart';
import '../../../manager/cubit/register_intent.dart';
import '../../../registration_measurement_rules.dart';
import 'registration_value_wheel.dart';

class RegistrationAgeStep extends StatelessWidget {
  const RegistrationAgeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final age = context.select<RegisterCubit, int>(
      (cubit) => cubit.state.params.age,
    );
    return _IntegerWheel(
      minimum: RegistrationMeasurementRules.minimumAge,
      maximum: RegistrationMeasurementRules.maximumAge,
      current: RegistrationMeasurementRules.isValidAge(age)
          ? age
          : RegistrationMeasurementRules.defaultAge,
      unit: LocaleKeys.profile_setup_year.tr(),
      onChanged: (value) => _sendAge(context, age, value),
    );
  }
}

class RegistrationWeightStep extends StatelessWidget {
  const RegistrationWeightStep({super.key});

  @override
  Widget build(BuildContext context) {
    final weight = context.select<RegisterCubit, num>(
      (cubit) => cubit.state.params.weight,
    );
    return _IntegerWheel(
      minimum: RegistrationMeasurementRules.minimumWeightKg.round(),
      maximum: RegistrationMeasurementRules.maximumWeightKg.round(),
      current: _shownWeight(weight),
      unit: LocaleKeys.profile_setup_kg.tr(),
      onChanged: (value) => _sendWeight(context, weight, value),
    );
  }
}

class RegistrationHeightStep extends StatelessWidget {
  const RegistrationHeightStep({super.key});

  @override
  Widget build(BuildContext context) {
    final height = context.select<RegisterCubit, num>(
      (cubit) => cubit.state.params.height,
    );
    return _IntegerWheel(
      minimum: RegistrationMeasurementRules.minimumHeightCm.round(),
      maximum: RegistrationMeasurementRules.maximumHeightCm.round(),
      current: _shownHeight(height),
      unit: LocaleKeys.profile_setup_cm.tr(),
      onChanged: (value) => _sendHeight(context, height, value),
    );
  }
}

class _IntegerWheel extends StatelessWidget {
  const _IntegerWheel({
    required this.minimum,
    required this.maximum,
    required this.current,
    required this.unit,
    required this.onChanged,
  });

  final int minimum;
  final int maximum;
  final int current;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final count = maximum - minimum + 1;
    final index = (current - minimum).clamp(0, count - 1);
    return RegistrationValueWheel(
      labels: [for (var value = minimum; value <= maximum; value++) '$value'],
      selectedIndex: index,
      unit: unit,
      onChanged: (item) => onChanged(minimum + item),
    );
  }
}

int _shownWeight(num weight) {
  if (!RegistrationMeasurementRules.isValidWeight(weight)) {
    return RegistrationMeasurementRules.defaultWeightKg.round();
  }
  return _clampInt(
    weight.round(),
    RegistrationMeasurementRules.minimumWeightKg.round(),
    RegistrationMeasurementRules.maximumWeightKg.round(),
  );
}

int _shownHeight(num height) {
  if (!RegistrationMeasurementRules.isValidHeight(height)) {
    return RegistrationMeasurementRules.defaultHeightCm.round();
  }
  return _clampInt(
    height.round(),
    RegistrationMeasurementRules.minimumHeightCm.round(),
    RegistrationMeasurementRules.maximumHeightCm.round(),
  );
}

int _clampInt(int value, int minimum, int maximum) {
  if (value < minimum) {
    return minimum;
  }
  if (value > maximum) {
    return maximum;
  }
  return value;
}

void _sendAge(BuildContext context, int age, int value) {
  if (value == age) {
    return;
  }
  context.read<RegisterCubit>().doIntent(SelectAgeIntent(value));
}

void _sendWeight(BuildContext context, num weight, int value) {
  if (value == weight) {
    return;
  }
  context.read<RegisterCubit>().doIntent(SelectWeightIntent(value));
}

void _sendHeight(BuildContext context, num height, int value) {
  if (value == height) {
    return;
  }
  context.read<RegisterCubit>().doIntent(SelectHeightIntent(value));
}
