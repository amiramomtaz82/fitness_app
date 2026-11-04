import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'avatar_photo.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? pickedPhotoPath;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.pickedPhotoPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const diameter = 96.0;

    return GestureDetector(
      key: const Key('profileAvatar'),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: diameter.w,
            height: diameter.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: AvatarPhoto(localPath: pickedPhotoPath, url: photoUrl),
            ),
          ),
          Positioned(
            right: -2.w,
            bottom: -2.w,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit, size: 14.w, color: colors.white),
            ),
          ),
          if (pickedPhotoPath != null)
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
