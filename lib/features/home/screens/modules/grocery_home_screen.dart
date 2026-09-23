import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/features/reels/widgets/reels_section_widget.dart';
import 'package:Oxygen_Mart/features/reels/controllers/reels_controller.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/home/widgets/module_list_widget.dart';
import 'package:Oxygen_Mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/category_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/special_offer_view.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/features/home/widgets/shop_upto_offer.dart';
import 'package:Oxygen_Mart/features/home/widgets/todays_deals_section.dart';
import 'package:Oxygen_Mart/features/home/widgets/top_picks_near_you_widget.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import '../../widgets/bad_weather_widget.dart';
import '../../widgets/views/most_popular_item_view.dart';

class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Padding(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).cardColor,
          child: const Column(
            children: [
              BadWeatherWidget(),
              BannerView(isFeatured: false),
              SizedBox(height: 12),
            ],
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: ShopUpToOffer(variant: TopOfferVariant.grocery),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        const ModuleListWidget(),
        const SpecialOfferView(isFood: false, isShop: false),
        // const TodaysDealsSectionWidget(),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        // TopPicksNearYouWidget(title: "recommended_for_you".tr, isRecommended: true),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        GetBuilder<ReelsController>(builder: (controller) {
        final visible = (controller.reelsList == null && controller.isLoading) || (controller.reelsList != null && controller.reelsList!.isNotEmpty);
        return visible ? const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ReelsSectionWidget(),
        ) : const SizedBox();
      }),
        const HighlightWidget(),
        const FlashSaleViewWidget(),
        // const BestStoreNearbyView(),
        const MostPopularItemView(isFood: false, isShop: false),
        const JustForYouView(),

        const CategoryView(),
        const MiddleSectionBannerView(),
        // const BestReviewItemView(),
        // const TopOffersNearMe(),
        // const ItemThatYouLoveView(forShop: false),
        isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
        // const NewOnMartView(isPharmacy: false, isShop: false),
        const PromotionalBannerView(),
      ]),
    );
  }
}

