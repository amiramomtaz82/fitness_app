import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/cubit/workout_cubit.dart';
import '../../manager/cubit/workout_intent.dart';
import '../../manager/cubit/workout_state.dart';

class WorkoutTabsBar extends StatelessWidget {
  const WorkoutTabsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      buildWhen: (prev, curr) =>
      prev.selectedGroup != curr.selectedGroup ||
          prev.groupsResource != curr.groupsResource,
      builder: (context, state) {
        final groups = state.groupsResource.data ?? <MuscleGroupEntity>[];
        if (groups.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedIndex = groups.indexOf(state.selectedGroup ?? groups.first);

        return AppCategoryTabBar(
          categories: groups.map((g) => g.name).toList(),
          selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
          onCategorySelected: (index) {
            context.read<WorkoutCubit>().doIntent(
              SelectMuscleGroupIntent(groups[index]),
            );
          },
        );
      },
    );
  }
}