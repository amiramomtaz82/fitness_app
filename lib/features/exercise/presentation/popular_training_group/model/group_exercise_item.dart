import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/utils/display_values.dart';

class GroupExerciseItem extends Equatable {
  final ExerciseEntity exercise;
  final String name;
  final String? subtitle;
  final String? videoId;

  const GroupExerciseItem({
    required this.exercise,
    required this.name,
    this.subtitle,
    this.videoId,
  });

  factory GroupExerciseItem.from(ExerciseEntity exercise) {
    return GroupExerciseItem(
      exercise: exercise,
      name: exercise.name,
      subtitle: DisplayValues.firstFilled([
        exercise.primaryEquipment,
        exercise.difficultyLevel,
      ]),
      videoId: extractYoutubeVideoId(exercise.videoUrl ?? ''),
    );
  }

  @override
  List<Object?> get props => [exercise, name, subtitle, videoId];
}
