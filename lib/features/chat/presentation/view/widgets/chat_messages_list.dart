import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
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

        final photoUrl = state.profile?.photoUrl;
        final reversed = state.messages.reversed.toList();
        final leadingCount = state.isSending ? 1 : 0;

        if (reversed.isEmpty && !state.isSending) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              CoachTextBubble(
                text: LocaleKeys.chat_hello_how_can_i_assist.tr(),
              ),
            ],
          );
        }

        return ListView.separated(
          reverse: true,
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
        );
      },
    );
  }
}
