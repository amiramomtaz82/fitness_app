import 'package:flutter/material.dart';

class AppBackgroundScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final String? backgroundImage;
  final double overlayOpacity;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  const AppBackgroundScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.backgroundImage,
    this.overlayOpacity = 0.6,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // 1. Background image (uses default or custom asset)
          Positioned.fill(
            child: Image.asset(
              backgroundImage ?? 'assets/images/auth_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Dark overlay tint
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: overlayOpacity),
            ),
          ),
          // 3. Screen content
          SafeArea(child: child),
        ],
      ),
    );
  }
}