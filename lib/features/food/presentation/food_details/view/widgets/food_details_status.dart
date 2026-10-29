import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../view_model/food_details_cubit.dart';
import '../../view_model/food_details_state.dart';
import 'food_details_back.dart';
import 'food_details_content.dart';
import 'food_details_media.dart';
import 'food_details_nutrition.dart';

class FoodDetailsStatus extends StatelessWidget {
  const FoodDetailsStatus({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FoodDetailsCubit>().state;
    final page = foodDetailsPage(state, onBack);
    if (showsMeal(state)) return mealAmbient(state, page);
    return FoodDetailsBackLayer(onBack: onBack, child: page);
  }
}

Widget mealAmbient(FoodDetailsState state, Widget page) {
  final meal = state.mealResource.data;
  return FoodDetailsAmbient(
    videoUrl: meal?.youtubeUrl,
    thumbnailUrl: meal?.thumbnailUrl,
    child: page,
  );
}

bool showsMeal(FoodDetailsState state) {
  return state.mealResource.isSuccess && state.mealResource.data != null;
}

Widget foodDetailsPage(FoodDetailsState state, VoidCallback onBack) {
  if (state.isMealNotFound || emptyMeal(state)) return missingMealMessage();
  if (state.mealResource.isError) return failureMessage(state);
  final meal = state.mealResource.data;
  if (meal == null || !state.mealResource.isSuccess) {
    return const FoodDetailsLoading();
  }
  return FoodDetailsContent(meal: meal, onBack: onBack);
}

bool emptyMeal(FoodDetailsState state) {
  return state.mealResource.isSuccess && state.mealResource.data == null;
}

Widget missingMealMessage() {
  return FoodDetailsMessage(message: LocaleKeys.errors_data_not_found.tr());
}

Widget failureMessage(FoodDetailsState state) {
  return FoodDetailsMessage(
    message: foodDetailsFailureText(state.mealResource.failure),
  );
}

String foodDetailsFailureText(Failure? failure) {
  final message = failure?.serverMessage;
  if (message != null && message.isNotEmpty) return message;
  return LocaleKeys.errors_something_went_wrong.tr();
}

class FoodDetailsLoading extends StatelessWidget {
  const FoodDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.orange),
    );
  }
}

class FoodDetailsMessage extends StatelessWidget {
  const FoodDetailsMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: FoodDetailsMessageText(message: message));
  }
}

class FoodDetailsMessageText extends StatelessWidget {
  const FoodDetailsMessageText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: foodMessageStyle(context),
      ),
    );
  }
}

TextStyle foodMessageStyle(BuildContext context) {
  final style = context.textTheme.bodyLarge ?? const TextStyle();
  return style.copyWith(color: AppColors.white);
}

class FoodDetailsAmbient extends StatelessWidget {
  const FoodDetailsAmbient({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.child,
  });

  final String? videoUrl;
  final String? thumbnailUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FoodDetailsPhoto(
          image: foodBackdropImage(videoUrl, thumbnailUrl),
          blurred: true,
        ),
        const FoodDetailsAmbientScrim(),
        child,
      ],
    );
  }
}

class FoodDetailsAmbientScrim extends StatelessWidget {
  const FoodDetailsAmbientScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(decoration: foodAmbientDecoration);
  }
}

const foodAmbientDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x80242424), Color(0xE6242424), foodDetailsPanel],
    stops: [0.32, 0.62, 0.94],
  ),
);
