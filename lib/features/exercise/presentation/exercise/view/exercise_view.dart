import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ExerciseView extends StatelessWidget {
  final String muscleId;
  const ExerciseView({super.key, required this.muscleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(color: AppColors.orange),
    );
  }
}
