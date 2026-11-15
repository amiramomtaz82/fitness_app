import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class BottomItem {
  final String icon;
  final String label;
  final String? pushRoute;

  const BottomItem({required this.icon, required this.label, this.pushRoute});

  bool get opensFullScreen => pushRoute != null;
}

const List<BottomItem> items = [
  BottomItem(icon: AppAssets.home, label: LocaleKeys.home_home),
  BottomItem(
    icon: AppAssets.chat,
    label: LocaleKeys.chat_smart_coach,
    pushRoute: AppRoutes.smartCoach,
  ),
  BottomItem(icon: AppAssets.exercise, label: LocaleKeys.workouts_workouts),
  BottomItem(icon: AppAssets.person, label: LocaleKeys.profile_profile),
];

final List<int> branchTabIndexes = [
  for (var i = 0; i < items.length; i++)
    if (!items[i].opensFullScreen) i,
];
