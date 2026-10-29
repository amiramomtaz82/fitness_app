import 'package:equatable/equatable.dart';

class MealIngredient extends Equatable {
  final String name;
  final String? measure;

  const MealIngredient({required this.name, this.measure});

  @override
  List<Object?> get props => [name, measure];
}
