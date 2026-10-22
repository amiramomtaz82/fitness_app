import 'package:fitness_app/core/contants/app_assets.dart';
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
    this.overlayColor = Colors.black,
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
          // 1. Background image
          Positioned.fill(
            child: Image.asset(
              backgroundImage ??AppAssets.authProfileBG,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Overlay tint (Solid color or Gradient, customizable per feature)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: overlayGradient == null
                    ? overlayColor.withValues(alpha: overlayOpacity)
                    : null,
                gradient: overlayGradient,
              ),
            ),
          ),

          // 3. Screen content
          SafeArea(child: child),

          // 4. Feature-Specific Layout Guide Overlay (Visible only in debug if enabled)
          if (kDebugMode && showLayoutGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w),
                  child: Row(
                    children: List.generate(
                      gridColumns * 2 - 1,
                          (index) {
                        // Alternate between column and gutter gap
                        if (index.isOdd) {
                          return SizedBox(width: 16.w);
                        }
                        return Expanded(
                          child: Container(
                            color: (gridColor ?? Colors.red).withValues(alpha:.09),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}