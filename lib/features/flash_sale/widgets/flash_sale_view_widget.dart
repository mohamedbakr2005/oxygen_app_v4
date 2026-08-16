import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:Oxygen_Mart/features/flash_sale/widgets/flash_sale_timer_view_widget.dart';
import 'package:Oxygen_Mart/features/flash_sale/widgets/timer_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/components/flash_sale_card_widget.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class FlashSaleViewWidget extends StatefulWidget {
  const FlashSaleViewWidget({super.key});

  @override
  State<FlashSaleViewWidget> createState() => _FlashSaleViewWidgetState();
}

class _FlashSaleViewWidgetState extends State<FlashSaleViewWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlashSaleController>(builder: (flashSaleController) {
      return flashSaleController.flashSaleModel != null
          ? flashSaleController.flashSaleModel!.activeProducts != null &&
                  flashSaleController.duration!.inSeconds > 1
              ? Container(
                  width: Get.width,
                  color: const Color(0xFFF0F9F4), // Slightly lighter mint background for contrast
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                  child: Column(
                    children: [
                      // Header Section (Glassmorphism)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75), // Frosted white
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2EAA60).withOpacity(0.15),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeDefault),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Right Side (First in RTL): Title & Badge
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('flash_sale'.tr,
                                                style: robotoBold.copyWith(
                                                    fontSize: 22, color: Colors.black87)),
                                            const SizedBox(height: 4),
                                            Text('عروض حصرية لفترة محدودة', // Hardcoded subtitle per spec
                                                style: robotoRegular.copyWith(
                                                    fontSize: 14, color: Colors.grey)),
                                          ]
                                        ),
                                        const SizedBox(width: 12),
                                        // Glossy Lightning Badge
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const RadialGradient(
                                              colors: [Color(0xFF3FE281), Color(0xFF1B6E3A)],
                                              radius: 0.8,
                                            ),
                                            border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF2EAA60).withOpacity(0.5),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          ),
                                          child: const Icon(Icons.bolt, color: Colors.yellow, size: 30),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(width: 20),
                                    
                                    // Left Side (Second in RTL): Timer
                                    FlashSaleTimerView(eventDuration: flashSaleController.duration),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      
                      // Product Card Carousel
                      flashSaleController.flashSaleModel!.activeProducts != null
                          ? FlashSaleCard(
                              activeProducts: flashSaleController.flashSaleModel!.activeProducts!,
                              soldOut: false, // Calculated internally per item now
                            )
                          : const SizedBox(),
                    ],
                  ),
                )
              : const SizedBox()
          : const FlashSaleShimmerView();
    });
  }
}

class FlashSaleShimmerView extends StatelessWidget {
  const FlashSaleShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: ResponsiveHelper.isDesktop(context) ? 330 : 350,
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9F4),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 2000),
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        enabled: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, width: 100, color: Colors.white),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Container(height: 15, width: 80, color: Colors.white),
                  ],
                ),
                const Spacer(),
                Container(height: 50, width: 200, color: Colors.white),
              ]),
            ),
            Container(
              height: ResponsiveHelper.isDesktop(context) ? 150 : 170,
              width: Get.width * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
