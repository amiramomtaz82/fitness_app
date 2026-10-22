import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/contants/app_assets.dart';
import '../../../../../../../core/theme/context.extension.dart';
import '../../../../../../../core/widgets/app_background_scaffold.dart';
import '../../../../../../../generated/locale_keys.g.dart';
import '../../../manager/cubit/register_cubit.dart';
import '../../../registration_measurement_rules.dart';
import 'registration_progress.dart';
import 'registration_step_page.dart';

class RegistrationShellBody extends StatelessWidget {
  const RegistrationShellBody({
    super.key,
    required this.pageController,
    required this.onBack,
    required this.onNext,
  });

  final PageController pageController;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      backgroundImage: AppAssets.authProfileBG,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: Column(
          children: [
            const _RegistrationLogo(),
            SizedBox(height: 12.h),
            _RegistrationHeader(onBack: onBack),
            SizedBox(height: 16.h),
            _RegistrationPanel(pageController: pageController),
            SizedBox(height: 16.h),
            _RegistrationNextButton(onNext: onNext),
          ],
        ),
      ),
    );
  }
}

class _RegistrationLogo extends StatelessWidget {
  const _RegistrationLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.logo, height: 56.h, fit: BoxFit.contain);
  }
}

class _RegistrationHeader extends StatelessWidget {
  const _RegistrationHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final step = context.select<RegisterCubit, int>(
      (cubit) => cubit.state.currentStep,
    );
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: LocaleKeys.common_back.tr(),
          icon: const BackButtonIcon(),
        ),
        const Spacer(),
        RegistrationProgress(currentStep: step),
      ],
    );
  }
}

class _RegistrationPanel extends StatelessWidget {
  const _RegistrationPanel({required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _BlurredPanel(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              const _RegistrationTitles(),
              SizedBox(height: 16.h),
              Expanded(child: _RegistrationPages(controller: pageController)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurredPanel extends StatelessWidget {
  const _BlurredPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28.r);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.inputFillTranslucent,
            borderRadius: radius,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RegistrationTitles extends StatelessWidget {
  const _RegistrationTitles();

  @override
  Widget build(BuildContext context) {
    final step = context.select<RegisterCubit, int>(
      (cubit) => cubit.state.currentStep,
    );
    final copy = _copyFor(step);
    final theme = context.textTheme;
    return Column(
      children: [
        Text(
          copy.$1,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.headlineLarge,
        ),
        SizedBox(height: 8.h),
        Text(
          copy.$2,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyMedium?.copyWith(color: context.colors.grey),
        ),
      ],
    );
  }
}

class _RegistrationPages extends StatelessWidget {
  const _RegistrationPages({required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    const count = RegistrationMeasurementRules.lastStepIndex + 1;
    return PageView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, index) => RegistrationStepPage(step: index),
    );
  }
}

class _RegistrationNextButton extends StatelessWidget {
  const _RegistrationNextButton({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<RegisterCubit, bool>(_canPressNext);
    return ElevatedButton(
      onPressed: enabled ? onNext : null,
      child: Text(LocaleKeys.common_next.tr()),
    );
  }
}

bool _canPressNext(RegisterCubit cubit) {
  final state = cubit.state;
  if (state.isPaging || state.registerResource.isLoading) return false;
  final finished =
      state.currentStep == RegistrationMeasurementRules.lastStepIndex &&
      state.selectedActivity != null;
  return !finished;
}

const _stepKeys = <(String, String)>[
  (
    LocaleKeys.profile_setup_tell_us_about_yourself,
    LocaleKeys.profile_setup_need_to_know_gender,
  ),
  (
    LocaleKeys.profile_setup_how_old_are_you,
    LocaleKeys.profile_setup_personalized_plan_subtitle,
  ),
  (
    LocaleKeys.profile_setup_what_is_your_weight,
    LocaleKeys.profile_setup_personalized_plan_subtitle,
  ),
  (
    LocaleKeys.profile_setup_what_is_your_height,
    LocaleKeys.profile_setup_personalized_plan_subtitle,
  ),
  (
    LocaleKeys.profile_setup_what_is_your_goal,
    LocaleKeys.profile_setup_personalized_plan_subtitle,
  ),
  (
    LocaleKeys.profile_setup_activity_level_title,
    LocaleKeys.profile_setup_personalized_plan_subtitle,
  ),
];

(String, String) _copyFor(int step) {
  final index = step.clamp(0, _stepKeys.length - 1);
  final keys = _stepKeys[index];
  return (keys.$1.tr(), keys.$2.tr());
}
