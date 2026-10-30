import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_content_grid_view.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_cubit.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_intent.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutMusclesGrid extends StatelessWidget {
  const WorkoutMusclesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        final resource = state.musclesResource;

        return switch (resource.status) {
          ApiStatus.initial => const SizedBox.shrink(),
          ApiStatus.loading =>
            const Center(child: CircularProgressIndicator.adaptive()),
          ApiStatus.error => const _WorkoutGridErrorState(),
          ApiStatus.success => _WorkoutMusclesContent(
              muscles: resource.data ?? const <MuscleEntity>[],
            ),
        };
      },
    );
  }
}

class _WorkoutMusclesContent extends StatelessWidget {
  final List<MuscleEntity> muscles;

  const _WorkoutMusclesContent({required this.muscles});

  @override
  Widget build(BuildContext context) {
    if (muscles.isEmpty) {
      return const _WorkoutGridEmptyState();
    }

    final items = muscles
        .map(
          (m) => ContentCardItem(
            id: m.id,
            title: m.name,
            imageUrl: m.imageUrl,
          ),
        )
        .toList();

    return AppContentGridView(
      items: items,
      onItemTap: (item) {
        context.read<WorkoutCubit>().doIntent(
          MuscleSelectedIntent(item.id),
        );
      },
    );
  }
}

class _WorkoutGridEmptyState extends StatelessWidget {
  const _WorkoutGridEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LocaleKeys.workouts_no_muscles_found.tr(),
        style: AppTextStyles.white14regular,
      ),
    );
  }
}

class _WorkoutGridErrorState extends StatelessWidget {
  const _WorkoutGridErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.errors_something_went_wrong.tr(),
            style: AppTextStyles.white14regular,
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () {
              context.read<WorkoutCubit>().doIntent(
                const RetryFetchMusclesIntent(),
              );
            },
            child: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      ),
    );
  }
}
