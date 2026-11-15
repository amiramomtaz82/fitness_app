import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/exercise_view.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view_model/exercise_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExerciseScreen extends StatelessWidget {
  final String? muscleId;
  final String? muscleName;

  const ExerciseScreen({super.key, this.muscleId, this.muscleName});

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final resolvedMuscleId =
        muscleId ?? routerState.pathParameters['muscleId'] ?? '';
    final resolvedMuscleName =
        muscleName ?? routerState.uri.queryParameters['muscle'] ?? 'Chest';

    try {
      context.read<ExerciseDetailsCubit>();
      return ExerciseView(
        muscleId: resolvedMuscleId,
        muscleName: resolvedMuscleName,
      );
    } catch (_) {
      return BlocProvider(
        create: (_) => getIt<ExerciseDetailsCubit>(),
        child: ExerciseView(
          muscleId: resolvedMuscleId,
          muscleName: resolvedMuscleName,
        ),
      );
    }
  }
}
