import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/popular_training_dummy_data.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'widgets/popular_training_exercise_list.dart';
import 'widgets/popular_training_hero.dart';

class PopularTrainingExerciseView extends StatefulWidget {
  final String exerciseId;

  const PopularTrainingExerciseView({super.key, required this.exerciseId});

  @override
  State<PopularTrainingExerciseView> createState() =>
      _PopularTrainingExerciseViewState();
}

class _PopularTrainingExerciseViewState
    extends State<PopularTrainingExerciseView> {
  final List<ExerciseEntity> _exercises = PopularTrainingDummyData.exercises;
  late final List<String> _levels;
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _levels = _exercises
        .map((e) => e.difficultyLevel)
        .whereType<String>()
        .toSet()
        .toList();
    _selectedLevel = _levels.isEmpty ? '' : _levels.first;
  }

  List<ExerciseEntity> get _visibleExercises =>
      _exercises.where((e) => e.difficultyLevel == _selectedLevel).toList();

  String get _title {
    final muscle = _exercises.isEmpty
        ? null
        : _exercises.first.targetMuscleGroup;
    if (muscle == null || muscle.isEmpty) return '';
    return '$muscle ${LocaleKeys.exercises_exercise.tr()}';
  }

  String? get _heroVideoId => _exercises.isEmpty
      ? null
      : extractYoutubeVideoId(
          _exercises.first.shortYoutubeDemonstrationLink ?? '',
        );

  void _onPlay(ExerciseEntity exercise) {
    final url = exercise.shortYoutubeDemonstrationLink ?? '';
    if (url.isEmpty) return;
    context.push(AppRoutes.exerciseVideo, extra: url);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      safeAreaTop: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PopularTrainingHero(
            backgroundVideoId: _heroVideoId,
            title: _title,
            levels: _levels,
            selectedLevel: _selectedLevel,
            onLevelSelected: (level) => setState(() => _selectedLevel = level),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: PopularTrainingExerciseList(
              exercises: _visibleExercises,
              onPlay: _onPlay,
            ),
          ),
        ],
      ),
    );
  }
}
