
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class BottomItem {
  final String icon;
  final String label;

  const BottomItem({
    required this.icon,
    required this.label,
  });
}

final List<BottomItem> items = [
   const BottomItem(
    icon: AppAssets.home,
    label: 'home.home', 
  ),
 const BottomItem(
    icon: AppAssets.chat,
    label: 'chat.smart_coach',
  ),
 const BottomItem(
    icon: AppAssets.exercise,
    label: 'workouts.workouts',
  ),
 const BottomItem(
    icon: AppAssets.person,
    label: 'profile.profile',
  ),
];
