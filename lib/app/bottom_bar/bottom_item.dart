import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class BottomItem {
  final String icon;
  final String label;

  const BottomItem({required this.icon, required this.label});
}

final List<BottomItem> items = [
  BottomItem(icon: AppAssets.home, label: LocaleKeys.home.tr()),
   BottomItem(icon: AppAssets.chat, label: LocaleKeys.chat_smart_coach.tr()),
   BottomItem(icon: AppAssets.exercise, label: LocaleKeys.workouts.tr()),
   BottomItem(icon: AppAssets.person, label: LocaleKeys.profile.tr()),
];
