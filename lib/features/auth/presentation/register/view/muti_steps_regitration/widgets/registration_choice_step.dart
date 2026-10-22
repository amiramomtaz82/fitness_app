import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/context.extension.dart';
import '../../../manager/cubit/register_cubit.dart';
import '../../../manager/cubit/register_intent.dart';
import '../../../registration_options.dart';

class RegistrationGoalStep extends StatelessWidget {
  const RegistrationGoalStep({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<RegisterCubit, RegistrationGoal?>(
      (cubit) => cubit.state.selectedGoal,
    );
    final choices = <RegistrationChoice>[];
    for (final goal in RegistrationGoal.values) {
      final label = goal.displayText;
      choices.add(
        RegistrationChoice(
          label: label,
          selected: selected == goal,
          onTap: () => _selectGoal(context, goal, label),
        ),
      );
    }
    return RegistrationChoiceList(choices: choices);
  }
}

class RegistrationActivityStep extends StatelessWidget {
  const RegistrationActivityStep({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<RegisterCubit, RegistrationActivity?>(
      (cubit) => cubit.state.selectedActivity,
    );
    final choices = <RegistrationChoice>[];
    for (final activity in RegistrationActivity.values) {
      final label = activity.displayText;
      choices.add(
        RegistrationChoice(
          label: label,
          selected: selected == activity,
          onTap: () => _selectActivity(context, activity, label),
        ),
      );
    }
    return RegistrationChoiceList(choices: choices);
  }
}

class RegistrationChoiceList extends StatelessWidget {
  const RegistrationChoiceList({super.key, required this.choices});

  final List<RegistrationChoice> choices;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: choices.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, index) => _ChoiceTile(choice: choices[index]),
    );
  }
}

class RegistrationChoice {
  const RegistrationChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({required this.choice});

  final RegistrationChoice choice;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: choice.onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: _ChoiceSurface(choice: choice),
      ),
    );
  }
}

class _ChoiceSurface extends StatelessWidget {
  const _ChoiceSurface({required this.choice});

  final RegistrationChoice choice;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: _decoration(context),
      child: _ChoiceLabel(label: choice.label, selected: choice.selected),
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    final colors = context.colors;
    return BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: choice.selected ? colors.primary : colors.border,
        width: choice.selected ? 2 : 1,
      ),
    );
  }
}

class _ChoiceLabel extends StatelessWidget {
  const _ChoiceLabel({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.colors.textPrimary;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: context.textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}

void _selectGoal(BuildContext context, RegistrationGoal goal, String label) {
  context.read<RegisterCubit>().doIntent(SelectGoalIntent(goal, label));
}

void _selectActivity(
  BuildContext context,
  RegistrationActivity activity,
  String label,
) {
  context.read<RegisterCubit>().doIntent(SelectActivityIntent(activity, label));
}
