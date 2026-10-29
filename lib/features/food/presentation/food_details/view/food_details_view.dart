import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/contants/app_assets.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../../../../core/widgets/app_background_scaffold.dart';
import '../view_model/food_details_cubit.dart';
import '../view_model/food_details_intent.dart';
import '../view_model/food_details_state.dart';
import 'widgets/food_details_nutrition.dart';
import 'widgets/food_details_status.dart';

class FoodDetailsView extends StatelessWidget {
  const FoodDetailsView({super.key, required this.mealId});

  final String mealId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FoodDetailsCubit>(),
      child: FoodDetailsScreen(mealId: mealId),
    );
  }
}

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key, required this.mealId});

  final String mealId;

  @override
  State<FoodDetailsScreen> createState() => FoodDetailsScreenState();
}

class FoodDetailsScreenState extends State<FoodDetailsScreen>
    with UiEventMixin<FoodDetailsScreen, FoodDetailsState, BaseUiEvent> {
  @override
  BaseCubit<FoodDetailsState, BaseUiEvent> get cubit =>
      context.read<FoodDetailsCubit>();

  @override
  void initState() {
    super.initState();
    requestMeal();
  }

  void requestMeal() {
    context.read<FoodDetailsCubit>().doIntent(
      LoadMealDetailsIntent(widget.mealId),
    );
  }

  void popFoodDetails() {
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      backgroundImage: AppAssets.foodBG,
      safeArea: false,
      overlayColor: foodDetailsPanel,
      overlayOpacity: 1,
      child: FoodDetailsStatus(onBack: popFoodDetails),
    );
  }
}
