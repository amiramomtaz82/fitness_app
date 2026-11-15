import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String difficultyLevel;
  final String targetMuscleGroup;
  final String primeMoverMuscle;
  final String primaryEquipment;
  final String shortVideoUrl;
  final String explanationVideoUrl;

  final String? secondaryMuscle;
  final String? tertiaryMuscle;
  final String? posture;
  final String? mechanics;
  final String? bodyRegion;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.difficultyLevel,
    required this.targetMuscleGroup,
    required this.primeMoverMuscle,
    required this.primaryEquipment,
    required this.shortVideoUrl,
    required this.explanationVideoUrl,
    this.secondaryMuscle,
    this.tertiaryMuscle,
    this.posture,
    this.mechanics,
    this.bodyRegion,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    difficultyLevel,
    targetMuscleGroup,
    primeMoverMuscle,
    primaryEquipment,
    shortVideoUrl,
    explanationVideoUrl,
    secondaryMuscle,
    tertiaryMuscle,
    mechanics,
    posture,
    bodyRegion,
  ];
}
