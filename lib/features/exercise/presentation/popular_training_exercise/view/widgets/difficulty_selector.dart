import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:flutter/material.dart';

class DifficultySelector extends StatelessWidget {
  final List<String> levels;
  final String selected;
  final ValueChanged<String> onChanged;

  const DifficultySelector({
    super.key,
    required this.levels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCategoryTabBar(
      categories: levels,
      selectedIndex: levels.indexOf(selected),
      onCategorySelected: (index) => onChanged(levels[index]),
    );
  }
}
