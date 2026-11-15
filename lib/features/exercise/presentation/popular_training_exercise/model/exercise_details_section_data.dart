import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/model/exercise_details_entry.dart';

class ExerciseDetailsSectionData extends Equatable {
  final String titleKey;
  final List<ExerciseDetailsEntry> entries;

  const ExerciseDetailsSectionData({
    required this.titleKey,
    required this.entries,
  });

  @override
  List<Object?> get props => [titleKey, entries];
}
