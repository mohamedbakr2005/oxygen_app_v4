import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class PromotionalBannerView extends StatelessWidget {
  const PromotionalBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      return bannerController.promotionalBanner != null
          ? bannerController.promotionalBanner!.bottomSectionBannerFullUrl !=
                  null
              ? Container(
                  height: 200,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeDefault,
                      horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    child: CustomImage(
                      image:
                          '${bannerController.promotionalBanner!.bottomSectionBannerFullUrl}',
                      fit: BoxFit.cover,
                      height: 80,
                      width: double.infinity,
                      isHighQuality: true,
                    ),
                  ),
                )
              : const SizedBox()
          : const PromotionalBannerShimmerView();
    });
  }
}

class PromotionalBannerShimmerView extends StatelessWidget {
  const PromotionalBannerShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 2000),
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      enabled: true,
      child: Container(
        height: 90,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
      ),
    );
  }
}
