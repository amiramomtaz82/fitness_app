import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable dark-themed bottom sheet matching Figma guidelines.
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.showDragHandle = true,
    this.padding,
  });

  /// Displays the modal bottom sheet using [AppBottomSheet] styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.6),
      builder: (context) => AppBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle) ...[
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ],
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  title!,
                  style: AppTextStyles.white20bold,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
