import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import '../models/profile_menu_item.dart';
import '../models/profile_menu_trailing.dart';

class ProfileMenuTile extends StatelessWidget {
  final ProfileMenuItem item;
  final String titleKey;
  final bool languageSwitchOn;
  final VoidCallback? onTap;

  const ProfileMenuTile({
    super.key,
    required this.item,
    required this.titleKey,
    this.languageSwitchOn = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(item.icon, size: 22.r, color: colors.primary),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                titleKey.tr(),
                style: AppTextStyles.white14bold.copyWith(
                  color: item.isDestructive ? colors.primary : colors.white,
                ),
              ),
            ),
            switch (item.trailing) {
              ProfileMenuTrailing.chevron => Icon(
                Icons.arrow_forward_ios,
                size: 14.r,
                color: colors.primary,
              ),
              ProfileMenuTrailing.languageSwitch => Switch(
                value: languageSwitchOn,
                onChanged: (_) => onTap?.call(),
                activeTrackColor: colors.primary,
                inactiveTrackColor: colors.grey,
              ),
            },
          ],
        ),
      ),
    );
  }
}
