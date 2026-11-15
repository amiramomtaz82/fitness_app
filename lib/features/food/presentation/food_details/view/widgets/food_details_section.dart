import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/context.extension.dart';

class FoodDetailsSection extends StatelessWidget {
  const FoodDetailsSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: sectionTitleStyle(context)),
        SizedBox(height: 12.h),
        child,
      ],
    );
  }
}

TextStyle sectionTitleStyle(BuildContext context) {
  final style = context.textTheme.titleMedium ?? const TextStyle();
  return style.copyWith(
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
}
