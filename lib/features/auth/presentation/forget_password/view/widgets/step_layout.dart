import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/widgets/frosted_panel.dart';

class StepLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool subtitleAbove;
  final Widget child;

  const StepLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.subtitleAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleText = Text(
      title,
      textAlign: TextAlign.start,
      style: context.textTheme.headlineLarge?.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );

    final subtitleText = Text(
      subtitle,
      textAlign: TextAlign.start,
      style: context.textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
    );

    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 2.0,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          left: 12.w,
          right: 12.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (subtitleAbove) ...[
              subtitleText,
              SizedBox(height: 6.h),
              titleText,
            ] else ...[
              titleText,
              SizedBox(height: 6.h),
              subtitleText,
            ],
            SizedBox(height: 28.h),
            FrostedPanel(child: child),
          ],
        ),
      ),
    );
  }
}
