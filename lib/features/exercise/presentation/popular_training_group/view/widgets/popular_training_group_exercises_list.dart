import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercise_rows.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingGroupExercisesList extends StatelessWidget {
  final Resource<List<GroupExerciseItem>> resource;
  final ValueChanged<GroupExerciseItem> onItemTap;
  final VoidCallback? onRetry;

  const PopularTrainingGroupExercisesList({
    super.key,
    required this.resource,
    required this.onItemTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (resource.status) {
      ApiStatus.initial => const SizedBox.shrink(),
      ApiStatus.loading => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      ApiStatus.error => Column(
        children: [
          Text(
            LocaleKeys.errors_something_went_wrong.tr(),
            style: AppTextStyles.white14regular,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: onRetry,
            child: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      ),
      ApiStatus.success => PopularTrainingGroupExerciseRows(
        items: resource.data ?? const [],
        onItemTap: onItemTap,
      ),
    };
  }
}
