import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_app/core/local/locale_cubit.dart';
import 'package:fitness_app/core/local/locale_state.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/widgets/frosted_panel.dart';

import '../../view_model/profile_cubit.dart';
import '../../view_model/profile_intent.dart';
import '../models/profile_menu_item.dart';
import '../models/profile_menu_titles.dart';
import 'profile_menu_tile.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final colors = context.colors;

    return BlocBuilder<LocaleCubit, LocaleState>(
      buildWhen: (previous, current) =>
          previous.language != current.language,
      builder: (context, state) => FrostedPanel(
        radius: 20,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, item) in profileMenuItems.indexed) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.white.withValues(alpha: 0.08),
                ),
              ProfileMenuTile(
                key: Key('menu_${item.action.name}'),
                item: item,
                titleKey: menuTitleKey(state.language, item.action),
                languageSwitchOn: state.isLanguageSwitchOn,
                onTap: () => cubit.doIntent(MenuTapIntent(item)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
