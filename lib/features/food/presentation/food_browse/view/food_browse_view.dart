import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/contants/app_assets.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/widgets/app_background_scaffold.dart';
import '../view_model/food_browse_cubit.dart';
import '../view_model/food_browse_intent.dart';
import 'widgets/food_browse_body.dart';

class FoodBrowseView extends StatelessWidget {
  const FoodBrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FoodBrowseCubit>(),
      child: const FoodBrowseScreen(),
    );
  }
}

class FoodBrowseScreen extends StatefulWidget {
  const FoodBrowseScreen({super.key});

  @override
  State<FoodBrowseScreen> createState() => FoodBrowseScreenState();
}

class FoodBrowseScreenState extends State<FoodBrowseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FoodBrowseCubit>().doIntent(const LoadFoodBrowseIntent());
  }

  @override
  Widget build(BuildContext context) {
    return const AppBackgroundScaffold(
      backgroundImage: AppAssets.foodBG,
      child: FoodBrowseBody(),
    );
  }
}
