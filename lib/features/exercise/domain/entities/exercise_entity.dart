import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? difficultyLevel;

  const ExerciseEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.difficultyLevel,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, difficultyLevel];
}
