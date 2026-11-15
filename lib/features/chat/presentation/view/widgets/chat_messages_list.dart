import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';
import '../../view_model/smart_coach_state.dart';
import 'chat_bubble.dart';
import 'coach_typing_indicator.dart';

class ChatMessagesList extends StatelessWidget {
  const ChatMessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartCoachCubit, SmartCoachState>(
      buildWhen: (previous, current) =>
          previous.messages != current.messages ||
          previous.isSending != current.isSending ||
          previous.conversationResource != current.conversationResource ||
          previous.profile != current.profile,
      builder: (context, state) {
        if (state.conversationResource.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          );
        }

        if (state.conversationResource.isError) {
          return const _ConversationError();
        }

        final photoUrl = state.profile?.photoUrl;
        final reversed = state.messages.reversed.toList();
        final leadingCount = state.isSending ? 1 : 0;

        return Align(
          alignment: Alignment.topCenter,
          child: ListView.separated(
            reverse: true,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: reversed.length + leadingCount,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index < leadingCount) return const CoachTypingIndicator();
              final message = reversed[index - leadingCount];
              return ChatBubble(
                key: ValueKey(message.id),
                message: message,
                userPhotoUrl: photoUrl,
              );
            },
          ),
        );
      },
    );
  }
}

class _ConversationError extends StatelessWidget {
  const _ConversationError();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('conversation_error'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.grey, size: 40.r),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.chat_load_conversation_failed.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.white14regular,
            ),
            SizedBox(height: 8.h),
            TextButton(
              key: const Key('retry_conversation_button'),
              onPressed: () => context.read<SmartCoachCubit>().doIntent(
                const RetryLoadConversationIntent(),
              ),
              child: Text(
                LocaleKeys.chat_retry.tr(),
                style: AppTextStyles.orange12regular.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
