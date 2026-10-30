import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/domain/entities/popular_training_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/popular_training_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePopularTraining extends StatelessWidget {
  const HomePopularTraining({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      buildWhen: (previous, current) =>
          previous.popularTrainingResource != current.popularTrainingResource,
      builder: (context, state) {
        final resource = state.popularTrainingResource;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.home_popular_training.tr(),
              style: AppTextStyles.white20bold,
            ),
            SizedBox(height: 16.h),
            switch (resource.status) {
              ApiStatus.initial => const SizedBox.shrink(),
              ApiStatus.loading => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              ApiStatus.error => Center(
                child: Text(LocaleKeys.errors_something_went_wrong.tr()),
              ),
              ApiStatus.success => _buildList(
                (resource.data ?? []).whereType<PopularTrainingEntity>().toList(),
              ),
            },
          ],
        );
      },
    );
  }

  Widget _buildList(List<PopularTrainingEntity> trainings) {
    if (trainings.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trainings.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final training = trainings[index];

          return PopularTrainingCard(
            title: training.muscleName,
            imageUrl: training.imageUrl ?? '',
            tasksCount: training.exercisesCount,
            levelName: training.levelName,
            width: 220.w,
            height: 150.h,
            onTap: () {
              // TODO: navigation
            },
          );
        },
      ),
    );
  }
}
