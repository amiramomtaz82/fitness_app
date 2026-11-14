import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppImagePlaceholder extends StatelessWidget {
  final String? message;

  const AppImagePlaceholder({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = message;

    return ColoredBox(
      color: colors.card,
      child: Center(
        child: label == null
            ? Icon(Icons.image_not_supported_outlined, color: colors.grey)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_not_supported_outlined, color: colors.grey),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: AppTextStyles.grey12regular,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
