import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppContentCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const AppContentCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CardBackgroundImage(imageUrl: imageUrl),
              _CardBlurredTitle(title: title),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBackgroundImage extends StatelessWidget {
  final String imageUrl;

  const _CardBackgroundImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _CardPlaceholder(),
      );
    }
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _CardPlaceholder(),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.card,
      alignment: AlignmentDirectional.center,
      child: Icon(Icons.image_outlined, color: colors.grey, size: 32.r),
    );
  }
}

class _CardBlurredTitle extends StatelessWidget {
  final String title;

  const _CardBlurredTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: 0,
      end: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(12.w, 24.h, 12.w, 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: 0.75),
            ],
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.white20bold.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
