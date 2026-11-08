import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';

class WorkoutState extends Equatable {
  final Resource<List<MuscleGroupEntity>> groupsResource;
  final MuscleGroupEntity? selectedGroup;
  final Resource<List<MuscleEntity>> musclesResource;

  const WorkoutState({
    this.groupsResource = const Resource.initial(),
    this.selectedGroup,
    this.musclesResource = const Resource.initial(),
  });

  WorkoutState copyWith({
    Resource<List<MuscleGroupEntity>>? groupsResource,
    MuscleGroupEntity? selectedGroup,
    Resource<List<MuscleEntity>>? musclesResource,
  }) {
    return WorkoutState(
      groupsResource: groupsResource ?? this.groupsResource,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      musclesResource: musclesResource ?? this.musclesResource,
    );
  }

  @override
  List<Object?> get props => [groupsResource, selectedGroup, musclesResource];
}
