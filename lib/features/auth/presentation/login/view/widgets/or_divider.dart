import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../generated/locale_keys.g.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _DividerLine()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            LocaleKeys.auth_or.tr(),
            style: AppTextStyles.white14regular.copyWith(
              color: context.colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ),
        const Expanded(child: _DividerLine()),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(color: context.colors.grey, thickness: 1),
    );
  }
}
