import '../../../../core/validation/form_validators.dart';
import '../../domain/entities/register_parameters.dart';

/// Approved profile-measurement bounds and one-time defaults.
abstract final class RegistrationMeasurementRules {
  static const int minimumAge = 16;
  static const int maximumAge = 100;
  static const int defaultAge = 25;
  static const num minimumWeightKg = 20;
  static const num maximumWeightKg = 350;
  static const num defaultWeightKg = 90;
  static const num minimumHeightCm = 100;
  static const num maximumHeightCm = 250;
  static const num defaultHeightCm = 167;
  static const int firstStepIndex = 0;
  static const int lastStepIndex = 5;

  static bool isAgeUnset(int age) => age == 0;

  static bool isWeightUnset(num weight) => weight == 0;

  static bool isHeightUnset(num height) => height == 0;

  static bool isValidAge(int age) {
    return age >= minimumAge && age <= maximumAge;
  }

  static bool isValidWeight(num weight) {
    if (weight < minimumWeightKg || weight > maximumWeightKg) {
      return false;
    }
    return FormValidators.validateWeight(weight.toString()) == null;
  }

  static bool isValidHeight(num height) {
    return height >= minimumHeightCm && height <= maximumHeightCm;
  }

  static RegisterParameters withStepDefaults(
    int step,
    RegisterParameters params,
  ) {
    return switch (step) {
      1 => _withDefaultAge(params),
      2 => _withDefaultWeight(params),
      3 => _withDefaultHeight(params),
      _ => params,
    };
  }

  static RegisterParameters _withDefaultAge(RegisterParameters params) {
    if (!isAgeUnset(params.age)) {
      return params;
    }
    return params.copyWith(age: defaultAge);
  }

  static RegisterParameters _withDefaultWeight(RegisterParameters params) {
    if (!isWeightUnset(params.weight)) {
      return params;
    }
    return params.copyWith(weight: defaultWeightKg);
  }

  static RegisterParameters _withDefaultHeight(RegisterParameters params) {
    if (!isHeightUnset(params.height)) {
      return params;
    }
    return params.copyWith(height: defaultHeightCm);
  }
}
