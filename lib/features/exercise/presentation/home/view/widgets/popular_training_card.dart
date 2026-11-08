import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int tasksCount;
  final String levelName;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const PopularTrainingCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.tasksCount,
    required this.levelName,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: imageUrl.startsWith('assets/')
                  ? AssetImage(imageUrl)
                  : NetworkImage(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: colors.card,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.grey,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.white14bold,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          LocaleKeys.home_tasks.tr(args: ['$tasksCount']),
                          style: AppTextStyles.white14regular.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Text(
                        levelName,
                        style: AppTextStyles.darkOrange14Bold.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
