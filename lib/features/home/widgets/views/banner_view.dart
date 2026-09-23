import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class BannerView extends StatefulWidget {
  final bool isFeatured;
  const BannerView({super.key, required this.isFeatured});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    return GetBuilder<BannerController>(builder: (bannerController) {
      List<String?>? bannerList = widget.isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      List<dynamic>? bannerDataList = widget.isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      return (bannerList != null && bannerList.isEmpty)
          ? const SizedBox()
          : Container(
              width: MediaQuery.of(context).size.width,
              // Ø¸Ø¨Ø·Ù†Ø§ Ø§Ù„Ø§Ø±ØªÙØ§Ø¹ Ø¹Ø´Ø§Ù† ÙŠØªÙ†Ø§Ø³Ø¨ Ù…Ø¹ Ø§Ù„Ø¹Ø±Ø¶ Ø§Ù„Ø¹Ø±ÙŠØ¶
              height: GetPlatform.isDesktop
                  ? 500
                  : MediaQuery.of(context).size.width * 0.55,
              padding:
                  const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              child: bannerList != null
                  ? Column(
                      children: [
                        Expanded(
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              autoPlay: true,
                              // 1. Ø´ØºÙ„Ù†Ø§ Ø§Ù„Ø²ÙˆÙˆÙ… Ø¹Ø´Ø§Ù† Ø§Ù„Ù„ÙŠ ÙÙŠ Ø§Ù„Ù†Øµ ØªØ¨Ø±Ø²
                              enlargeCenterPage: true,
                              disableCenter: true,

                              // 2. Ø¯Ù‡ Ø§Ù„Ø±Ù‚Ù… Ø§Ù„Ø³Ø­Ø±ÙŠ: 0.93
                              // Ø¨ÙŠØ®Ù„ÙŠ Ø§Ù„ÙƒØ§Ø±Øª ÙŠØ§Ø®Ø¯ 93% Ù…Ù† Ø§Ù„Ø¹Ø±Ø¶ (Ø¹Ø±ÙŠØ¶ Ø¬Ø¯Ø§Ù‹)
                              // ÙˆØ§Ù„Ù€ 7% Ø§Ù„Ø¨Ø§Ù‚ÙŠØ© Ø¨ØªØªÙ‚Ø³Ù… ÙŠÙ…ÙŠÙ† ÙˆØ´Ù…Ø§Ù„ (Ø­ØªØ© ØµØºÙŠØ±Ø© ØªØ¨Ø§Ù†)
                              viewportFraction: 0.98,

                              // 3. Ù‚Ù„Ù„Ù†Ø§ Ø§Ù„ÙØ§ÙƒØªÙˆØ± Ù„Ù€ 0.15
                              // Ø¹Ø´Ø§Ù† Ø§Ù„Ø¬Ù†Ø§Ø¨ Ù…ØªØµØºØ±Ø´ Ø£ÙˆÙŠ ÙˆØªØ¨Ù‚Ù‰ "Ù…ÙØ¹ÙˆØµØ©"ØŒ ÙƒØ¯Ø© Ù‡ØªØ¨Ø§Ù† Ø­ØªØ© ØµØºÙŠØ±Ø© ÙˆÙ…Ø­ØªØ±Ù…Ø©
                              enlargeFactor: 0.3,

                              clipBehavior: Clip.none,
                              autoPlayInterval: const Duration(seconds: 6),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              onPageChanged: (index, reason) {
                                bannerController.setCurrentIndex(index, true);
                              },
                            ),
                            itemCount:
                                bannerList.isEmpty ? 1 : bannerList.length,
                            itemBuilder: (context, index, _) {
                              return _buildZoomBannerItem(
                                context: context,
                                imageUrl: bannerList[index]!,
                                onTap: () => _handleBannerClick(
                                  index,
                                  bannerList[index]!,
                                  bannerDataList,
                                  analytics,
                                  context,
                                ),
                              );
                            },
                          ),
                        ),

                        // Ø§Ù„Ù…Ø¤Ø´Ø±Ø§Øª (Dots)
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: bannerList.asMap().entries.map((entry) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutQuad,
                              width: bannerController.currentIndex == entry.key
                                  ? 20
                                  : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color:
                                    bannerController.currentIndex == entry.key
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.withValues(alpha: 0.3),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : _buildShimmerLoading(context),
            );
    });
  }

  // --- Zoom Style Item ---
  Widget _buildZoomBannerItem({
    required BuildContext context,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Container(
      // Ù‚Ù„Ù„Øª Ø§Ù„Ù…Ø§Ø±Ø¬Ù† Ø®Ø§Ù„Øµ (2) Ø¹Ø´Ø§Ù† Ø§Ø­Ù†Ø§ Ù…ÙƒØ¨Ø±ÙŠÙ† Ø§Ù„Ù€ viewportFraction Ø¹ Ø§Ù„Ø¢Ø®Ø±
      // ÙÙ…Ø´ Ø¹Ø§ÙŠØ²ÙŠÙ† Ù…Ø³Ø§ÙØ§Øª ÙƒØ¨ÙŠØ±Ø©ØŒ ÙŠØ¯ÙˆØ¨ ÙØ§ØµÙ„ Ø¨Ø³ÙŠØ·
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: CustomImage(
              image: imageUrl,
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  // --- Shimmer ---
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          viewportFraction: 1, // Ù†ÙØ³ Ø§Ù„Ø±Ù‚Ù… Ø¹Ø´Ø§Ù† ÙŠØ¸Ø¨Ø· Ù…Ø¹ Ø§Ù„ØªØ­Ù…ÙŠÙ„
          enlargeCenterPage: true,
          enlargeFactor: 0.4,
          disableCenter: false,
        ),
        itemCount: 3,
        itemBuilder: (context, index, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }

  // --- Logic ---
  Future<void> _handleBannerClick(
    int index,
    String bannerImage,
    List<dynamic>? bannerDataList,
    FirebaseAnalytics analytics,
    BuildContext context,
  ) async {
    if (bannerDataList == null || bannerDataList.isEmpty) return;

    final data = bannerDataList[index];
    final String type = data.runtimeType.toString();

    analytics.logEvent(
      name: 'banner_click',
      parameters: {'index': index, 'image': bannerImage, 'type': type},
    );

    if (data is Item) {
      Get.find<ItemController>().navigateToItemPage(data, context);
    } else if (data is Store) {
      _handleStoreNavigation(data, context);
    } else if (data is BasicCampaignModel) {
      Get.toNamed(RouteHelper.getBasicCampaignRoute(data));
    } else if (data is String) {
      if (await canLaunchUrlString(data)) {
        await launchUrlString(data, mode: LaunchMode.externalApplication);
      } else {
        showCustomSnackBar('unable_to_found_url'.tr);
      }
    }
  }

  void _handleStoreNavigation(Store store, BuildContext context) {
    if (widget.isFeatured) {
      final splash = Get.find<SplashController>();
      if (splash.moduleList != null) {
        for (var module in splash.moduleList!) {
          if (module.id == store.moduleId) {
            splash.setModule(module);
            break;
          }
        }
      }
    }
    Get.toNamed(
      RouteHelper.getStoreRoute(
        id: store.id,
        page: widget.isFeatured ? 'module' : 'banner',
      ),
      arguments: StoreScreen(store: store, fromModule: widget.isFeatured),
    );
  }
}



