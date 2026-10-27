import 'dart:ui';

import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPageItem extends StatelessWidget {
  const OnboardingPageItem({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                height: 320.h,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.background.withValues(alpha: 0.3),
                      colors.background.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 56.h),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.white20bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.grey12regular,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
