import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBackgroundScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final String? backgroundImage;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  // === Per-Feature Overlay Customization ===
  final Color overlayColor;
  final double overlayOpacity;
  final Gradient? overlayGradient;

  // === Per-Feature Layout Grid Guide (Debug Mode) ===
  final bool showLayoutGrid;
  final Color? gridColor;
  final int gridColumns;

  const AppBackgroundScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.backgroundImage,
    this.overlayColor = AppColors.black,
    this.overlayOpacity = 0.6,
    this.overlayGradient,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
    this.showLayoutGrid = false,
    this.gridColor,
    this.gridColumns = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          AppBackgroundImage(image: backgroundImage),
          AppBackgroundOverlay(
            color: overlayColor,
            opacity: overlayOpacity,
            gradient: overlayGradient,
          ),
          SafeArea(child: child),
          if (kDebugMode && showLayoutGrid)
            AppLayoutGrid(columns: gridColumns, color: gridColor),
        ],
      ),
    );
  }
}

class AppBackgroundImage extends StatelessWidget {
  const AppBackgroundImage({super.key, this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(image ?? AppAssets.authProfileBG, fit: BoxFit.cover),
    );
  }
}

class AppBackgroundOverlay extends StatelessWidget {
  const AppBackgroundOverlay({
    super.key,
    required this.color,
    required this.opacity,
    this.gradient,
  });

  final Color color;
  final double opacity;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: gradient == null ? color.withValues(alpha: opacity) : null,
          gradient: gradient,
        ),
      ),
    );
  }
}

class AppLayoutGrid extends StatelessWidget {
  const AppLayoutGrid({super.key, required this.columns, this.color});

  final int columns;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
          child: Row(
            children: List.generate(columns * 2 - 1, (index) {
              if (index.isOdd) return SizedBox(width: 16.w);
              return Expanded(child: AppLayoutColumn(color: color));
            }),
          ),
        ),
      ),
    );
  }
}

class AppLayoutColumn extends StatelessWidget {
  const AppLayoutColumn({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: (color ?? AppColors.error).withValues(alpha: 0.08),
    );
  }
}
