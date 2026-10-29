import 'package:equatable/equatable.dart';

import 'meal_ingredient.dart';

class MealDetailsEntity extends Equatable {
  final String? id;
  final String? name;
  final String? thumbnailUrl;
  final String? instructions;
  final String? youtubeUrl;
  final List<MealIngredient> ingredients;

  const MealDetailsEntity({
    this.id,
    this.name,
    this.thumbnailUrl,
    this.instructions,
    this.youtubeUrl,
    this.ingredients = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    thumbnailUrl,
    instructions,
    youtubeUrl,
    ingredients,
  ];
}
