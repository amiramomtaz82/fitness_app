import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../profile/presentation/profile/view/widgets/avatar_photo.dart';
import '../../../domain/entites/chat_entities/chat_message_entity.dart';
import 'coach_avatar.dart';
import 'coach_recommendations.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final String? userPhotoUrl;

  const ChatBubble({super.key, required this.message, this.userPhotoUrl});

  @override
  Widget build(BuildContext context) {
    if (message.sender == ChatSender.user) {
      return Opacity(
        opacity: message.isPending ? 0.6 : 1,
        child: _UserBubble(text: message.text, photoUrl: userPhotoUrl),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CoachTextBubble(text: message.text),
        if (message.exercises.isNotEmpty || message.meals.isNotEmpty) ...[
          SizedBox(height: 8.h),
          CoachRecommendations(
            exercises: message.exercises,
            meals: message.meals,
          ),
        ],
      ],
    );
  }
}

class CoachTextBubble extends StatelessWidget {
  final String text;

  const CoachTextBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CoachAvatar(),
        SizedBox(width: 8.w),
        Flexible(
          child: _BubbleBody(
            text: text,
            color: AppColors.surface.withValues(alpha: 0.85),
            tailAtStart: true,
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final String? photoUrl;

  const _UserBubble({required this.text, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 40.w),
        Flexible(
          child: _BubbleBody(
            text: text,
            color: AppColors.orange.withValues(alpha: 0.55),
            tailAtStart: false,
          ),
        ),
        SizedBox(width: 8.w),
        ClipOval(
          child: SizedBox(
            width: 32.r,
            height: 32.r,
            child: AvatarPhoto(url: photoUrl),
          ),
        ),
      ],
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final String text;
  final Color color;
  final bool tailAtStart;

  const _BubbleBody({
    required this.text,
    required this.color,
    required this.tailAtStart,
  });

  @override
  Widget build(BuildContext context) {
    final big = Radius.circular(16.r);
    final small = Radius.circular(4.r);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadiusDirectional.only(
          topStart: tailAtStart ? small : big,
          topEnd: tailAtStart ? big : small,
          bottomStart: big,
          bottomEnd: big,
        ),
      ),
      child: Text(text, style: AppTextStyles.white14regular),
    );
  }
}
