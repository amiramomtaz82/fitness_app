import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseChevron extends StatelessWidget {
  const ExerciseChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: context.colors.grey,
      size: 24.r,
    );
  }
}
