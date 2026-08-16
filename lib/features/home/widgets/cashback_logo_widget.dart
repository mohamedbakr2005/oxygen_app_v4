import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CashBackLogoWidget extends StatefulWidget {
  const CashBackLogoWidget({super.key});

  @override
  State<CashBackLogoWidget> createState() => _CashBackLogoWidgetState();
}

class _CashBackLogoWidgetState extends State<CashBackLogoWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Pulse / Breathing Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // 2. Shiny Glint / Sweep Animation (Runs every 2.5 seconds)
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _shineAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
    _shineController.repeat();

    // 3. Sparkle Fade / Scale Animation
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _sparkleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withOpacity(_glowAnimation.value * 0.5),
                  blurRadius: 14 + (4 * _scaleAnimation.value),
                  spreadRadius: 2 + _glowAnimation.value * 2,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Rich gold-to-orange metallic gradient base
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFF176), // Light shiny yellow
                        Color(0xFFFFB300), // Amber
                        Color(0xFFE65100), // Deep orange
                      ],
                      stops: [0.0, 0.4, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.8,
                    ),
                  ),
                ),

                // 2. Glassmorphic inner ring overlay
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.2,
                    ),
                  ),
                ),

                // 3. Central Content (Icon & Text)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 6),
                      const Icon(
                        Icons.monetization_on_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'cash_back'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Glint / Metallic shine sweep overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: AnimatedBuilder(
                      animation: _shineController,
                      builder: (context, child) {
                        return FractionalTranslation(
                          translation: Offset(_shineAnimation.value, 0),
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.35),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  stops: const [0.3, 0.5, 0.7],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 5. Sparkle Stars (Magical effect)
                Positioned(
                  top: 6,
                  right: 6,
                  child: FadeTransition(
                    opacity: _sparkleAnimation,
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: FadeTransition(
                    opacity: _sparkleAnimation,
                    child: const Icon(
                      Icons.star,
                      color: Color(0xFFFFF59D), // Light yellow star
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
