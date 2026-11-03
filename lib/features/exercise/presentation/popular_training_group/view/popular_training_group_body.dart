import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/core/widgets/app_source_image.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercises_list.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_muscles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_stats.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_state.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_hero.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PopularTrainingGroupBody extends StatefulWidget {
  const PopularTrainingGroupBody({super.key});

  @override
  State<PopularTrainingGroupBody> createState() =>
      _PopularTrainingGroupBodyState();
}

class _PopularTrainingGroupBodyState extends State<PopularTrainingGroupBody>
    with
        UiEventMixin<
          PopularTrainingGroupBody,
          PopularTrainingGroupState,
          BaseUiEvent
        > {
  @override
  BaseCubit<PopularTrainingGroupState, BaseUiEvent> get cubit =>
      context.read<PopularTrainingGroupViewModel>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      PopularTrainingGroupViewModel,
      PopularTrainingGroupState
    >(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final training = state.training;
        if (training == null) return const SizedBox.shrink();

        return AppBackgroundScaffold(
          safeAreaTop: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExerciseHero(
                height: 280.h,
                background: AppSourceImage(source: state.heroImageUrl),
                title: LocaleKeys.exercises_group_title.tr(
                  args: [training.muscleName],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PopularTrainingGroupStats(
                        exercisesCount: state.exercisesCount,
                        levelName: training.levelName,
                        muscleName: training.muscleName,
                      ),
                      SizedBox(height: 24.h),
                      PopularTrainingGroupMuscles(
                        muscleNames: state.relatedMuscles,
                      ),
                      SizedBox(height: 24.h),
                      PopularTrainingGroupExercisesList(
                        resource: state.exercisesResource,
                        onItemTap: _onExerciseTap,
                        onRetry: _retry,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onExerciseTap(GroupExerciseItem item) {
    context.push(AppRoutes.popularTrainingExercise, extra: item.exercise);
  }

  void _retry() {
    context.read<PopularTrainingGroupViewModel>().doIntent(
      const RetryPopularTrainingGroupIntent(),
    );
  }
}
