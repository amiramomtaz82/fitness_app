import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/error/failures.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../view_model/food_details_cubit.dart';
import 'food_details_back.dart';
import 'food_details_content.dart';
import 'food_details_media.dart';
import 'food_details_nutrition.dart';

class FoodDetailsStatus extends StatelessWidget {
  const FoodDetailsStatus({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final resource = context.watch<FoodDetailsCubit>().state.mealResource;
    final meal = resource.data;
    if (resource.isError) {
      return FoodDetailsBackLayer(
        onBack: onBack,
        child: FoodDetailsFailure(failure: resource.failure),
      );
    }
    if (resource.isSuccess && meal == null) {
      return FoodDetailsBackLayer(
        onBack: onBack,
        child: FoodDetailsMessage(
          message: LocaleKeys.errors_data_not_found.tr(),
        ),
      );
    }
    if (meal == null) {
      return FoodDetailsBackLayer(
        onBack: onBack,
        child: const FoodDetailsLoading(),
      );
    }
    return FoodDetailsAmbient(
      videoUrl: meal.youtubeUrl,
      thumbnailUrl: meal.thumbnailUrl,
      child: FoodDetailsContent(meal: meal, onBack: onBack),
    );
  }
}

class FoodDetailsFailure extends StatelessWidget {
  const FoodDetailsFailure({super.key, required this.failure});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final message = failure?.serverMessage;
    final text = message == null || message.isEmpty
        ? LocaleKeys.errors_something_went_wrong.tr()
        : message;
    return FoodDetailsMessage(message: text);
  }
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
    return DecoratedBox(decoration: foodAmbientDecoration);
  }
}

final foodAmbientDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      foodDetailsPanel.withValues(alpha: 0x80 / 0xFF),
      foodDetailsPanel.withValues(alpha: 0xE6 / 0xFF),
      foodDetailsPanel,
    ],
    stops: const [0.32, 0.62, 0.94],
  ),
);
