import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
import 'coach_logo.dart';

class CoachChatHeader extends StatelessWidget {
  const CoachChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionTitle = context.select<SmartCoachCubit, String?>(
      (cubit) => cubit.state.sessionTitle,
    );

    return Row(
      children: [
        const CoachLogo(),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.chat_smart_coach.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.white20bold,
              ),
              if (sessionTitle != null && sessionTitle.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    sessionTitle,
                    key: const Key('chat_session_title'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.grey12regular,
                  ),
                ),
            ],
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
