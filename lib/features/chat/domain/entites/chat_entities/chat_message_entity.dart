import 'package:equatable/equatable.dart';
import '../catalog_entities/exercise_card_entity.dart';
import '../catalog_entities/meal_card_entity.dart';

enum ChatSender { user, coach }

class ChatMessageEntity extends Equatable {
  final String id;
  final ChatSender sender;
  final String text;
  final DateTime createdAt;
  final List<String> exerciseRefs; // ✅ IDs stored in Firestore
  final List<String> mealRefs;     // ✅ IDs stored in Firestore
  final List<ExerciseCardEntity> exercises;
  final List<MealCardEntity> meals;
  final bool isPending;

  const ChatMessageEntity({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.exerciseRefs = const [],
    this.mealRefs = const [],
    this.exercises = const [],
    this.meals = const [],
    this.isPending = false,
  });

  ChatMessageEntity copyWith({
    List<ExerciseCardEntity>? exercises,
    List<MealCardEntity>? meals,
    bool? isPending,
  }) {
    return ChatMessageEntity(
      id: id,
      sender: sender,
      text: text,
      createdAt: createdAt,
      exerciseRefs: exerciseRefs,
      mealRefs: mealRefs,
      exercises: exercises ?? this.exercises,
      meals: meals ?? this.meals,
      isPending: isPending ?? this.isPending,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sender,
    text,
    createdAt,
    exerciseRefs,
    mealRefs,
    exercises,
    meals,
    isPending,
  ];
}