import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/go_routes/routes_names.dart';

import '../../../../../../../core/theme/text_styles.dart';
import '../../../../../../../generated/locale_keys.g.dart';


class RegisterFooter extends StatelessWidget {
  const RegisterFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${LocaleKeys.auth_already_have_account.tr()} ',
          style: AppTextStyles.white14regular,
        ),
        InkWell(
          onTap: () => context.go(AppRoutes.login),
          child: Text(
            LocaleKeys.auth_login.tr(),
            style: AppTextStyles.darkOrange14Bold.copyWith(
                decoration:TextDecoration.underline,
          color: AppColors.orange),
          ),
        ),
      ],
    );
  }
}