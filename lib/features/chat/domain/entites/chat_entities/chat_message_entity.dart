import 'package:equatable/equatable.dart';
import '../catalog_entities/exercise_card_entity.dart';
import '../catalog_entities/meal_card_entity.dart';

enum ChatSender { user, coach }

class ChatMessageEntity extends Equatable {
  final String id;
  final ChatSender sender;
  final String text;
  final DateTime createdAt;
  final List<ExerciseCardEntity> exercises;
  final List<MealCardEntity> meals;
  final bool isPending;

  const ChatMessageEntity({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.exercises = const [],
    this.meals = const [],
    this.isPending = false,
  });

  @override
  List<Object?> get props => [id, sender, text, createdAt, exercises, meals, isPending];
}