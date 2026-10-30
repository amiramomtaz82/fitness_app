import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/homa_image_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHorizontalSection<T> extends StatelessWidget {
  final String title;
  final Resource<List<T>> resource;
  final String Function(T item) getTitle;
  final String Function(T item) getImage;
  final VoidCallback? onSeeAllTap;
  final void Function(T item)? onItemTap; 

  const HomeHorizontalSection({
    super.key,
    required this.title,
    required this.resource,
    required this.getTitle,
    required this.getImage,
    this.onSeeAllTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.white20bold),
            if (onSeeAllTap != null)
              TextButton(
                onPressed: onSeeAllTap,
                child: Text(
                  LocaleKeys.home_see_all
                      .tr(), 
                  style: TextStyle(color: Colors.orange, fontSize: 14.sp),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        switch (resource.status) {
          ApiStatus.initial => const SizedBox.shrink(),
          ApiStatus.loading => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          ApiStatus.error => Center(
            child: Text(LocaleKeys.errors_something_went_wrong.tr()),
          ),
          ApiStatus.success => _buildList(resource.data ?? []),
        },
      ],
    );
  }

  Widget _buildList(List<T> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 125.h, // تعديل الارتفاع ليتطابق مع تصميم فيجما
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = items[index];
          return HomeImageCard(
            title: getTitle(item),
            imageUrl: getImage(item),
            width: 135
                .w, 
            height: 125.h,
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
          );
        },
      ),
    );
  }
}
