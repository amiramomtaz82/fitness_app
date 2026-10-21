import 'package:fitness_app/core/contants/app_assets.dart';
 

class BottomItem {
    final String icon;
  final String label;

  const BottomItem({
    required this.icon,
    required this.label,
  });
}
 
 const List<BottomItem> items = [
    BottomItem(
      icon: AppAssets.home,
      label: 'Explore',
    ),
    BottomItem(
      icon: AppAssets.chat,
      label: 'Chat',
    ),
    BottomItem(
      icon: AppAssets.exercise,
      label: 'Workouts',
    ),
    BottomItem(
      icon: AppAssets.person,
      label: 'Profile',
    ),
  ];