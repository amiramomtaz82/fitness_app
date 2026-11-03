import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'exercise')
  final String? name;

  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;

  @JsonKey(name: 'target_muscle_group')
  final String? targetMuscleGroup;

  @JsonKey(name: 'prime_mover_muscle')
  final String? primeMoverMuscle;

  @JsonKey(name: 'secondary_muscle')
  final String? secondaryMuscle;

  @JsonKey(name: 'tertiary_muscle')
  final String? tertiaryMuscle;

  @JsonKey(name: 'primary_equipment')
  final String? primaryEquipment;

  @JsonKey(name: '_primary_items')
  final int? primaryItems;

  @JsonKey(name: 'secondary_equipment')
  final String? secondaryEquipment;

  @JsonKey(name: '_secondary_items')
  final int? secondaryItems;

  final String? posture;
  final String? singleOrDoubleArm;
  final String? continuousOrAlternatingArms;
  final String? grip;
  final String? loadPositionEnding;
  final String? continuousOrAlternatingLegs;
  final String? footElevation;
  final String? combinationExercises;
  final String? movementPattern1;
  final String? movementPattern2;
  final String? movementPattern3;
  final String? planeOfMotion1;
  final String? planeOfMotion2;
  final String? planeOfMotion3;
  final String? bodyRegion;
  final String? forceType;
  final String? mechanics;
  final String? laterality;
  final String? primaryExerciseClassification;

  @JsonKey(name: 'short_youtube_demonstration_link')
  final String? demonstrationVideoUrl;

  @JsonKey(name: 'in_depth_youtube_explanation_link')
  final String? explanationVideoUrl;

  const ExerciseModel({
    this.id,
    this.name,
    this.difficultyLevel,
    this.targetMuscleGroup,
    this.primeMoverMuscle,
    this.secondaryMuscle,
    this.tertiaryMuscle,
    this.primaryEquipment,
    this.primaryItems,
    this.secondaryEquipment,
    this.secondaryItems,
    this.posture,
    this.singleOrDoubleArm,
    this.continuousOrAlternatingArms,
    this.grip,
    this.loadPositionEnding,
    this.continuousOrAlternatingLegs,
    this.footElevation,
    this.combinationExercises,
    this.movementPattern1,
    this.movementPattern2,
    this.movementPattern3,
    this.planeOfMotion1,
    this.planeOfMotion2,
    this.planeOfMotion3,
    this.bodyRegion,
    this.forceType,
    this.mechanics,
    this.laterality,
    this.primaryExerciseClassification,
    this.demonstrationVideoUrl,
    this.explanationVideoUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id ?? '',
      name: name ?? '',
      difficultyLevel: difficultyLevel,
      targetMuscleGroup: targetMuscleGroup,
      primeMoverMuscle: primeMoverMuscle,
      secondaryMuscle: secondaryMuscle,
      tertiaryMuscle: tertiaryMuscle,
      primaryEquipment: primaryEquipment,
      primaryItems: primaryItems,
      secondaryEquipment: secondaryEquipment,
      secondaryItems: secondaryItems,
      posture: posture,
      singleOrDoubleArm: singleOrDoubleArm,
      continuousOrAlternatingArms: continuousOrAlternatingArms,
      grip: grip,
      loadPositionEnding: loadPositionEnding,
      continuousOrAlternatingLegs: continuousOrAlternatingLegs,
      footElevation: footElevation,
      combinationExercises: combinationExercises,
      movementPattern1: movementPattern1,
      movementPattern2: movementPattern2,
      movementPattern3: movementPattern3,
      planeOfMotion1: planeOfMotion1,
      planeOfMotion2: planeOfMotion2,
      planeOfMotion3: planeOfMotion3,
      bodyRegion: bodyRegion,
      forceType: forceType,
      mechanics: mechanics,
      laterality: laterality,
      primaryExerciseClassification: primaryExerciseClassification,
      demonstrationVideoUrl: demonstrationVideoUrl,
      explanationVideoUrl: explanationVideoUrl,
    );
  }
}
