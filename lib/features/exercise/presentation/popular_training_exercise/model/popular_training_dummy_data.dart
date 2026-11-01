import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';

class PopularTrainingDummyData {
  const PopularTrainingDummyData._();

  static const List<ExerciseEntity> exercises = [
    ExerciseEntity(
      id: 'ex_1',
      exercise: 'Bench Press',
      difficultyLevel: 'Beginner',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Chest',
      primaryEquipment: 'Barbell',
      shortYoutubeDemonstrationLink: 'https://youtu.be/rT7DgCr-3pg',
    ),
    ExerciseEntity(
      id: 'ex_2',
      exercise: 'Incline Press',
      difficultyLevel: 'Beginner',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Upper Chest',
      primaryEquipment: 'Dumbbell',
      shortYoutubeDemonstrationLink: 'https://youtu.be/8iPEnn-ltC8',
    ),
    ExerciseEntity(
      id: 'ex_3',
      exercise: 'Chest Fly',
      difficultyLevel: 'Beginner',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Chest',
      primaryEquipment: 'Cable',
      shortYoutubeDemonstrationLink: 'https://youtu.be/PRw7ieDBLl4',
    ),
    ExerciseEntity(
      id: 'ex_4',
      exercise: 'Cable Crossover',
      difficultyLevel: 'Intermediate',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Chest',
      primaryEquipment: 'Cable',
      shortYoutubeDemonstrationLink: 'https://youtu.be/taI4XduLpTk',
    ),
    ExerciseEntity(
      id: 'ex_5',
      exercise: 'Dumbbell Pullover',
      difficultyLevel: 'Intermediate',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Serratus Anterior',
      primaryEquipment: 'Dumbbell',
      shortYoutubeDemonstrationLink: 'https://youtu.be/FK4rHfWKEac',
    ),
    ExerciseEntity(
      id: 'ex_6',
      exercise: 'Planche Push Up',
      difficultyLevel: 'Advanced',
      targetMuscleGroup: 'Chest',
      primeMoverMuscle: 'Chest',
      primaryEquipment: 'Body Only',
      shortYoutubeDemonstrationLink: 'https://youtu.be/A9tJDvRcqjE',
    ),
  ];
}
