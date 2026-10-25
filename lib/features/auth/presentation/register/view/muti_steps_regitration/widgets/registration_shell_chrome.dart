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
import '../../../manager/cubit/register_intent.dart';
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
            const RegistrationLogo(),
            SizedBox(height: 12.h),
            RegistrationHeader(onBack: onBack),
            SizedBox(height: 16.h),
            RegistrationPanel(pageController: pageController),
            SizedBox(height: 16.h),
            RegistrationNextButton(onNext: onNext),
          ],
        ),
      ),
    );
  }
}

class RegistrationLogo extends StatelessWidget {
  const RegistrationLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.logo, height: 56.h, fit: BoxFit.contain);
  }
}

class RegistrationHeader extends StatelessWidget {
  const RegistrationHeader({super.key, required this.onBack});

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

class RegistrationPanel extends StatelessWidget {
  const RegistrationPanel({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RegistrationBlurredPanel(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              const RegistrationTitles(),
              SizedBox(height: 16.h),
              Expanded(child: RegistrationPages(controller: pageController)),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationBlurredPanel extends StatelessWidget {
  const RegistrationBlurredPanel({super.key, required this.child});

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

class RegistrationTitles extends StatelessWidget {
  const RegistrationTitles({super.key});

  @override
  Widget build(BuildContext context) {
    final step = context.select<RegisterCubit, int>(
      (cubit) => cubit.state.currentStep,
    );
    final index = step.clamp(0, _stepKeys.length - 1);
    final keys = _stepKeys[index];
    return RegistrationStepCopy(title: keys.$1.tr(), subtitle: keys.$2.tr());
  }
}

class RegistrationStepCopy extends StatelessWidget {
  const RegistrationStepCopy({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    return Column(
      children: [
        RegistrationStepLine(text: title, style: theme.headlineLarge),
        SizedBox(height: 8.h),
        RegistrationStepLine(text: subtitle, style: _subtitleStyle(context)),
      ],
    );
  }

  TextStyle? _subtitleStyle(BuildContext context) {
    return context.textTheme.bodyMedium?.copyWith(color: context.colors.grey);
  }
}

class RegistrationStepLine extends StatelessWidget {
  const RegistrationStepLine({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

class RegistrationPages extends StatelessWidget {
  const RegistrationPages({super.key, required this.controller});

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

class RegistrationNextButton extends StatelessWidget {
  const RegistrationNextButton({super.key, this.onNext});

  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final isLastStep = context.select<RegisterCubit, bool>(
      (cubit) =>
          cubit.state.currentStep == RegistrationMeasurementRules.lastStepIndex,
    );
    final isLoading = context.select<RegisterCubit, bool>(
      (cubit) => cubit.state.registerResource.isLoading,
    );
    final enabled = context.select<RegisterCubit, bool>(_canPressNext);

    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                final cubit = context.read<RegisterCubit>();
                if (cubit.state.isPaging || isLoading) return;

                if (isLastStep) {
                  cubit.doIntent(const SubmitRegistrationIntent());
                } else {
                  cubit.doIntent(const NextStepIntent());
                }
              }
            : null,
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                isLastStep
                    ? LocaleKeys.auth_register.tr()
                    : LocaleKeys.common_next.tr(),
              ),
      ),
    );
  }
}

bool _canPressNext(RegisterCubit cubit) {
  final state = cubit.state;
  if (state.isPaging || state.registerResource.isLoading) return false;
  if (state.currentStep == RegistrationMeasurementRules.lastStepIndex) {
    return state.selectedActivity != null; // Enabled once activity is chosen
  }
  return true;
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
