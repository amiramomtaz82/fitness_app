import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import '../../theme/text_styles.dart';

class WebViewErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const WebViewErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.errors_something_went_wrong.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.white14regular,
            ),
            SizedBox(height: 20.h),
            FilledButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.common_retry.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
