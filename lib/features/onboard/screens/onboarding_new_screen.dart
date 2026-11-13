import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OnBoardingNewScreen extends StatefulWidget {
  const OnBoardingNewScreen({super.key});

  @override
  State<OnBoardingNewScreen> createState() => _OnBoardingNewScreenState();
}

class _OnBoardingNewScreenState extends State<OnBoardingNewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isNavigating = false;

  static const List<String> _onboardingImages = [
    Images.onBoarding1,
    Images.onBoarding2,
    Images.onBoarding3,
  ];

  static const Color _screenBgColor = Color(0xFFFEFDF6);
  static const Color _primaryGreen = Color(0xFF008B47);
  static const Color _accentGreen = Color(0xFF05A855);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final img in _onboardingImages) {
      precacheImage(AssetImage(img), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_currentPage != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentPage = index;
      });
    }
  }

  void _handleNext() {
    HapticFeedback.lightImpact();
    if (_currentPage < _onboardingImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _configureToRouteInitialPage();
    }
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    _configureToRouteInitialPage();
  }

  void _configureToRouteInitialPage() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      Get.find<SplashController>().disableIntro();
      await Get.find<AuthController>().guestLogin();
      if (AddressHelper.getUserAddressFromSharedPref() != null) {
        Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
      } else {
        Get.find<LocationController>().navigateToLocationScreen(
          RouteHelper.onBoarding,
          offNamed: true,
        );
      }
    } catch (_) {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: _screenBgColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _screenBgColor,
        appBar: isDesktop ? const WebMenuBar() : null,
        body: SafeArea(
          top: false,
          bottom: true,
          child: Center(
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440, maxHeight: 860),
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _screenBgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Full screen content
        Column(
          children: [
            // PageView taking maximum available space
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingImages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _OnboardingImageCard(
                    imagePath: _onboardingImages[index],
                  );
                },
              ),
            ),

            // Bottom Navigation Controls Dock
            _buildBottomControls(),
          ],
        ),

        // Floating Top Bar (Back & Skip buttons)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: _buildTopBar(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    final bool isLastPage = _currentPage == _onboardingImages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (shown when on slide 1 or 2)
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: _currentPage == 0,
              child: _GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _handleBack,
              ),
            ),
          ),

          // Skip button ("تخطي")
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: _GlassCapsuleButton(
                title: 'skip'.tr,
                onTap: _handleSkip,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    final bool isLastPage = _currentPage == _onboardingImages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Modern Animated Page Indicator
          _buildPageIndicator(),

          // Dynamic Action CTA Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            height: 54,
            width: isLastPage ? 185 : 54,
            child: isLastPage
                ? _buildGetStartedButton()
                : _buildNextRoundButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_onboardingImages.length, (index) {
        final bool isSelected = _currentPage == index;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isSelected ? 30 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [_primaryGreen, _accentGreen],
                    )
                  : null,
              color: isSelected ? null : const Color(0xFFD8E2DC),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primaryGreen.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNextRoundButton() {
    final double progress = (_currentPage + 1) / _onboardingImages.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Sleek outer circular progress tracker
        SizedBox(
          width: 54,
          height: 54,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 2.5,
                backgroundColor: _primaryGreen.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(_primaryGreen),
              );
            },
          ),
        ),

        // Central elevated action button
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _handleNext,
            customBorder: const CircleBorder(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryGreen, _accentGreen],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryGreen.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: _handleNext,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryGreen, Color(0xFF02A350)],
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryGreen.withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'يلا بينا'.tr,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingImageCard extends StatelessWidget {
  final String imagePath;

  const _OnboardingImageCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.topCenter,
      child: Image.asset(
        imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _GlassCapsuleButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _GlassCapsuleButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: robotoBold.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF0E3826),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: Color(0xFF0E3826),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: const Color(0xFF0E3826),
            ),
          ),
        ),
      ),
    );
  }
}
