import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class BottomItem {
  final String icon;
  final String label;

  const BottomItem({required this.icon, required this.label});
}

const List<BottomItem> items = [
  BottomItem(icon: AppAssets.home, label: LocaleKeys.home),
  BottomItem(icon: AppAssets.chat, label: LocaleKeys.chat_smart_coach),
  BottomItem(icon: AppAssets.exercise, label: LocaleKeys.workouts),
  BottomItem(icon: AppAssets.person, label: LocaleKeys.profile),
];
