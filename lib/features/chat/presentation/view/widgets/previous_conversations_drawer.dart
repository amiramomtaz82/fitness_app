import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../domain/entites/chat_entities/chat_session_entity.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';
import '../../view_model/smart_coach_state.dart';

class PreviousConversationsDrawer extends StatefulWidget {
  const PreviousConversationsDrawer({super.key});

  @override
  State<PreviousConversationsDrawer> createState() =>
      _PreviousConversationsDrawerState();
}

class _PreviousConversationsDrawerState
    extends State<PreviousConversationsDrawer> {
  SmartCoachCubit get _cubit => context.read<SmartCoachCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.doIntent(const LoadPreviousSessionsIntent());
  }

  void _closeThen(SmartCoachIntent intent) {
    Navigator.of(context).pop();
    _cubit.doIntent(intent);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 0.6.sw,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24.r),
          bottomStart: Radius.circular(24.r),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: AppColors.surface.withValues(alpha: 0.75),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Text(
                    LocaleKeys.chat_previous_conversations.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.white14bold.copyWith(fontSize: 16.sp),
                  ),
                ),
                TextButton.icon(
                  key: const Key('drawer_new_chat_button'),
                  onPressed: () => _closeThen(const StartNewChatIntent()),
                  icon: Icon(Icons.add, color: AppColors.orange, size: 18.r),
                  label: Text(
                    LocaleKeys.chat_new_chat.tr(),
                    style: AppTextStyles.orange12regular.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SmartCoachCubit, SmartCoachState>(
                    buildWhen: (previous, current) =>
                        previous.sessionsResource != current.sessionsResource ||
                        previous.sessionId != current.sessionId,
                    builder: (context, state) => _SessionsBody(
                      state: state,
                      onRetry: () =>
                          _cubit.doIntent(const LoadPreviousSessionsIntent()),
                      onSelect: (session) =>
                          _closeThen(SelectSessionIntent(session)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionsBody extends StatelessWidget {
  final SmartCoachState state;
  final VoidCallback onRetry;
  final ValueChanged<ChatSessionEntity> onSelect;

  const _SessionsBody({
    required this.state,
    required this.onRetry,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final resource = state.sessionsResource;
    final sessions = resource.data ?? const <ChatSessionEntity>[];

    if (sessions.isEmpty) {
      if (resource.isLoading || resource.isInitial) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        );
      }
      if (resource.isError) {
        return Center(
          child: TextButton(
            onPressed: onRetry,
            child: Text(
              LocaleKeys.chat_retry.tr(),
              style: AppTextStyles.orange12regular,
            ),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(
            LocaleKeys.chat_no_previous_conversations.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.grey12regular,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      itemCount: sessions.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: AppColors.white.withValues(alpha: 0.08)),
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isCurrent = session.id == state.sessionId;
        return ListTile(
          key: ValueKey('session_${session.id}'),
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
          selected: isCurrent,
          selectedTileColor: AppColors.orange.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          leading: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.orange,
            size: 14.r,
          ),
          minLeadingWidth: 14.r,
          title: Text(
            session.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.white14regular.copyWith(fontSize: 12.sp),
          ),
          onTap: () => onSelect(session),
        );
      },
    );
  }
}
