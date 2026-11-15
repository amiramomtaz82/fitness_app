import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_categories.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_header.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_meal_categories.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_popular_training.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_recommendations.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_upcoming_workouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          SizedBox(height: 28.h),

          const HomeCategories(),
          SizedBox(height: 28.h),

          const HomeRecommendations(),
          SizedBox(height: 28.h),

          const HomeUpcomingWorkouts(),
          SizedBox(height: 28.h),

          const HomeMealCategories(),
          SizedBox(height: 28.h),

          const HomePopularTraining(),
        ],
      ),
    );
  }
}
