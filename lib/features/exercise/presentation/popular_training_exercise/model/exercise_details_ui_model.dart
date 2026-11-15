import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_section_data.dart';

class ExerciseDetailsUiModel extends Equatable {
  final String name;
  final String? level;
  final String? equipment;
  final String? playUrl;
  final String? videoId;
  final List<ExerciseDetailsSectionData> sections;

  const ExerciseDetailsUiModel({
    required this.name,
    this.level,
    this.equipment,
    this.playUrl,
    this.videoId,
    required this.sections,
  });

  @override
  List<Object?> get props => [
    name,
    level,
    equipment,
    playUrl,
    videoId,
    sections,
  ];
}
