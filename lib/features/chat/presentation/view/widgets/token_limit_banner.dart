import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../../domain/entites/chat_entities/token_status_entity.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';

class TokenLimitBanner extends StatelessWidget {
  const TokenLimitBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final level = context.select<SmartCoachCubit, TokenLimitLevel>(
      (cubit) => cubit.state.tokenStatus.level,
    );
    if (level == TokenLimitLevel.normal) return const SizedBox.shrink();

    final isLocked = level == TokenLimitLevel.locked8k;
    final color = isLocked ? AppColors.error : AppColors.warning;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsetsDirectional.fromSTEB(12.w, 8.h, 4.w, 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.block : Icons.warning_amber_rounded,
            color: color,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isLocked
                  ? LocaleKeys.chat_token_limit_reached.tr()
                  : LocaleKeys.chat_token_limit_warning.tr(),
              style: AppTextStyles.white14regular.copyWith(fontSize: 12.sp),
            ),
          ),
          TextButton(
            key: const Key('banner_new_chat_button'),
            onPressed: () => context.read<SmartCoachCubit>().doIntent(
              const StartNewChatIntent(),
            ),
            child: Text(
              LocaleKeys.chat_new_chat.tr(),
              style: AppTextStyles.orange12regular.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
