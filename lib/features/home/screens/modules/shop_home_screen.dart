import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/brands_view_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/category_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/featured_categories_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/popular_store_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/special_offer_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/visit_again_view.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class ShopHomeScreen extends StatelessWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (Get.find<SplashController>().module != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: InkWell(
            onTap: () {
              var splashCtrl = Get.find<SplashController>();
              if (splashCtrl.moduleList != null) {
                try {
                  var groceryModule = splashCtrl.moduleList!.firstWhere((m) => m.moduleType == AppConstants.grocery);
                  splashCtrl.switchModule(groceryModule);
                } catch (e) {
                  splashCtrl.removeModule();
                }
              } else {
                splashCtrl.removeModule();
              }
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.shopModuleBannerBg),
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

      const CategoryView(),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const MostPopularItemView(isFood: false, isShop: true),
      const FlashSaleViewWidget(),
      const MiddleSectionBannerView(),
      const HighlightWidget(),
      const PopularStoreView(),
      const BrandsViewWidget(),
      const SpecialOfferView(isFood: false, isShop: true),
      const ProductWithCategoriesView(fromShop: true),
      const TopOffersNearMe(),
      const FeaturedCategoriesView(),
      // const StoreWiseBannerView(),
      const ItemThatYouLoveView(
        forShop: true,
      ),
      // const NewOnMartView(isShop: true, isPharmacy: false),
      const PromotionalBannerView(),
    ]);
  }
}
