import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';

class HomeState extends Equatable {
  final Resource<List<MuscleGroupEntity>> groupsResource;
  final Resource<List<MuscleEntity>> randomMusclesResource;
  final Resource<List<MuscleEntity>> groupMusclesResource;
  final Resource<List<MealCategoryEntity>> mealCategoriesResource;
  final Resource<List<PopularTrainingEntity>> popularTrainingResource;
  final int selectedGroupIndex;

  const HomeState({
    this.groupsResource = const Resource.initial(),
    this.randomMusclesResource = const Resource.initial(),
    this.groupMusclesResource = const Resource.initial(),
    this.mealCategoriesResource = const Resource.initial(),
    this.popularTrainingResource = const Resource.initial(),
    this.selectedGroupIndex = 0,
  });

  HomeState copyWith({
    Resource<List<MuscleGroupEntity>>? groupsResource,
    Resource<List<MuscleEntity>>? randomMusclesResource,
    Resource<List<MuscleEntity>>? groupMusclesResource,
    Resource<List<MealCategoryEntity>>? mealCategoriesResource,
    Resource<List<PopularTrainingEntity>>? popularTrainingResource,
    int? selectedGroupIndex,
  }) {
    return HomeState(
      groupsResource: groupsResource ?? this.groupsResource,
      randomMusclesResource:
          randomMusclesResource ?? this.randomMusclesResource,
      groupMusclesResource: groupMusclesResource ?? this.groupMusclesResource,
      mealCategoriesResource:
          mealCategoriesResource ?? this.mealCategoriesResource,
      popularTrainingResource:
          popularTrainingResource ?? this.popularTrainingResource,
      selectedGroupIndex: selectedGroupIndex ?? this.selectedGroupIndex,
    );
  }

  @override
  List<Object?> get props => [
    groupsResource,
    randomMusclesResource,
    groupMusclesResource,
    mealCategoriesResource,
    popularTrainingResource,
    selectedGroupIndex,
  ];
}
