import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/on_bording/views/widgets/onboarding_buttons.dart';
import 'package:fitness_app/features/on_bording/views/widgets/onboarding_indicator.dart';
import 'package:fitness_app/features/on_bording/views/widgets/onboarding_page_item.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const List<({String image, String titleKey, String descKey})> _pages =
      [
        (
          image: AppAssets.boarding1,
          titleKey: LocaleKeys.onboarding_title_1,
          descKey: LocaleKeys.onboarding_desc_1,
        ),
        (
          image: AppAssets.boarding2,
          titleKey: LocaleKeys.onboarding_title_2,
          descKey: LocaleKeys.onboarding_desc_2,
        ),
        (
          image: AppAssets.boarding3,
          titleKey: LocaleKeys.onboarding_title_3,
          descKey: LocaleKeys.onboarding_desc_3,
        ),
      ];

  bool get _isFirst => _currentPage == 0;
  bool get _isLast => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _back() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToLogin() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => OnboardingPageItem(
              image: _pages[index].image,
              title: _pages[index].titleKey.tr(),
              description: _pages[index].descKey.tr(),
            ),
          ),
          if (!_isLast)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    LocaleKeys.onboarding_skip.tr(),
                    style: AppTextStyles.white14regular,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingIndicator(
                      controller: _controller,
                      count: _pages.length,
                    ),
                    SizedBox(height: 20.h),
                    OnboardingButtons(
                      isFirst: _isFirst,
                      isLast: _isLast,
                      onNext: _next,
                      onBack: _back,
                      onFinish: _goToLogin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
