import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class EditSaveButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  const EditSaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final actionable = enabled && !isLoading;
    return FilledButton(
      key: const Key('editSaveButton'),
      onPressed: actionable ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        disabledBackgroundColor: colors.primary.withValues(alpha: 0.6),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 22.w,
              height: 22.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.white,
              ),
            )
          : Text(LocaleKeys.common_save.tr()),
    );
  }
}
