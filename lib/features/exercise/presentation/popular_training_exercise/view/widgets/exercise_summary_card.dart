import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_play_button.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:flutter/material.dart';

class ExerciseSummaryCard extends StatelessWidget {
  final String name;
  final String? equipment;
  final String? videoId;
  final VoidCallback? onPlay;

  const ExerciseSummaryCard({
    super.key,
    required this.name,
    this.equipment,
    this.videoId,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return TranslucentCardList(
      children: [
        ExerciseItemCard(
          name: name,
          subtitle: equipment,
          videoId: videoId,
          trailing: ExercisePlayButton(onTap: onPlay),
        ),
      ],
    );
  }
}
