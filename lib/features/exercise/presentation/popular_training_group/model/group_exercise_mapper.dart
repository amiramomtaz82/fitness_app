import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/utils/display_values.dart';

abstract final class GroupExerciseMapper {
  GroupExerciseMapper._();

  static List<GroupExerciseItem> toItems(List<ExerciseEntity> exercises) {
    return exercises.map(GroupExerciseItem.from).toList();
  }

  static List<String> relatedMuscles(List<ExerciseEntity> exercises) {
    final muscles = <String>{};
    for (final exercise in exercises) {
      for (final muscle in exercise.muscleNames) {
        final displayName = DisplayValues.text(muscle);
        if (displayName != null) muscles.add(displayName);
      }
    }
    return muscles.toList();
  }
}
