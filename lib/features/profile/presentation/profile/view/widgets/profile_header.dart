import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileEntity? profile;
  final String? pickedPhotoPath;
  final VoidCallback? onPickPhoto;

  const ProfileHeader({
    super.key,
    this.profile,
    this.pickedPhotoPath,
    this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          photoUrl: profile?.photoUrl,
          pickedPhotoPath: pickedPhotoPath,
          onTap: onPickPhoto,
        ),
        SizedBox(height: 14.h),
        Text(
          profile?.fullName ?? '',
          style: AppTextStyles.white20bold,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
