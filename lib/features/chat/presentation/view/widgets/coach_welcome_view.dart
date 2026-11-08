import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/contants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/frosted_panel.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';
import 'coach_logo.dart';

class CoachWelcomeView extends StatelessWidget {
  const CoachWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          const _WelcomeHeader(),
          Expanded(child: Image.asset(AppAssets.robot, fit: BoxFit.contain)),
          FrostedPanel(
            radius: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.chat_how_can_i_assist_you_today.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.white20bold,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => context.read<SmartCoachCubit>().doIntent(
                      const GetStartedIntent(),
                    ),
                    child: Text(
                      LocaleKeys.chat_get_started.tr(),
                      style: AppTextStyles.white14bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final firstName = context.select<SmartCoachCubit, String>(
      (cubit) => cubit.state.profile?.firstName.trim() ?? '',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CoachLogo(),
        Expanded(
          child: Column(
            children: [
              if (firstName.isNotEmpty)
                Text(
                  LocaleKeys.chat_hi_user.tr(args: [firstName]),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.white14bold,
                ),
              Text(
                LocaleKeys.chat_i_am_your_smart_coach.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.white14bold,
              ),
            ],
          ),
        ),
        SizedBox(width: 24.r),
      ],
    );
  }
}
