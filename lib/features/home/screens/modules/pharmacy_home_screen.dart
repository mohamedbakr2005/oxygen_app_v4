import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/bogo_offer_card_widget.dart';
import 'package:Oxygen_Mart/features/reels/widgets/reels_section_widget.dart';
import 'package:Oxygen_Mart/features/reels/controllers/reels_controller.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/features/home/widgets/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/category_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/common_condition_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:Oxygen_Mart/features/home/widgets/todays_deals_section.dart';
import 'package:Oxygen_Mart/features/home/widgets/top_picks_near_you_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/visit_again_view.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (Get.find<SplashController>().module != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: InkWell(
            onTap: () {
              Get.find<SplashController>().removeModule();
              Get.find<StoreController>().resetStoreData();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).disabledColor.withOpacity(0.1),
        child: const Column(
          children: [
            // BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),
      const CategoryView(),
      const TodaysDealsSectionWidget(),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      TopPicksNearYouWidget(title: "verified_pharmacies".tr, subTitle: "secure_buying_experience".tr, isVerifiedStore: true),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      TopPicksNearYouWidget(title: "recommended_for_you".tr, isRecommended: true),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const ProductWithCategoriesView(),
      GetBuilder<ReelsController>(builder: (controller) {
        final visible = (controller.reelsList == null && controller.isLoading) || (controller.reelsList != null && controller.reelsList!.isNotEmpty);
        return visible ? const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ReelsSectionWidget(),
        ) : const SizedBox();
      }),
      const BogoOfferCardWidget(),
      const HighlightWidget(),
      const MiddleSectionBannerView(),
      const TopOffersNearMe(),
      // const NewOnMartView(isShop: false, isPharmacy: true, isNewStore: true),
      const CommonConditionView(),
      const PromotionalBannerView(),
    ]);
  }
}

