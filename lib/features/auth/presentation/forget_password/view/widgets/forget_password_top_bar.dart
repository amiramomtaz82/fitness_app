import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgetPasswordTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const ForgetPasswordTopBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h, left: 16.w, right: 16.w),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: AppBackButton(
              key: const Key('backButton'),
              onTap: onBack,
            ),
          ),
          Center(
            child: Image.asset(
              AppAssets.logo,
              width: 85.w,
              height: 60.h,
            ),
          ),
        ],
      ),
    );
  }
}