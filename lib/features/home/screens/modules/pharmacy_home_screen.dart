import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/features/checkout/screens/checkout_screen.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/bogo_offer_card_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/highlight_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/todays_deals_section.dart';
import 'package:Oxygen_Mart/features/home/widgets/top_picks_near_you_widget.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/common_condition_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/visit_again_view.dart';
import 'package:Oxygen_Mart/features/reels/controllers/reels_controller.dart';
import 'package:Oxygen_Mart/features/reels/widgets/reels_section_widget.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Prescription Hero Card
      const _PharmacyPrescriptionHeroCard(),

      // Banner Section
      Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).disabledColor.withOpacity(0.06),
        child: const Column(
          children: [
            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),

      // Basic Medicine Nearby with Category Filter Tabs
      const ProductWithCategoriesView(),

      // Medicines by Common Health Condition / Symptoms
      const CommonConditionView(),

      // Recommended Pharmacies
      const RecommendedStoreView(),

      // Nearest Pharmacies
      const BestStoreNearbyView(),

      // Top Offers Near Me
      const TopOffersNearMe(),

      // Today's Deals
      const TodaysDealsSectionWidget(),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      // Verified Pharmacies
      TopPicksNearYouWidget(
        title: "verified_pharmacies".tr,
        subTitle: "secure_buying_experience".tr,
        isVerifiedStore: true,
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      // Recommended for you
      TopPicksNearYouWidget(
        title: "recommended_for_you".tr,
        isRecommended: true,
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      // Order Again
      isLoggedIn ? const VisitAgainView() : const SizedBox(),

      // Medical Reels / Health Tips
      GetBuilder<ReelsController>(builder: (controller) {
        final visible = (controller.reelsList == null && controller.isLoading) ||
            (controller.reelsList != null && controller.reelsList!.isNotEmpty);
        return visible
            ? const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ReelsSectionWidget(),
              )
            : const SizedBox();
      }),

      // Buy 1 Get 1
      const BogoOfferCardWidget(),

      // Highlights
      const HighlightWidget(),

      // Middle Banner
      const MiddleSectionBannerView(),

      // Just For You Deals
      const JustForYouView(),

      // Promotional Banner
      const PromotionalBannerView(),
      const SizedBox(height: Dimensions.paddingSizeDefault),
    ]);
  }
}

class _PharmacyPrescriptionHeroCard extends StatelessWidget {
  const _PharmacyPrescriptionHeroCard();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Theme.of(context).cardColor,
                    primaryColor.withOpacity(0.18),
                  ]
                : [
                    primaryColor.withOpacity(0.12),
                    const Color(0xFF00B074).withOpacity(0.06),
                    Theme.of(context).cardColor,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: primaryColor.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services_rounded,
                color: primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'order_with_prescription'.tr.isNotEmpty &&
                            'order_with_prescription'.tr != 'order_with_prescription'
                        ? 'order_with_prescription'.tr
                        : 'اطلب أدويتك بالروشتة',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'capture_prescription_photo'.tr.isNotEmpty &&
                            'capture_prescription_photo'.tr != 'capture_prescription_photo'
                        ? '${'capture_prescription_photo'.tr} - ${'we_will_prepare_it_for_you'.tr}'
                        : 'صوّر الروشتة أو اكتب طلبك والصيدلية هتحضرلك أدويتك',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).disabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            ElevatedButton(
              onPressed: () {
                if (!AuthHelper.isLoggedIn()) {
                  Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                } else {
                  final storeCtrl = Get.find<StoreController>();
                  final stores = storeCtrl.storeModel?.stores ??
                      storeCtrl.recommendedStoreList ??
                      storeCtrl.popularStoreList;
                  final storeId =
                      (stores != null && stores.isNotEmpty) ? stores.first.id : null;
                  Get.toNamed(
                    RouteHelper.getCheckoutRoute('prescription', storeId: storeId),
                    arguments: CheckoutScreen(
                      fromCart: false,
                      cartList: null,
                      storeId: storeId,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'upload'.tr.isNotEmpty && 'upload'.tr != 'upload'
                        ? 'upload'.tr
                        : 'أرفق الآن',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
