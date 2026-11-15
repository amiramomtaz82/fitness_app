import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/locale_keys.g.dart';

class FoodDetailsBackLayer extends StatelessWidget {
  const FoodDetailsBackLayer({
    super.key,
    required this.onBack,
    required this.child,
  });

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        PositionedDirectional(
          top: MediaQuery.paddingOf(context).top + 16.h,
          start: 16.w,
          child: FoodDetailsBackButton(onPressed: onBack),
        ),
      ],
    );
  }
}

class FoodDetailsBackButton extends StatelessWidget {
  const FoodDetailsBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: LocaleKeys.common_back.tr(),
      child: FoodDetailsBackDisc(onPressed: onPressed),
    );
  }
}

class FoodDetailsBackDisc extends StatelessWidget {
  const FoodDetailsBackDisc({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.orange,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: FoodDetailsBackTap(onPressed: onPressed),
    );
  }
}

class FoodDetailsBackTap extends StatelessWidget {
  const FoodDetailsBackTap({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44.r,
        height: 44.r,
        child: const FoodDetailsBackIcon(),
      ),
    );
  }
}

class FoodDetailsBackIcon extends StatelessWidget {
  const FoodDetailsBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 16.r);
  }
}
