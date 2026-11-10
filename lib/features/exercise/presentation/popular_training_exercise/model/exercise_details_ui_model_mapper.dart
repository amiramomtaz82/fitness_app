import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_section_data.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_ui_model.dart';
import 'package:fitness_app/features/exercise/presentation/utils/display_values.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

abstract final class ExerciseDetailsUiModelMapper {
  static ExerciseDetailsUiModel fromEntity(ExerciseEntity exercise) {
    final playUrl = DisplayValues.firstFilled([
      exercise.demonstrationVideoUrl,
      exercise.explanationVideoUrl,
    ]);

    return ExerciseDetailsUiModel(
      name: exercise.name,
      level: DisplayValues.text(exercise.difficultyLevel),
      equipment: DisplayValues.text(exercise.primaryEquipment),
      playUrl: playUrl,
      videoId: extractYoutubeVideoId(playUrl ?? ''),
      sections: [
        _musclesSection(exercise),
        _equipmentSection(exercise),
        _executionSection(exercise),
        _classificationSection(exercise),
        _videosSection(exercise),
      ],
    );
  }

  static ExerciseDetailsSectionData _musclesSection(ExerciseEntity exercise) {
    return ExerciseDetailsSectionData(
      titleKey: LocaleKeys.exercises_related_muscles,
      entries: [
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_target_muscle_group,
          value: DisplayValues.text(exercise.targetMuscleGroup),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_prime_mover_muscle,
          value: DisplayValues.text(exercise.primeMoverMuscle),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_secondary_muscle,
          value: DisplayValues.text(exercise.secondaryMuscle),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_tertiary_muscle,
          value: DisplayValues.text(exercise.tertiaryMuscle),
        ),
      ],
    );
  }

  static ExerciseDetailsSectionData _equipmentSection(ExerciseEntity exercise) {
    return ExerciseDetailsSectionData(
      titleKey: LocaleKeys.exercises_equipment,
      entries: [
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_primary_equipment,
          value: DisplayValues.text(exercise.primaryEquipment),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_primary_items,
          value: DisplayValues.number(exercise.primaryItems),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_secondary_equipment,
          value: DisplayValues.text(exercise.secondaryEquipment),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_secondary_items,
          value: DisplayValues.number(exercise.secondaryItems),
        ),
      ],
    );
  }

  static ExerciseDetailsSectionData _executionSection(ExerciseEntity exercise) {
    return ExerciseDetailsSectionData(
      titleKey: LocaleKeys.exercises_execution,
      entries: [
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_posture,
          value: DisplayValues.text(exercise.posture),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_single_or_double_arm,
          value: DisplayValues.text(exercise.singleOrDoubleArm),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_continuous_or_alternating_arms,
          value: DisplayValues.text(exercise.continuousOrAlternatingArms),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_grip,
          value: DisplayValues.text(exercise.grip),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_load_position_ending,
          value: DisplayValues.text(exercise.loadPositionEnding),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_continuous_or_alternating_legs,
          value: DisplayValues.text(exercise.continuousOrAlternatingLegs),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_foot_elevation,
          value: DisplayValues.text(exercise.footElevation),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_combination_exercises,
          value: DisplayValues.text(exercise.combinationExercises),
        ),
      ],
    );
  }

  static ExerciseDetailsSectionData _classificationSection(
    ExerciseEntity exercise,
  ) {
    return ExerciseDetailsSectionData(
      titleKey: LocaleKeys.exercises_classification,
      entries: [
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_movement_patterns,
          value: DisplayValues.joined(exercise.movementPatterns),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_planes_of_motion,
          value: DisplayValues.joined(exercise.planesOfMotion),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_body_region,
          value: DisplayValues.text(exercise.bodyRegion),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_force_type,
          value: DisplayValues.text(exercise.forceType),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_mechanics,
          value: DisplayValues.text(exercise.mechanics),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_laterality,
          value: DisplayValues.text(exercise.laterality),
        ),
        ExerciseDetailsTextEntry(
          labelKey: LocaleKeys.exercises_primary_exercise_classification,
          value: DisplayValues.text(exercise.primaryExerciseClassification),
        ),
      ],
    );
  }

  static ExerciseDetailsSectionData _videosSection(ExerciseEntity exercise) {
    return ExerciseDetailsSectionData(
      titleKey: LocaleKeys.exercises_videos,
      entries: [
        ExerciseDetailsVideoEntry(
          labelKey: LocaleKeys.exercises_video_demonstration,
          videoUrl: DisplayValues.text(exercise.demonstrationVideoUrl),
        ),
        ExerciseDetailsVideoEntry(
          labelKey: LocaleKeys.exercises_video_explanation,
          videoUrl: DisplayValues.text(exercise.explanationVideoUrl),
        ),
      ],
    );
  }
}
