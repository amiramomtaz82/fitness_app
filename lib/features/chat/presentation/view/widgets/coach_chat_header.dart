import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/app_back_button.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';
import 'open_conversations_button.dart';

class CoachChatHeader extends StatelessWidget {
  const CoachChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionTitle = context.select<SmartCoachCubit, String?>(
      (cubit) => cubit.state.sessionTitle,
    );

    return Row(
      children: [
        Semantics(
          button: true,
          label: LocaleKeys.chat_back.tr(),
          child: AppBackButton(
            key: const Key('chat_back_button'),
            onTap: () => context.read<SmartCoachCubit>().doIntent(
              const BackToWelcomeIntent(),
            ),
          ),
        ),
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
        const OpenConversationsButton(),
      ],
    );
  }
}
