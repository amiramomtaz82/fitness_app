import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/difficulty_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LevelsBar extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;

  const LevelsBar({
    super.key,
    required this.levels,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w , vertical: 11.h),
      child: DifficultySelector(
        levels: levels,
        selected: selectedLevel,
        onChanged: onLevelSelected,
      ),
    );
  }
}
