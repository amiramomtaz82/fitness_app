import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view/widgets/workout_muscles_grid.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view/widgets/workout_tabs_bar.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_cubit.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_intent.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkOutView extends StatelessWidget {
  const WorkOutView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<WorkoutCubit>()..doIntent(const InitWorkoutsIntent()),
      child: const _WorkOutViewBody(),
    );
  }
}

class _WorkOutViewBody extends StatefulWidget {
  const _WorkOutViewBody();

  @override
  State<_WorkOutViewBody> createState() => _WorkOutViewBodyState();
}

class _WorkOutViewBodyState extends State<_WorkOutViewBody>
    with UiEventMixin<_WorkOutViewBody, WorkoutState, BaseUiEvent> {
  @override
  BaseCubit<WorkoutState, BaseUiEvent> get cubit =>
      context.read<WorkoutCubit>();

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.workouts_workouts.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.white20bold,
          ),
          SizedBox(height: 16.h),
          const WorkoutTabsBar(),
          SizedBox(height: 16.h),
          const Expanded(child: WorkoutMusclesGrid()),
        ],
      ),
    );
  }
}
