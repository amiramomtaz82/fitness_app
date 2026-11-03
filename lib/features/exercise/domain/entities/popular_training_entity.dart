import 'package:equatable/equatable.dart';

class PopularTrainingEntity extends Equatable {
  final String? primeMoverMuscleId;
  final String? difficultyLevelId;
  final String muscleName;
  final String levelName;
  final int exercisesCount;
  final String? imageUrl;

  const PopularTrainingEntity({
    this.primeMoverMuscleId,
    this.difficultyLevelId,
    required this.muscleName,
    required this.levelName,
    required this.exercisesCount,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    primeMoverMuscleId,
    difficultyLevelId,
    muscleName,
    levelName,
    exercisesCount,
    imageUrl,
  ];
}
