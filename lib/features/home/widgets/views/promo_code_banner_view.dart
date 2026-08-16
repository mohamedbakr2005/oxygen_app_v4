import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class PromoCodeBannerView extends StatefulWidget {
  const PromoCodeBannerView({super.key});

  @override
  State<PromoCodeBannerView> createState() => _PromoCodeBannerViewState();
}

class _PromoCodeBannerViewState extends State<PromoCodeBannerView> {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponController>(builder: (couponController) {
      return couponController.couponList != null
          ? couponController.couponList!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault,
                      horizontal: Dimensions.paddingSizeSmall),
                  child: Column(children: [
                    CarouselSlider.builder(
                      carouselController: carouselController,
                      itemCount: couponController.couponList!.length,
                      options: CarouselOptions(
                        height: 210, 
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 5),
                        enlargeCenterPage: true,
                        disableCenter: true,
                        viewportFraction: 0.95,
                        onPageChanged: (index, reason) {
                          couponController.setCurrentIndex(index, true);
                        },
                      ),
                      itemBuilder: (BuildContext context, int itemIndex,
                          int pageViewIndex) {
                        final coupon = couponController.couponList![itemIndex];

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(0.12),
                          alignment: FractionalOffset.center,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(
                                top: 25, bottom: 15, left: 4, right: 4),
                            // --- الإطار المعدني الخارجي ---
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE0E0E0),
                                  Color(0xFFFFFFFF),
                                  Color(0xFF9E9E9E),
                                  Color(0xFF616161),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFBDBDBD),
                                  offset: Offset(0, 4),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Color(0xFFEEEEEE),
                                  offset: Offset(0, -2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3.5),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // --- الحاوية الخضراء الداخلية ---
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4FA07B),
                                        Color(0xFF2C6B50),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      children: [
                                        // --- صورة الخلفية (الباترن) هنا ---
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: 0.5, // الشفافية عشان تندمج مع الأخضر (لو عايزها أغمق زود الرقم ده)
                                            child: Image.asset(
                                              Images.promoCodeBg,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.workspace_premium,
                                                            color: Colors.white70,
                                                            size: 16),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'عروض حصرية',
                                                          style:
                                                              robotoMedium.copyWith(
                                                            color: Colors.white70,
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        coupon.title ?? '',
                                                        style: robotoBold.copyWith(
                                                          fontSize: 22,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        '${'min_order_of'.tr} ${PriceConverter.convertPrice(coupon.minPurchase)}',
                                                        style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color: Colors.white
                                                              .withValues(alpha: 0.9),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    CustomInkWell(
                                                      onTap: () {
                                                        if (coupon.code != null) {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: coupon.code ??
                                                                      ''));
                                                          showCustomSnackBar(
                                                              'coupon_code_copied'.tr,
                                                              isError: false);
                                                        }
                                                      },
                                                      radius: 50,
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 16,
                                                            vertical: 8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  50),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Color(0xFF1B4231),
                                                              offset: Offset(0, 3),
                                                              blurRadius: 0,
                                                            )
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                                Icons.copy_outlined,
                                                                color:
                                                                    Color(0xFF2C6B50),
                                                                size: 16),
                                                            const SizedBox(width: 6),
                                                            Text(
                                                              'كود خصم : ${coupon.code ?? ''}',
                                                              style:
                                                                  robotoBold.copyWith(
                                                                color: const Color(
                                                                    0xFF2C6B50),
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                              ),
                                                              textDirection:
                                                                  TextDirection.rtl,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Expanded(
                                                  flex: 4, child: SizedBox()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // --- الصورة البارزة (اللوجو) ---
                                Positioned(
                                  left: 10,
                                  bottom: -5,
                                  top: -25,
                                  child: Image.asset(
                                    Images.couponOfferIcon,
                                    width: 140,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: couponController.couponList!.map((bnr) {
                        int index = couponController.couponList!.indexOf(bnr);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width:
                              index == couponController.currentIndex ? 18 : 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: index == couponController.currentIndex
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.3),
                          ),
                        );
                      }).toList(),
                    ),
                  ]),
                )
              : const SizedBox()
          : const PromoCodeShimmerView();
    });
  }
}

class PromoCodeShimmerView extends StatelessWidget {
  const PromoCodeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeDefault,
          horizontal: Dimensions.paddingSizeSmall),
      child: Column(children: [
        CarouselSlider.builder(
          itemCount: 3,
          options: CarouselOptions(
            height: 210,
            enlargeCenterPage: true,
            disableCenter: true,
            viewportFraction: 0.95,
          ),
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) {
            return Shimmer.fromColors(
              period: const Duration(milliseconds: 2000),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              enabled: true,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                    top: 25, bottom: 15, left: 4, right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }
}