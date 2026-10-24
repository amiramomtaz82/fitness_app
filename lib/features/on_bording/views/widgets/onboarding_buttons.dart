import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingButtons extends StatelessWidget {
  const OnboardingButtons({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.onNext,
    required this.onBack,
    required this.onFinish,
  });

  final bool isFirst;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (isFirst) {
      return ElevatedButton(
        onPressed: onNext,
        child: Text(LocaleKeys.onboarding_next.tr()),
      );
    }

    final colors = Theme.of(context).extension<CustomColors>()!;
    final smallSize = Size(90.w, 40.h);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: onBack,
          style: OutlinedButton.styleFrom(
            minimumSize: smallSize,
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary),
          ),
          child: Text(LocaleKeys.onboarding_back.tr()),
        ),
        ElevatedButton(
          onPressed: isLast ? onFinish : onNext,
          style: ElevatedButton.styleFrom(minimumSize: smallSize),
          child: Text(
            isLast
                ? LocaleKeys.onboarding_do_it.tr()
                : LocaleKeys.onboarding_next.tr(),
          ),
        ),
      ],
    );
  }
}
