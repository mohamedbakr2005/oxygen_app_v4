import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/category_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/popular_store_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/visit_again_view.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/features/reels/widgets/reels_section_widget.dart';
import 'package:Oxygen_Mart/features/reels/controllers/reels_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/shop_upto_offer.dart';
import 'package:Oxygen_Mart/features/home/widgets/todays_deals_section.dart';
import 'package:Oxygen_Mart/features/home/widgets/top_picks_near_you_widget.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: MediaQuery.of(context).size.width,
        decoration: Get.find<ThemeController>().darkTheme
            ? null
            : const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Images.foodModuleBannerBg),
                  fit: BoxFit.cover,
                ),
              ),
        child: const Column(
          children: [
            // BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: ShopUpToOffer(variant: TopOfferVariant.food),
      ),
      const CategoryView(),
      const TodaysDealsSectionWidget(),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      TopPicksNearYouWidget(title: "top_picks_near_you".tr, isNearYou: true),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      TopPicksNearYouWidget(title: "recommended_for_you".tr, isRecommended: true),
      const SizedBox(height: Dimensions.paddingSizeSmall),
      isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox(),
      GetBuilder<ReelsController>(builder: (controller) {
        final visible = (controller.reelsList == null && controller.isLoading) || (controller.reelsList != null && controller.reelsList!.isNotEmpty);
        return visible ? const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ReelsSectionWidget(),
        ) : const SizedBox();
      }),
      const HighlightWidget(),
      const TopOffersNearMe(),
      const BestStoreNearbyView(),
      const PopularStoreView(),
      const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false),
    ]);
  }
}

