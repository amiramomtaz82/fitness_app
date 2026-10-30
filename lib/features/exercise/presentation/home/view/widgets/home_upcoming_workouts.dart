import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_intent.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/homa_image_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeUpcomingWorkouts extends StatelessWidget {
  const HomeUpcomingWorkouts({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      buildWhen: (previous, current) =>
          previous.groupsResource != current.groupsResource ||
          previous.selectedGroupIndex != current.selectedGroupIndex ||
          previous.groupMusclesResource != current.groupMusclesResource,
      builder: (context, state) {
        final groups = state.groupsResource.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.home_upcoming_workouts.tr(),
                  style: AppTextStyles.white20bold,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    LocaleKeys.home_see_all.tr(),
                    style: TextStyle(color: Colors.orange, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            if (state.groupsResource.isLoading)
              const Center(child: CircularProgressIndicator.adaptive())
            else if (groups.isNotEmpty) ...[
              AppCategoryTabBar(
                categories: groups.map((group) => group.name).toList(),
                selectedIndex: state.selectedGroupIndex,
                onCategorySelected: (index) {
                  context.read<HomeViewModel>().doIntent(
                    SelectMuscleGroupIntent(index),
                  );
                },
              ),
              SizedBox(height: 16.h),
              _buildMusclesContent(state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMusclesContent(HomeState state) {
    final resource = state.groupMusclesResource;

    switch (resource.status) {
      case ApiStatus.initial:
        return const SizedBox.shrink();

      case ApiStatus.loading:
        return const Center(child: CircularProgressIndicator.adaptive());

      case ApiStatus.error:
        return Center(child: Text(LocaleKeys.errors_something_went_wrong.tr()));

      case ApiStatus.success:
        final muscles = resource.data ?? <MuscleEntity>[];

        if (muscles.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 125.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: muscles.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final muscle = muscles[index];

              return HomeImageCard(
                title: muscle.name,
                imageUrl: muscle.imageUrl,
                width: 135.w,
                height: 125.h,
                onTap: () {
                  // TODO: navigation
                },
              );
            },
          ),
        );
    }
  }
}
