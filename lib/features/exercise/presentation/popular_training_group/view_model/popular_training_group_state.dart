import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';

class PopularTrainingGroupState extends Equatable {
  final PopularTrainingEntity? training;
  final Resource<List<GroupExerciseItem>> exercisesResource;
  final List<String> relatedMuscles;
  final int exercisesCount;
  final String? heroImageUrl;

  const PopularTrainingGroupState({
    this.training,
    this.exercisesResource = const Resource.initial(),
    this.relatedMuscles = const [],
    this.exercisesCount = 0,
    this.heroImageUrl,
  });

  PopularTrainingGroupState copyWith({
    PopularTrainingEntity? training,
    Resource<List<GroupExerciseItem>>? exercisesResource,
    List<String>? relatedMuscles,
    int? exercisesCount,
    String? heroImageUrl,
  }) {
    return PopularTrainingGroupState(
      training: training ?? this.training,
      exercisesResource: exercisesResource ?? this.exercisesResource,
      relatedMuscles: relatedMuscles ?? this.relatedMuscles,
      exercisesCount: exercisesCount ?? this.exercisesCount,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
    );
  }

  @override
  List<Object?> get props => [
    training,
    exercisesResource,
    relatedMuscles,
    exercisesCount,
    heroImageUrl,
  ];
}
