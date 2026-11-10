import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_chevron.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingGroupExerciseRows extends StatelessWidget {
  final List<GroupExerciseItem> items;
  final ValueChanged<GroupExerciseItem> onItemTap;

  const PopularTrainingGroupExerciseRows({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Text(
          LocaleKeys.exercises_no_exercises_found.tr(),
          style: AppTextStyles.white14regular,
          textAlign: TextAlign.center,
        ),
      );
    }

    return TranslucentCardList(
      children: [
        for (final item in items)
          ExerciseItemCard(
            name: item.name,
            subtitle: item.subtitle,
            videoId: item.videoId,
            trailing: const ExerciseChevron(),
            onTap: () => onItemTap(item),
          ),
      ],
    );
  }
}
