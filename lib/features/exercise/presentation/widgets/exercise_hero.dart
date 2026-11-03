import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseHero extends StatelessWidget {
  final Widget background;
  final String title;
  final String? subtitle;
  final double height;

  const ExerciseHero({
    super.key,
    required this.background,
    required this.title,
    required this.height,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final detail = subtitle;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomRadius = BorderRadius.vertical(bottom: Radius.circular(24.r));

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ClipRRect(borderRadius: bottomRadius, child: background),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: bottomRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.45),
                    colors.background.withValues(alpha: 0.9),
                  ],
                  stops: const [0.3, 0.65, 1.0],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.white20bold.copyWith(fontSize: 22.sp),
                  ),
                  if (detail != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.white14regular.copyWith(
                        color: colors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: topInset + 16.h,
            start: 16.w,
            child: const AppBackButton(),
          ),
        ],
      ),
    );
  }
}
