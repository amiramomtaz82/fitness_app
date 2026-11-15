import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsetsDirectional.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildIcon(),
            SizedBox(height: 16.h),
            _buildTitle(context),
            SizedBox(height: 12.h),
            _buildMessage(context),
            SizedBox(height: 24.h),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.logout_rounded, color: AppColors.error, size: 28.sp),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      LocaleKeys.profile_logout.tr(context: context),
      style: AppTextStyles.white20bold,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      LocaleKeys.profile_are_you_sure_close_app.tr(context: context),
      style: AppTextStyles.grey14bold,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCancelButton(context)),
        SizedBox(width: 12.w),
        Expanded(child: _buildConfirmButton(context)),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        side: const BorderSide(color: AppColors.darkGrey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      onPressed: onCancel,
      child: Text(
        LocaleKeys.profile_no.tr(context: context),
        style: AppTextStyles.white14bold,
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      onPressed: onConfirm,
      child: Text(
        LocaleKeys.profile_yes.tr(context: context),
        style: AppTextStyles.white14bold,
      ),
    );
  }
}
