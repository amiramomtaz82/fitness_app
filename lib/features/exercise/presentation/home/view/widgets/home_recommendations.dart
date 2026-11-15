import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_state.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/home_view_model/home_view_model.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_horizontal_section.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeRecommendations extends StatelessWidget {
  const HomeRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      buildWhen: (previous, current) =>
          previous.randomMusclesResource != current.randomMusclesResource,
      builder: (context, state) {
        return HomeHorizontalSection<MuscleEntity>(
          title: LocaleKeys.home_recommendation_to_day.tr(),
          resource: state.randomMusclesResource,
          getTitle: (muscle) => muscle.name,
          getImage: (muscle) => muscle.imageUrl,
        );
      },
    );
  }
}
