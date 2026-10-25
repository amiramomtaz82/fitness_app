import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  final PageController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final page = (controller.hasClients ? controller.page : null) ?? 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final t = (1 - (page - index).abs()).clamp(0.0, 1.0).toDouble();

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: 8.w + 16.w * t,
              height: 8.h,
              decoration: BoxDecoration(
                color: Color.lerp(colors.white, colors.primary, t),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        );
      },
    );
  }
}
