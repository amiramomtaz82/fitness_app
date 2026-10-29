import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_categories.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ const HomeHeader(),
          SizedBox(height: 28.h),
          const HomeCategories(),
        
        ],
      ),
    );
  }
}
