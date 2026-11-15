import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import 'coach_avatar.dart';

class CoachTypingIndicator extends StatefulWidget {
  const CoachTypingIndicator({super.key});

  @override
  State<CoachTypingIndicator> createState() => _CoachTypingIndicatorState();
}

class _CoachTypingIndicatorState extends State<CoachTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CoachAvatar(),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value * 3 - index).clamp(0.0, 1.0);
                final opacity = 0.3 + 0.7 * (1 - (phase - 0.5).abs() * 2);
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
