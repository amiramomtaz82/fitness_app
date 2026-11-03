import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? difficultyLevel;
  final String? targetMuscleGroup;
  final String? primeMoverMuscle;
  final String? secondaryMuscle;
  final String? tertiaryMuscle;
  final String? primaryEquipment;
  final int? primaryItems;
  final String? secondaryEquipment;
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
  final String? demonstrationVideoUrl;
  final String? explanationVideoUrl;

  const ExerciseEntity({
    required this.id,
    required this.name,
    this.imageUrl,
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

  String? get videoUrl {
    final demonstration = _clean(demonstrationVideoUrl);
    if (demonstration != null) return demonstration;
    return _clean(explanationVideoUrl);
  }

  List<String> get muscleNames {
    return [
      targetMuscleGroup,
      primeMoverMuscle,
      secondaryMuscle,
      tertiaryMuscle,
    ].map(_clean).whereType<String>().toSet().toList();
  }

  List<String?> get movementPatterns {
    return [movementPattern1, movementPattern2, movementPattern3];
  }

  List<String?> get planesOfMotion {
    return [planeOfMotion1, planeOfMotion2, planeOfMotion3];
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    difficultyLevel,
    targetMuscleGroup,
    primeMoverMuscle,
    secondaryMuscle,
    tertiaryMuscle,
    primaryEquipment,
    primaryItems,
    secondaryEquipment,
    secondaryItems,
    posture,
    singleOrDoubleArm,
    continuousOrAlternatingArms,
    grip,
    loadPositionEnding,
    continuousOrAlternatingLegs,
    footElevation,
    combinationExercises,
    movementPattern1,
    movementPattern2,
    movementPattern3,
    planeOfMotion1,
    planeOfMotion2,
    planeOfMotion3,
    bodyRegion,
    forceType,
    mechanics,
    laterality,
    primaryExerciseClassification,
    demonstrationVideoUrl,
    explanationVideoUrl,
  ];
}
