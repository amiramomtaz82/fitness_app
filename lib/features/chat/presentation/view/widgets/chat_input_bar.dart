import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';
import 'text_direction_resolver.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  TextDirection? _direction;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateDirection);
  }

  void _updateDirection() {
    final direction = TextDirectionResolver.of(_controller.text);
    if (direction != _direction) setState(() => _direction = direction);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateDirection);
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<SmartCoachCubit>().doIntent(SendMessageIntent(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = context.select<SmartCoachCubit, bool>(
      (cubit) => cubit.state.canSend,
    );
    final isLocked = context.select<SmartCoachCubit, bool>(
      (cubit) => cubit.state.tokenStatus.isLocked,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 16.w, end: 4.w),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('chat_input_field'),
                controller: _controller,
                textDirection: _direction,
                enabled: !isLocked,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (canSend) _send();
                },
                style: AppTextStyles.white14regular,
                cursorColor: AppColors.orange,
                decoration: InputDecoration(
                  hintText: LocaleKeys.chat_type_message_hint.tr(),
                  hintStyle: AppTextStyles.grey12regular.copyWith(
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              key: const Key('chat_send_button'),
              tooltip: LocaleKeys.chat_send.tr(),
              onPressed: canSend ? _send : null,
              icon: Icon(
                Icons.send_rounded,
                color: canSend ? AppColors.orange : AppColors.darkGrey,
                size: 22.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
