import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeImageCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const HomeImageCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: colors.card,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: imageUrl.startsWith('assets/')
                  ? AssetImage(imageUrl)
                  : NetworkImage(imageUrl) as ImageProvider,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
                child: Text(
                  title,
                  maxLines:
                      1, //
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.white14bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
