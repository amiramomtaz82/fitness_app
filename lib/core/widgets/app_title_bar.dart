import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/text_styles.dart';
import 'app_back_button.dart';

class AppTitleBar extends StatelessWidget {
  final String titleKey;
  final bool showBackButton;

  const AppTitleBar({
    super.key,
    required this.titleKey,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    const markSize = 34.0;
    return Row(
      children: [
        if (showBackButton)
          const AppBackButton()
        else
          SizedBox(width: markSize.w),
        Expanded(
          child: Text(
            titleKey.tr(),
            style: AppTextStyles.white20bold,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(width: markSize.w),
      ],
    );
  }
}
