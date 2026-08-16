import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:universal_html/js.dart' as js;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class BannerView extends StatelessWidget {
  final bool isFeatured;
  const BannerView({super.key, required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      List<String?>? bannerList = isFeatured
          ? bannerController.featuredBannerList
          : bannerController.bannerImageList;
      List<dynamic>? bannerDataList = isFeatured
          ? bannerController.featuredBannerDataList
          : bannerController.bannerDataList;

      final double bannerHeight = GetPlatform.isDesktop
          ? 500
          : MediaQuery.of(context).size.width * 0.52;

      return (bannerList != null && bannerList.isEmpty)
          ? const SizedBox()
          : Container(
              width: MediaQuery.of(context).size.width,
              height: bannerHeight + Dimensions.paddingSizeDefault,
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              child: bannerList != null
                  ? Stack(
                      children: [
                        // ── Carousel ───────────────────────────────────
                        CarouselSlider.builder(
                          options: CarouselOptions(
                            height: bannerHeight,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            disableCenter: true,
                            viewportFraction: 0.90,
                            autoPlayInterval: const Duration(seconds: 7),
                            autoPlayCurve: Curves.easeInOut,
                            onPageChanged: (index, reason) {
                              bannerController.setCurrentIndex(index, true);
                            },
                          ),
                          itemCount: bannerList.isEmpty ? 1 : bannerList.length,
                          itemBuilder: (context, index, _) {
                            return _BannerCard(
                              bannerUrl: bannerList[index],
                              onTap: () async {
                                if (bannerDataList![index] is Item) {
                                  Item? item = bannerDataList[index];
                                  Get.find<ItemController>().navigateToItemPage(item, context);
                                } else if (bannerDataList[index] is Store) {
                                  Store? store = bannerDataList[index];
                                  if (isFeatured &&
                                      (AddressHelper.getUserAddressFromSharedPref()!.zoneData != null &&
                                          AddressHelper.getUserAddressFromSharedPref()!.zoneData!.isNotEmpty)) {
                                    for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                                      if (module.id == store!.moduleId) {
                                        Get.find<SplashController>().setModule(module);
                                        break;
                                      }
                                    }
                                    ZoneData zoneData = AddressHelper.getUserAddressFromSharedPref()!.zoneData!
                                        .firstWhere((data) => data.id == store!.zoneId);
                                    Modules module = zoneData.modules!.firstWhere((module) => module.id == store!.moduleId);
                                    Get.find<SplashController>().setModule(ModuleModel(
                                        id: module.id, moduleName: module.moduleName, moduleType: module.moduleType, themeId: module.themeId, storesCount: module.storesCount));
                                  }
                                  Get.toNamed(
                                    RouteHelper.getStoreRoute(id: store!.id, page: isFeatured ? 'module' : 'banner'),
                                    arguments: StoreScreen(store: store, fromModule: isFeatured),
                                  );
                                } else if (bannerDataList[index] is BasicCampaignModel) {
                                  BasicCampaignModel campaign = bannerDataList[index];
                                  Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign));
                                } else {
                                  String url = bannerDataList[index];
                                  if (await canLaunchUrlString(url)) {
                                    await launchUrlString(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    showCustomSnackBar('unable_to_found_url'.tr);
                                  }
                                }
                              },
                            );
                          },
                        ),

                        // ── Overlay pagination dots ────────────────────
                        if (bannerList.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: bannerList.asMap().entries.map((entry) {
                                final bool isActive = entry.key == bannerController.currentIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOut,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  height: 6,
                                  width: isActive ? 28 : 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Theme.of(context).primaryColor
                                        : Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: isActive
                                        ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 0)]
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    )
                  : _BannerShimmer(height: bannerHeight),
            );
    });
  }

  void fbBannerClickWeb({required int index, required String? bannerImage, required String bannerType}) {
    js.context.callMethod('fbq', ['trackCustom', 'BannerClick', {"banner_index": index, "banner_image": bannerImage, "banner_type": bannerType}]);
  }
}

// ─── Individual banner card ───────────────────────────────────────────────────
class _BannerCard extends StatefulWidget {
  final String? bannerUrl;
  final VoidCallback onTap;
  const _BannerCard({required this.bannerUrl, required this.onTap});
  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, spreadRadius: 0, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: GetBuilder<SplashController>(builder: (splashController) {
              return CustomImage(
                image: '${widget.bannerUrl}',
                fit: BoxFit.cover,
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Banner shimmer ────────────────────────────────────────────────────────────
class _BannerShimmer extends StatelessWidget {
  final double height;
  const _BannerShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1800),
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.white,
      enabled: true,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
