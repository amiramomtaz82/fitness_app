import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/contants/app_assets.dart';
import '../../../../../../../core/theme/context.extension.dart';
import '../../../../../../../core/theme/custom_colors.dart';
import '../../../manager/cubit/register_cubit.dart';
import '../../../manager/cubit/register_intent.dart';
import '../../../registration_options.dart';

class RegistrationGenderStep extends StatelessWidget {
  const RegistrationGenderStep({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = context.select<RegisterCubit, String>(
      (cubit) => cubit.state.params.gender,
    );
    const male = RegistrationGender.male;
    const female = RegistrationGender.female;
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        children: [
          Expanded(
            child: _GenderChoice(
              label: male.displayText,
              asset: AppAssets.male,
              selected: gender == male.name,
              onTap: () => _select(context, male.name),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _GenderChoice(
              label: female.displayText,
              asset: AppAssets.female,
              selected: gender == female.name,
              onTap: () => _select(context, female.name),
            ),
          ),
        ],
      ),
    );
  }
}

void _select(BuildContext context, String gender) {
  context.read<RegisterCubit>().doIntent(SelectGenderIntent(gender));
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: _GenderCard(label: label, asset: asset, selected: selected),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.asset,
    required this.selected,
  });

  final String label;
  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: _decoration(context.colors),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: _GenderBody(label: label, asset: asset),
      ),
    );
  }

  BoxDecoration _decoration(CustomColors colors) {
    return BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(
        color: selected ? colors.primary : colors.border,
        width: selected ? 2 : 1,
      ),
    );
  }
}

class _GenderBody extends StatelessWidget {
  const _GenderBody({required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, height: 72.h, fit: BoxFit.contain),
        SizedBox(height: 8.h),
        Text(label, style: context.textTheme.titleMedium),
      ],
    );
  }
}
