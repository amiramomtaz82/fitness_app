import 'package:equatable/equatable.dart';

class PopularTrainingEntity extends Equatable {
  final String muscleName;
  final String levelName;
  final int exercisesCount;
  final String? imageUrl;

  const PopularTrainingEntity({
    required this.muscleName,
    required this.levelName,
    required this.exercisesCount,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [muscleName, levelName, exercisesCount, imageUrl];
}
