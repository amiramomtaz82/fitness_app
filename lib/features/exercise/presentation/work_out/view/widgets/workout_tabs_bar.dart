import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_cubit.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_intent.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutTabsBar extends StatelessWidget {
  const WorkoutTabsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) =>
          prev.selectedGroup != curr.selectedGroup ||
          prev.groupsResource != curr.groupsResource,
      builder: (context, state) {
        return switch (state.groupsResource.status) {
          ApiStatus.initial => const SizedBox.shrink(),
          ApiStatus.loading => SizedBox(
              height: 33.h,
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ApiStatus.error => const _WorkoutTabsErrorState(),
          ApiStatus.success => _WorkoutTabsContent(state: state),
        };
      },
    );
  }
}

class _WorkoutTabsContent extends StatelessWidget {
  final WorkoutState state;

  const _WorkoutTabsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final groups = state.groupsResource.data ?? <MuscleGroupEntity>[];
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIndex = groups.indexOf(
      state.selectedGroup ?? groups.first,
    );

    return AppCategoryTabBar(
      categories: groups.map((g) => g.name).toList(),
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onCategorySelected: (index) {
        context.read<WorkoutCubit>().doIntent(
          SelectMuscleGroupIntent(groups[index]),
        );
      },
    );
  }
}

class _WorkoutTabsErrorState extends StatelessWidget {
  const _WorkoutTabsErrorState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33.h,
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            context.read<WorkoutCubit>().doIntent(
              const InitWorkoutsIntent(),
            );
          },
          icon: Icon(
            Icons.refresh,
            size: 16.sp,
            color: context.colors.primary,
          ),
          label: Text(
            LocaleKeys.common_retry.tr(),
            style: AppTextStyles.white14regular,
          ),
        ),
      ),
    );
  }
}
