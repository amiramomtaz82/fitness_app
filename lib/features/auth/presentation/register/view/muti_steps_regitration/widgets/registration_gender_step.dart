import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/contants/app_assets.dart';
import '../../../../../../../core/theme/app_colors.dart';
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
    return RegistrationGenderChoices(selectedName: gender);
  }
}

class RegistrationGenderChoices extends StatelessWidget {
  const RegistrationGenderChoices({super.key, required this.selectedName});

  final String selectedName;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        children: [
          RegistrationGenderOption(
            option: RegistrationGender.male,
            asset: AppAssets.male,
            selectedName: selectedName,
          ),
          SizedBox(width: 12.w),
          RegistrationGenderOption(
            option: RegistrationGender.female,
            asset: AppAssets.female,
            selectedName: selectedName,
          ),
        ],
      ),
    );
  }
}

class RegistrationGenderOption extends StatelessWidget {
  const RegistrationGenderOption({
    super.key,
    required this.option,
    required this.asset,
    required this.selectedName,
  });

  final RegistrationGender option;
  final String asset;
  final String selectedName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RegistrationGenderChoice(
        label: option.displayText,
        asset: asset,
        selected: selectedName == option.name,
        onTap: () => _select(context, option.name),
      ),
    );
  }
}

void _select(BuildContext context, String gender) {
  context.read<RegisterCubit>().doIntent(SelectGenderIntent(gender));
}

class RegistrationGenderChoice extends StatelessWidget {
  const RegistrationGenderChoice({
    super.key,
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
      color: AppColors.inputTransparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: RegistrationGenderCard(
          label: label,
          asset: asset,
          selected: selected,
        ),
      ),
    );
  }
}

class RegistrationGenderCard extends StatelessWidget {
  const RegistrationGenderCard({
    super.key,
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
        child: RegistrationGenderBody(label: label, asset: asset),
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

class RegistrationGenderBody extends StatelessWidget {
  const RegistrationGenderBody({
    super.key,
    required this.label,
    required this.asset,
  });

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
