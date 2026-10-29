import 'package:equatable/equatable.dart';

import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/meal_details_entity.dart';

class FoodDetailsState extends Equatable {
  final Resource<MealDetailsEntity> mealResource;
  final bool isMealNotFound;

  const FoodDetailsState({
    this.mealResource = const Resource.initial(),
    this.isMealNotFound = false,
  });

  FoodDetailsState copyWith({
    Resource<MealDetailsEntity>? mealResource,
    bool? isMealNotFound,
  }) {
    return FoodDetailsState(
      mealResource: mealResource ?? this.mealResource,
      isMealNotFound: isMealNotFound ?? this.isMealNotFound,
    );
  }

  @override
  List<Object?> get props => [mealResource, isMealNotFound];
}
