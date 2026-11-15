import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../generated/locale_keys.g.dart';

class OpenConversationsButton extends StatelessWidget {
  const OpenConversationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('open_previous_conversations'),
      tooltip: LocaleKeys.chat_previous_conversations.tr(),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: 24.r, height: 24.r),
      onPressed: () => Scaffold.of(context).openEndDrawer(),
      icon: Icon(Icons.sort, color: AppColors.orange, size: 24.r),
    );
  }
}
