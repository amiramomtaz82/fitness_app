import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/popular_training_group_body.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_intent.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view_model/popular_training_group_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PopularTrainingGroupView extends StatelessWidget {
  final PopularTrainingEntity training;

  const PopularTrainingGroupView({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PopularTrainingGroupViewModel>()
            ..doIntent(InitPopularTrainingGroupIntent(training)),
      child: const PopularTrainingGroupBody(),
    );
  }
}
