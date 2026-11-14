import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscle_groups_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_by_group_id_use_case.dart';
import 'package:injectable/injectable.dart';
import '../../../../../app/routes_names.dart';
import 'workout_intent.dart';
import 'workout_state.dart';

@injectable
class WorkoutCubit extends BaseCubit<WorkoutState, BaseUiEvent> {
  final GetMuscleGroupsUseCase _getMuscleGroupsUseCase;
  final GetMusclesByGroupIdUseCase _getMusclesByGroupIdUseCase;

  WorkoutCubit(this._getMuscleGroupsUseCase, this._getMusclesByGroupIdUseCase)
    : super(const WorkoutState());

  void doIntent(WorkoutIntent intent) {
    switch (intent) {
      case InitWorkoutsIntent():
        _initialize();
      case SelectMuscleGroupIntent(group: final group):
        _onGroupSelected(group);
      case RetryFetchMusclesIntent():
        _retry();
      case MuscleSelectedIntent(muscleId: final id):
        emitEvent(NavigateEvent(AppRoutes.exercise, arguments: id));
    }
  }

  Future<void> _initialize() async {
    emit(state.copyWith(groupsResource: const Resource.loading()));
    final response = await _getMuscleGroupsUseCase();
    switch (response) {
      case SuccessResponse<List<MuscleGroupEntity>>(data: final groups):
        emit(state.copyWith(groupsResource: Resource.success(groups)));
        if (groups.isNotEmpty) {
          _onGroupSelected(groups.first);
        }
      case ErrorResponse<List<MuscleGroupEntity>>(failure: final failure):
        emit(state.copyWith(groupsResource: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  void _onGroupSelected(MuscleGroupEntity group) {
    if (state.selectedGroup == group && state.musclesResource.isSuccess) {
      return;
    }
    emit(state.copyWith(selectedGroup: group));
    _fetchMusclesForGroup(group.id);
  }

  Future<void> _fetchMusclesForGroup(String groupId) async {
    emit(state.copyWith(musclesResource: const Resource.loading()));
    final response = await _getMusclesByGroupIdUseCase(groupId);
    switch (response) {
      case SuccessResponse<List<MuscleEntity>>(data: final list):
        emit(state.copyWith(musclesResource: Resource.success(list)));
      case ErrorResponse<List<MuscleEntity>>(failure: final failure):
        emit(state.copyWith(musclesResource: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  void _retry() {
    if (state.groupsResource.isError) {
      _initialize();
    } else if (state.selectedGroup != null) {
      _fetchMusclesForGroup(state.selectedGroup!.id);
    }
  }
}
