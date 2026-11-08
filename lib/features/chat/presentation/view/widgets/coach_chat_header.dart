import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import 'coach_logo.dart';

class CoachChatHeader extends StatelessWidget {
  const CoachChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CoachLogo(),
        Expanded(
          child: Text(
            LocaleKeys.chat_smart_coach.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.white20bold,
          ),
        ),
        IconButton(
          key: const Key('open_previous_conversations'),
          tooltip: LocaleKeys.chat_previous_conversations.tr(),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 24.r, height: 24.r),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: Icon(Icons.sort, color: AppColors.orange, size: 24.r),
        ),
      ],
    );
  }
}
