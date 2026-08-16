import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/features/home/widgets/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/category_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/common_condition_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/visit_again_view.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
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
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const ProductWithCategoriesView(),
      const HighlightWidget(),
      const MiddleSectionBannerView(),
      const TopOffersNearMe(),
      // const NewOnMartView(isShop: false, isPharmacy: true, isNewStore: true),
      const CommonConditionView(),
      const PromotionalBannerView(),
    ]);
  }
}
