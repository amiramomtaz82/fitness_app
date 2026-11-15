import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../view_model/smart_coach_cubit.dart';
import 'chat_empty_state.dart';
import 'chat_input_bar.dart';
import 'chat_messages_list.dart';
import 'coach_chat_header.dart';
import 'token_limit_banner.dart';

class CoachChatView extends StatefulWidget {
  const CoachChatView({super.key});

  @override
  State<CoachChatView> createState() => _CoachChatViewState();
}

class _CoachChatViewState extends State<CoachChatView> {
  final _inputKey = GlobalKey();
  final _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _inputFocus.removeListener(_onFocusChanged);
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmptyChat = context.select<SmartCoachCubit, bool>(
      (cubit) => cubit.state.isEmptyChat,
    );
    final input = ChatInputBar(key: _inputKey, focusNode: _inputFocus);
    final centerInput = isEmptyChat && !_inputFocus.hasFocus;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: const CoachChatHeader(),
        ),
        const TokenLimitBanner(),
        if (centerInput)
          Expanded(child: ChatEmptyState(input: input))
        else ...[
          Expanded(
            child: isEmptyChat
                ? const ChatEmptyState()
                : const ChatMessagesList(),
          ),
          input,
        ],
      ],
    );
  }
}
