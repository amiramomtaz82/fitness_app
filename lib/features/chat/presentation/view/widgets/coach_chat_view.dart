import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chat_input_bar.dart';
import 'chat_messages_list.dart';
import 'coach_chat_header.dart';
import 'token_limit_banner.dart';

class CoachChatView extends StatelessWidget {
  const CoachChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: const CoachChatHeader(),
        ),
        const TokenLimitBanner(),
        const Expanded(child: ChatMessagesList()),
        const ChatInputBar(),
      ],
    );
  }
}
