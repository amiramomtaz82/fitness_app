import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(image: AppAssets.gym, titleKey: LocaleKeys.home_gym),
    _CategoryItem(image: AppAssets.fitness, titleKey: LocaleKeys.home_fitness),
    _CategoryItem(image: AppAssets.yoga, titleKey: LocaleKeys.home_yoga),
    _CategoryItem(
      image: AppAssets.aerobics,
      titleKey: LocaleKeys.home_aerobics,
    ),
    _CategoryItem(image: AppAssets.trainer, titleKey: LocaleKeys.home_trainer),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.home_category.tr(),
          style: AppTextStyles.white20bold.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 112.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final category = _categories[index];

              return SizedBox(
                width: 64.w,
                child: Column(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        category.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.fitness_center,
                            color: AppColors.orange,
                            size: 28.sp,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      category.titleKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.grey12regular.copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem {
  const _CategoryItem({required this.image, required this.titleKey});

  final String image;
  final String titleKey;
}
