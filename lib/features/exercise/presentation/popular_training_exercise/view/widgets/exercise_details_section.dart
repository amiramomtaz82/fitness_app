import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_section_data.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_details_row.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_video_tile.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseDetailsSection extends StatelessWidget {
  final ExerciseDetailsSectionData section;
  final ValueChanged<String> onVideoTap;

  const ExerciseDetailsSection({
    super.key,
    required this.section,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.titleKey.tr(), style: AppTextStyles.white14bold),
        SizedBox(height: 8.h),
        TranslucentCardList(
          children: section.entries.map(_buildEntry).toList(),
        ),
      ],
    );
  }

  Widget _buildEntry(ExerciseDetailsEntry entry) {
    return switch (entry) {
      ExerciseDetailsTextEntry(:final labelKey, :final value) =>
        ExerciseDetailsRow(labelKey: labelKey, value: value),
      ExerciseDetailsVideoEntry(:final labelKey, :final videoUrl) =>
        videoUrl == null
            ? ExerciseDetailsRow(labelKey: labelKey)
            : ExerciseVideoTile(
                labelKey: labelKey,
                onTap: () => onVideoTap(videoUrl),
              ),
    };
  }
}
