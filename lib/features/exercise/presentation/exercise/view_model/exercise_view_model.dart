import 'dart:developer';

import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_result_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscles_group_entity.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_difficlulty_levels_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_exercise_use_case.dart';
import 'package:fitness_app/features/exercise/domain/use_cases/get_muscles_group_use_case.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_intent.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExerciseDetailsCubit
    extends BaseCubit<ExerciseDetailsState, BaseUiEvent> {
  final GetExercisesUseCase _getExercisesUseCase;
  final GetDifficultyLevelsUseCase _getDifficultyLevelsUseCase;
  final GetMuscleGroupsUseCase _getMuscleGroupsUseCase;
  String? _muscleId;
  String? _muscleName;
  int _exerciseRequestId = 0;

  ExerciseDetailsCubit(
    this._getExercisesUseCase,
    this._getDifficultyLevelsUseCase, {
    GetMuscleGroupsUseCase? getMuscleGroupsUseCase,
  })  : _getMuscleGroupsUseCase =
            getMuscleGroupsUseCase ?? getIt<GetMuscleGroupsUseCase>(),
        super(const ExerciseDetailsState());

  void doIntent(ExerciseDetailsIntent intent) {
    switch (intent) {
      case LoadExerciseDetailsIntent(:final muscleId, :final muscleName):
        _loadInitialData(muscleId, muscleName: muscleName);
      case SelectDifficultyIntent(:final difficultyId):
        _selectDifficulty(difficultyId);
      case LoadMoreExercisesIntent():
        _loadMoreExercises();
      case RetryExerciseDetailsIntent():
        _retry();
      case RefreshExercisesIntent():
        _refreshExercises();
    }
  }

  Future<void> _loadInitialData(String muscleId, {String? muscleName}) async {
    log('========== MUSCLE DEBUG ==========');
    log('Received muscleId: $muscleId, muscleName: $muscleName');
    log('==================================');

    if (state.difficultyLevels.isLoading) return;
    _muscleName = muscleName;

    // Check if muscleId is a valid 24-character hexadecimal MongoDB ObjectId
    final isObjectId = RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(muscleId);
    String resolvedMuscleId = muscleId;

    if (!isObjectId) {
      // Resolve muscle ID from the backend muscles group API
      final groupsResult = await _getMuscleGroupsUseCase();
      if (groupsResult is SuccessResponse<List<MuscleGroupEntity>>) {
        final groups = groupsResult.data;
        if (groups.isNotEmpty) {
          final target = (muscleName != null && muscleName.isNotEmpty)
              ? muscleName.toLowerCase()
              : muscleId.toLowerCase();
          final match = groups.firstWhere(
            (g) => g.name.toLowerCase() == target,
            orElse: () => groups.firstWhere(
              (g) => g.id == muscleId,
              orElse: () => groups.first,
            ),
          );
          resolvedMuscleId = match.id;
        }
      }
    }

    _muscleId = resolvedMuscleId;
    await _loadDifficultyLevels();
    if (!state.difficultyLevels.isSuccess) return;
    final levels = state.difficultyLevelsList;
    if (levels.isEmpty) {
      emit(
        state.copyWith(
          exercises: const Resource.success(
            ExercisesResultEntity(
              totalExercises: 0,
              totalPages: 0,
              currentPage: 1,
              exercises: [],
            ),
          ),
        ),
      );
      return;
    }
    final beginnerLevels = levels.where(
      (level) => level.name.toLowerCase() == 'beginner',
    );
    final defaultLevel = beginnerLevels.isNotEmpty
        ? beginnerLevels.first
        : levels.first;
    emit(state.copyWith(selectedDifficultyId: defaultLevel.id));
    await _loadExercises(difficultyId: defaultLevel.id, page: 1, reset: true);
    log('Difficulty status: ${state.difficultyLevels.status}');
log('Difficulty count: ${state.difficultyLevelsList.length}');
log('Selected difficulty: ${defaultLevel.id}');
  }

  Future<void> _loadDifficultyLevels() async {
    final muscleId = _muscleId ?? '';
    if (muscleId.isEmpty) return;
    if (state.difficultyLevels.isLoading) return;
    emit(state.copyWith(difficultyLevels: const Resource.loading()));
    final result = await _getDifficultyLevelsUseCase(muscleId: muscleId);
    switch (result) {
      case SuccessResponse(:final data):
        emit(state.copyWith(difficultyLevels: Resource.success(data)));
      case ErrorResponse(:final failure):
        emit(state.copyWith(difficultyLevels: Resource.error(failure)));
        emitFailure(failure);
    }
    
  }

  Future<void> _selectDifficulty(String difficultyId) async {
    final isValid = state.difficultyLevelsList.any(
      (level) => level.id == difficultyId,
    );
    if (!isValid || difficultyId == state.selectedDifficultyId) {
      return;
    }
    _exerciseRequestId++;
    emit(
      state.copyWith(
        selectedDifficultyId: difficultyId,
        exercises: const Resource.loading(),
      ),
    );
    await _loadExercises(difficultyId: difficultyId, page: 1, reset: true);
  }

  Future<void> _loadExercises({
    required String difficultyId,
    required int page,
    required bool reset,
  }) async {
    final muscleId = _muscleId;
    if (muscleId == null || muscleId.isEmpty) return;
    final oldData = state.exercises.data;
    final requestId = ++_exerciseRequestId;
    emit(
      state.copyWith(exercises: Resource.loading(data: reset ? null : oldData)),
    );
    final result = await _getExercisesUseCase(
      muscleId: muscleId,
      difficultyId: difficultyId,
      page: page,
    );
    if (requestId != _exerciseRequestId ||
        difficultyId != state.selectedDifficultyId) {
      return;
    }
    switch (result) {
      case SuccessResponse(:final data):
        final updatedExercises = reset
            ? data.exercises
            : [...?oldData?.exercises, ...data.exercises];
        final updatedResult = ExercisesResultEntity(
          totalExercises: data.totalExercises,
          totalPages: data.totalPages,
          currentPage: data.currentPage,
          exercises: updatedExercises,
        );
        emit(state.copyWith(exercises: Resource.success(updatedResult)));
      case ErrorResponse(:final failure):
        emit(state.copyWith(exercises: Resource.error(failure, data: oldData)));
        emitFailure(failure);
    }
  }

  Future<void> _loadMoreExercises() async {
    if (state.exercises.isLoading ||
        !state.exercises.isSuccess ||
        !state.hasMorePages ||
        state.selectedDifficultyId == null) {
      return;
    }
    await _loadExercises(
      difficultyId: state.selectedDifficultyId!,
      page: state.currentPage + 1,
      reset: false,
    );
  }

  Future<void> _refreshExercises() async {
    final difficultyId = state.selectedDifficultyId;
    if (difficultyId == null || state.exercises.isLoading) {
      return;
    }
    await _loadExercises(difficultyId: difficultyId, page: 1, reset: true);
  }

  Future<void> _retry() {
    if (state.difficultyLevels.isError || state.difficultyLevels.isInitial) {
      return _loadInitialData(_muscleId ?? '', muscleName: _muscleName);
    }
    if (state.exercises.isError || state.exercises.isInitial) {
      final difficultyId = state.selectedDifficultyId;
      if (difficultyId != null) {
        return _loadExercises(difficultyId: difficultyId, page: 1, reset: true);
      }
    }
    return Future.value();
  }
}
