import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_ui_model.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_ui_model_mapper.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_details_section.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_summary_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_hero.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_video_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PopularTrainingExerciseView extends StatefulWidget {
  final ExerciseEntity exercise;

  const PopularTrainingExerciseView({super.key, required this.exercise});

  @override
  State<PopularTrainingExerciseView> createState() =>
      _PopularTrainingExerciseViewState();
}

class _PopularTrainingExerciseViewState
    extends State<PopularTrainingExerciseView> {
  late ExerciseDetailsUiModel _details;

  @override
  void initState() {
    super.initState();
    _details = ExerciseDetailsUiModelMapper.fromEntity(widget.exercise);
  }

  @override
  void didUpdateWidget(covariant PopularTrainingExerciseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise != widget.exercise) {
      _details = ExerciseDetailsUiModelMapper.fromEntity(widget.exercise);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    final playUrl = details.playUrl;

    return AppBackgroundScaffold(
      safeAreaTop: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExerciseHero(
            height: 440.h,
            background: ExerciseVideoImage(videoId: details.videoId),
            title: details.name,
            subtitle: details.level,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ExerciseSummaryCard(
                    name: details.name,
                    equipment: details.equipment,
                    videoId: details.videoId,
                    onPlay: playUrl == null
                        ? null
                        : () => context.push(
                            AppRoutes.exerciseVideo,
                            extra: playUrl,
                          ),
                  ),
                  for (final section in details.sections) ...[
                    SizedBox(height: 24.h),
                    ExerciseDetailsSection(
                      section: section,
                      onVideoTap: (videoUrl) => context.push(
                        AppRoutes.exerciseVideo,
                        extra: videoUrl,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
