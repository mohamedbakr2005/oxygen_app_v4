import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/features/bogo_offer/controllers/bogo_offer_controller.dart';
import 'package:Oxygen_Mart/features/bogo_offer/domain/models/bogo_offer_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BogoOfferCardWidget extends StatelessWidget {
  final bool bordered;
  final VoidCallback? onTap;

  const BogoOfferCardWidget({super.key, this.bordered = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BogoOfferController>(builder: (bogoOfferController) {
      final BogoHomeModel? bogoHome = bogoOfferController.bogoHomeModel;
      if (bogoHome?.isLive != true) {
        return const SizedBox.shrink();
      }

      final String title = 'hurry_up_bogo_offer_is_live'.tr;
      final String description = 'buy_more_and_enjoy_exclusive_free_items'.tr;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,
        ),
        child: CustomInkWell(
          onTap: onTap ?? () => Get.toNamed(RouteHelper.getBogoOfferRoute(moduleId: Get.find<SplashController>().module?.id)),
          radius: Dimensions.radiusLarge,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall + 4,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.12),
                  Theme.of(context).primaryColor.withOpacity(0.04),
                ],
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
              ),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.25),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CustomAssetImageWidget(Images.bogoOfferIcon, height: 32, width: 32),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )),
                    const SizedBox(height: 3),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall - 0.5,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75),
                      )),
                  ],
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 14,
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
