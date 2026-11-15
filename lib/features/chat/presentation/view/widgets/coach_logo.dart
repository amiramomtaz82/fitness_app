import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/contants/app_assets.dart';

class CoachLogo extends StatelessWidget {
  const CoachLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.logo, width: 24.r, height: 24.r);
  }
}
