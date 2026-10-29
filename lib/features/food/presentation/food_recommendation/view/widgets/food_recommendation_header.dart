import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../core/widgets/app_back_button.dart';
import '../../../../../../generated/locale_keys.g.dart';

class FoodRecommendationHeader extends StatelessWidget {
  const FoodRecommendationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          const AppBackButton(key: Key('foodBackBtn')),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              LocaleKeys.food_food_recommendation.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.white20bold.copyWith(fontSize: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
