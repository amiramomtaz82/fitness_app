import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';

const kYoutubeUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
const kYoutubeId = 'dQw4w9WgXcQ';

const kExercise = ExerciseEntity(
  id: 'e_1',
  name: 'Bench Press',
  difficultyLevel: 'Beginner',
  primaryEquipment: 'Barbell',
  demonstrationVideoUrl: kYoutubeUrl,
);

const kExerciseWithoutVideo = ExerciseEntity(
  id: 'e_2',
  name: 'Squat',
  difficultyLevel: 'Intermediate',
);

const kExerciseItem = GroupExerciseItem(
  exercise: kExercise,
  name: 'Bench Press',
  subtitle: 'Barbell',
  videoId: kYoutubeId,
);

const kExerciseItemWithoutVideo = GroupExerciseItem(
  exercise: kExerciseWithoutVideo,
  name: 'Squat',
  subtitle: 'Intermediate',
);

const kTraining = PopularTrainingEntity(
  primeMoverMuscleId: 'pm_1',
  difficultyLevelId: 'dl_1',
  muscleName: 'Chest',
  levelName: 'Beginner',
  exercisesCount: 3,
  imageUrl: 'https://cdn.test/chest.png',
);
