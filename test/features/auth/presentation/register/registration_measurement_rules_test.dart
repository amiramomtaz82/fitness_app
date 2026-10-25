import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_measurement_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const empty = RegisterParameters();
const filled = RegisterParameters(age: 40, weight: 70.5, height: 180);

void main() {
  ageBounds();
  weightBounds();
  heightBounds();
  defaultsFillUnsetMeasurements();
  otherStepsKeepParameters();
}

void ageBounds() {
  test('age is unset at zero and valid from 16 through 100', () {
    expect(RegistrationMeasurementRules.isAgeUnset(0), isTrue);
    expect(RegistrationMeasurementRules.isAgeUnset(16), isFalse);
    expect(RegistrationMeasurementRules.isValidAge(15), isFalse);
    expect(RegistrationMeasurementRules.isValidAge(16), isTrue);
    expect(RegistrationMeasurementRules.isValidAge(100), isTrue);
    expect(RegistrationMeasurementRules.isValidAge(101), isFalse);
  });
}

void weightBounds() {
  test('weight follows the shared validator inside 20 to 350', () {
    expect(RegistrationMeasurementRules.isWeightUnset(0), isTrue);
    expect(RegistrationMeasurementRules.isValidWeight(19.9), isFalse);
    expect(RegistrationMeasurementRules.isValidWeight(20), isTrue);
    expect(RegistrationMeasurementRules.isValidWeight(70.5), isTrue);
    expect(RegistrationMeasurementRules.isValidWeight(350), isTrue);
    expect(RegistrationMeasurementRules.isValidWeight(350.1), isFalse);
  });
}

void heightBounds() {
  test('height is unset at zero and valid from 100 through 250', () {
    expect(RegistrationMeasurementRules.isHeightUnset(0), isTrue);
    expect(RegistrationMeasurementRules.isValidHeight(99), isFalse);
    expect(RegistrationMeasurementRules.isValidHeight(100), isTrue);
    expect(RegistrationMeasurementRules.isValidHeight(250), isTrue);
    expect(RegistrationMeasurementRules.isValidHeight(251), isFalse);
  });
}

void defaultsFillUnsetMeasurements() {
  test('defaults fill only an unset age, weight, or height', () {
    expect(_entered(1, empty).age, RegistrationMeasurementRules.defaultAge);
    expect(
      _entered(2, empty).weight,
      RegistrationMeasurementRules.defaultWeightKg,
    );
    expect(
      _entered(3, empty).height,
      RegistrationMeasurementRules.defaultHeightCm,
    );
    expect(_entered(1, filled).age, 40);
    expect(_entered(2, filled).weight, 70.5);
    expect(_entered(3, filled).height, 180);
  });
}

void otherStepsKeepParameters() {
  test('steps outside the measurements keep the parameters', () {
    expect(RegistrationMeasurementRules.firstStepIndex, 0);
    expect(RegistrationMeasurementRules.lastStepIndex, 5);
    expect(_entered(0, filled), filled);
    expect(_entered(4, filled), filled);
    expect(_entered(5, empty), empty);
  });
}

RegisterParameters _entered(int step, RegisterParameters params) {
  return RegistrationMeasurementRules.withStepDefaults(step, params);
}
