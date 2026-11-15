import 'package:equatable/equatable.dart';

class ExerciseCardEntity extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? muscleGroup;
  final String? difficulty;
  final String? demoUrl;

  const ExerciseCardEntity({
    required this.id,
    required this.name,
    this.nameAr,
    this.muscleGroup,
    this.difficulty,
    this.demoUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    nameAr,
    muscleGroup,
    difficulty,
    demoUrl,
  ];
}
