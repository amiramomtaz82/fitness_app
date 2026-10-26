import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/context.extension.dart';
import '../../../registration_measurement_rules.dart';

class RegistrationProgress extends StatelessWidget {
  const RegistrationProgress({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const stepCount = RegistrationMeasurementRules.lastStepIndex + 1;
    final visibleStep = currentStep + 1;
    return SizedBox(
      width: 72.r,
      height: 72.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RegistrationProgressRing(value: visibleStep / stepCount),
          Text('$visibleStep/$stepCount', style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class RegistrationProgressRing extends StatelessWidget {
  const RegistrationProgressRing({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CircularProgressIndicator(
      value: value,
      strokeWidth: 4.r,
      color: colors.primary,
      backgroundColor: colors.border.withValues(alpha: 0.35),
    );
  }
}
