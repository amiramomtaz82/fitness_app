import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResendCodeButton extends StatelessWidget {
  final VoidCallback onResend;
  final int secondsLeft;
  final bool isResending;

  const ResendCodeButton({
    super.key,
    required this.onResend,
    required this.isResending,
    this.secondsLeft = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCoolingDown = secondsLeft > 0;
    final canTap = !isCoolingDown && !isResending;

    if (isResending) {
      return SizedBox(
        height: 18.w,
        width: 18.w,
        child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
      );
    }

    final label = isCoolingDown
        ? LocaleKeys.auth_resend_in.tr(
            namedArgs: {'seconds': '$secondsLeft'},
          )
        : LocaleKeys.auth_resend_code.tr();

    return TextButton(
      onPressed: canTap ? onResend : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colors.primary,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          decoration: canTap ? TextDecoration.underline : TextDecoration.none,
          color: canTap ? colors.primary : colors.hint,
        ),
      ),
    );
  }
}
