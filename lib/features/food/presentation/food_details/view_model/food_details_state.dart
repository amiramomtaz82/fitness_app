import 'package:equatable/equatable.dart';

import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/meal_details_entity.dart';

class FoodDetailsState extends Equatable {
  final Resource<MealDetailsEntity> mealResource;

  const FoodDetailsState({this.mealResource = const Resource.initial()});

  FoodDetailsState copyWith({Resource<MealDetailsEntity>? mealResource}) {
    return FoodDetailsState(mealResource: mealResource ?? this.mealResource);
  }

  @override
  List<Object?> get props => [mealResource];
}
