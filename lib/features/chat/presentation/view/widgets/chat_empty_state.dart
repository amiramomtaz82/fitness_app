import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
import 'coach_avatar.dart';

class ChatEmptyState extends StatelessWidget {
  final Widget? input;

  const ChatEmptyState({super.key, this.input});

  @override
  Widget build(BuildContext context) {
    final firstName = context.select<SmartCoachCubit, String>(
      (cubit) => cubit.state.profile?.firstName.trim() ?? '',
    );

    return Center(
      key: const Key('chat_empty_state'),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(scale: 1.6, child: const CoachAvatar()),
            SizedBox(height: 20.h),
            if (firstName.isNotEmpty)
              Text(
                LocaleKeys.chat_hi_user.tr(args: [firstName]),
                textAlign: TextAlign.center,
                style: AppTextStyles.white14bold,
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              child: Text(
                LocaleKeys.chat_how_can_i_assist_you_today.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.white20bold,
              ),
            ),
            if (input case final input?) ...[SizedBox(height: 12.h), input],
          ],
        ),
      ),
    );
  }
}
