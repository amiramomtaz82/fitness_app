import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlayButton extends StatelessWidget {
  final VoidCallback onPlay;

  const PlayButton({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPlay,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: colors.white,
          size: 22.sp,
        ),
      ),
    );
  }
}
