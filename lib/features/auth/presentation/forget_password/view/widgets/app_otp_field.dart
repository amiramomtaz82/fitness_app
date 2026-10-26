import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../../../core/theme/context.extension.dart';

/// Themed one-time-code input with an inline error message slot.
///
/// Uses the Figma "underline" style: orange digits over a thin underline that
/// turns orange once filled/focused.
///
/// [errorNotifier] is deliberately a [ValueNotifier]: setting or clearing the
/// error rebuilds only the error text, never the whole step/screen.
class AppOtpField extends StatelessWidget {
  final int length;
  final bool enabled;
  final bool autofocus;
  final ValueListenable<String?> errorNotifier;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  const AppOtpField({
    super.key,
    required this.onChanged,
    required this.onCompleted,
    required this.errorNotifier,
    this.length = 6,
    this.enabled = true,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    PinTheme underline({required Color lineColor}) => PinTheme(
      width: 52.w,
      height: 52.h,
      textStyle: TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: colors.primary,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: lineColor, width: 2)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Pinput(
          length: length,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          onCompleted: onCompleted,
          defaultPinTheme: underline(
            lineColor: colors.white.withValues(alpha: 0.7),
          ),
          focusedPinTheme: underline(lineColor: colors.primary),
          submittedPinTheme: underline(lineColor: colors.primary),
          errorPinTheme: underline(lineColor: colors.error),
        ),
        SizedBox(height: 8.h),
        ValueListenableBuilder<String?>(
          valueListenable: errorNotifier,
          builder: (context, error, _) =>
              error == null
                  ? const SizedBox.shrink()
                  : Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: colors.error),
                  ),
        ),
      ],
    );
  }
}
