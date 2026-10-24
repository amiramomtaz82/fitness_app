import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward().then((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نفس لون الـ native splash عشان مفيش وميض بينهم
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(AppAssets.logo, width: 240.w, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
