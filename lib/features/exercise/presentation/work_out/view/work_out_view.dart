import 'package:fitness_app/app/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkOutView extends StatelessWidget {
  const WorkOutView({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.pushNamed(
          AppRoutes.exerciseDetails,
          pathParameters: {
            'muscleId': '69d982ed85f6bfa972bf2220',
          },
          queryParameters: {
            'muscle': 'Chest',
          },
        );
      },
      child: const Text('Exercises'),
    );
  }
}