import 'package:flutter/material.dart';

import 'registration_choice_step.dart';
import 'registration_gender_step.dart';
import 'registration_measurement_steps.dart';

class RegistrationStepPage extends StatelessWidget {
  const RegistrationStepPage({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: switch (step) {
        0 => const RegistrationGenderStep(),
        1 => const RegistrationAgeStep(),
        2 => const RegistrationWeightStep(),
        3 => const RegistrationHeightStep(),
        4 => const RegistrationGoalStep(),
        5 => const RegistrationActivityStep(),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
