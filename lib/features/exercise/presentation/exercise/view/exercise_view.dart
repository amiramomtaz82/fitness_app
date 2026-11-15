import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/core/widgets/app_youtube_video.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/widgets/exercise_Top_section.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/widgets/exercise_bottom_container.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_intent.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_state.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_view_model.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ExerciseView extends StatefulWidget {
  final String muscleId;
  final String? muscleName;

  const ExerciseView({super.key, required this.muscleId, this.muscleName});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  StreamSubscription<BaseUiEvent>? _eventSubscription;
  ExerciseEntity? _selectedExercise;
  String? _playingExerciseId;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ExerciseDetailsCubit>();
    _eventSubscription = cubit.eventStream.listen(_handleUiEvent);
    cubit.doIntent(
      LoadExerciseDetailsIntent(widget.muscleId, muscleName: widget.muscleName),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleUiEvent(BaseUiEvent event) {
    if (!mounted) return;
    if (event is ShowErrorSnackBarEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.failure.message ?? 'Something went wrong'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  /// The YouTube link the API sent for [exercise], short demo first.
  ///
  /// A link only counts when it yields a playable YouTube id, otherwise the
  /// explanation link is used and finally `null` when nothing is playable.
  String? _getVideoUrl(ExerciseEntity? exercise) {
    if (exercise == null) return null;
    for (final url in [exercise.shortVideoUrl, exercise.explanationVideoUrl]) {
      final trimmed = url.trim();
      if (extractYoutubeVideoId(trimmed) != null) return trimmed;
    }
    return null;
  }

  ExerciseEntity? _currentExercise(ExerciseDetailsState state) {
    final exercises = state.exercisesList;
    if (exercises.isEmpty) return null;
    final selectedId = _selectedExercise?.id;
    if (selectedId != null) {
      for (final exercise in exercises) {
        if (exercise.id == selectedId) return exercise;
      }
    }
    return exercises.first;
  }

  void _playExerciseVideo(ExerciseEntity exercise) {
    if (_getVideoUrl(exercise) == null) {
      _showVideoUnavailable();
      return;
    }
    setState(() {
      _selectedExercise = exercise;
      _playingExerciseId = exercise.id;
    });
  }

  void _showVideoUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleKeys.exercises_video_unavailable.tr()),
        backgroundColor: context.colors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<ExerciseDetailsCubit, ExerciseDetailsState>(
        builder: (context, state) {
          final cubit = context.read<ExerciseDetailsCubit>();
          final muscleName = widget.muscleName ?? 'Chest';

          // Current active exercise
          final currentExercise = _currentExercise(state);
          final currentVideoUrl = _getVideoUrl(currentExercise);
          final extractedVideoId = currentVideoUrl == null
              ? null
              : extractYoutubeVideoId(currentVideoUrl);
          final isPlayingVideo =
              _playingExerciseId != null &&
              _playingExerciseId == currentExercise?.id &&
              extractedVideoId != null;

          // Dynamic calculation for Time & Calories based on exercises count
          final exerciseCount = state.totalExercises > 0
              ? state.totalExercises
              : state.exercisesList.length;
          final totalMinutes = exerciseCount > 0
              ? (exerciseCount == 1 ? 30 : exerciseCount * 6)
              : 30;
          final totalCalories = exerciseCount > 0
              ? (exerciseCount == 1 ? 130 : exerciseCount * 26)
              : 130;

          // Dynamic description
          String headerDescription =
              'Lorem Ipsum Dolor Sit Amet Consectetur. Tempus Volutpat Ut Nisi Morbi.';
          if (currentExercise != null) {
            final equipment = currentExercise.primaryEquipment?.trim() ?? '';
            final primeMover = currentExercise.primeMoverMuscle?.trim() ?? '';
            final target = currentExercise.targetMuscleGroup?.trim() ?? '';
            final eq = equipment.isNotEmpty ? equipment : 'Bodyweight';
            final pm = primeMover.isNotEmpty ? primeMover : target;
            headerDescription =
                '$eq • $pm • ${currentExercise.difficultyLevel ?? ''}';
          }

          final headerTitle = '$muscleName Exercise';

          // Difficulty levels tabs data
          final categories = state.difficultyLevelsList.isNotEmpty
              ? state.difficultyLevelsList.map((d) => d.name).toList()
              : const ['Beginner', 'Intermediate', 'Advanced'];
          final selectedIndex = state.difficultyLevelsList.isNotEmpty
              ? state.difficultyLevelsList.indexWhere(
                  (d) => d.id == state.selectedDifficultyId,
                )
              : 0;
          final effectiveIndex = selectedIndex >= 0 ? selectedIndex : 0;
          return Column(
            children: [
              // Top Section: Live In-Screen Video Player OR Hero Section
              if (isPlayingVideo)
                SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: AppYoutubeVideo(
                          key: ValueKey(currentVideoUrl),
                          videoUrl: currentVideoUrl!,
                          autoPlay: true,
                          showBackButton: true,
                          onBack: () =>
                              setState(() => _playingExerciseId = null),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentExercise?.name ?? headerTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppCategoryTabBar(
                        categories: categories,
                        selectedIndex: effectiveIndex,
                        onCategorySelected: (index) {
                          if (index >= 0 &&
                              index < state.difficultyLevelsList.length) {
                            final level = state.difficultyLevelsList[index];
                            cubit.doIntent(SelectDifficultyIntent(level.id));
                          }
                        },
                      ),
                      SizedBox(height: 6.h),
                    ],
                  ),
                )
              else
                ExerciseTopSection(
                  videoId: extractedVideoId,
                  muscleName: muscleName,
                  title: headerTitle,
                  description: headerDescription,
                  timeText: '$totalMinutes MIN',
                  caloriesText: '$totalCalories',
                  difficultyLevels: state.difficultyLevelsList,
                  selectedDifficultyId: state.selectedDifficultyId,
                  onCategorySelected: (index) {
                    if (index >= 0 &&
                        index < state.difficultyLevelsList.length) {
                      final level = state.difficultyLevelsList[index];
                      cubit.doIntent(SelectDifficultyIntent(level.id));
                    }
                  },
                  onBack: () => context.pop(),
                  onPlayVideo: currentExercise == null
                      ? null
                      : () => _playExerciseVideo(currentExercise),
                ),

              // Bottom Section: Custom Container with Exercise List
              Expanded(
                child: ExerciseBottomContainer(
                  exercises: state.exercisesList,
                  activeExerciseId: currentExercise?.id,
                  isLoading: state.exercises.isLoading,
                  isError:
                      state.difficultyLevels.isError ||
                      (state.exercises.isError && state.exercisesList.isEmpty),
                  errorMessage:
                      state.exercises.failure?.message ??
                      state.difficultyLevels.failure?.message,
                  hasMore: state.hasMorePages,
                  onRetry: () =>
                      cubit.doIntent(const RetryExerciseDetailsIntent()),
                  onLoadMore: () =>
                      cubit.doIntent(const LoadMoreExercisesIntent()),
                  onPlayExercise: _playExerciseVideo,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
