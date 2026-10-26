import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBarItems extends StatelessWidget {
  final BottomItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomBarItems({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 50.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: AppColors.grey,
                    end: isSelected ? AppColors.orange : AppColors.grey,
                  ),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, color, child) {
                    return Image.asset(
                      item.icon,
                      width: 26.r,
                      height: 26.r,
                      fit: BoxFit.contain,
                      color: color,
                    );
                  },
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: isSelected
                    ? AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            item.label.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.orange12regular.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
