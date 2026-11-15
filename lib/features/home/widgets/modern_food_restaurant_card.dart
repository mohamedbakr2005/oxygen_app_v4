import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ModernFoodRestaurantCard extends StatelessWidget {
  final Store store;

  const ModernFoodRestaurantCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Check Open / Closed Status
    bool isOpen = false;
    try {
      isOpen = Get.find<StoreController>().isOpenNow(store);
    } catch (_) {
      isOpen = store.open == 1 && (store.active ?? true);
    }

    // Distance Calculation
    double distanceKm = 0;
    if (store.distance != null) {
      distanceKm = store.distance! / 1000;
    } else if (store.latitude != null && store.longitude != null) {
      try {
        final userAddress = AddressHelper.getUserAddressFromSharedPref();
        if (userAddress?.latitude != null && userAddress?.longitude != null) {
          distanceKm = Geolocator.distanceBetween(
                double.parse(store.latitude!),
                double.parse(store.longitude!),
                double.parse(userAddress!.latitude!),
                double.parse(userAddress.longitude!),
              ) /
              1000;
        }
      } catch (_) {}
    }

    // Discount / Offer Text
    double discount = store.discount?.discount ?? 0;
    String discountType = store.discount?.discountType ?? 'percent';
    String? offerText;
    bool isFreeDelivery = store.freeDelivery == true;

    if (isFreeDelivery) {
      offerText = 'free_delivery'.tr;
    } else if (discount > 0) {
      offerText = discountType == 'percent'
          ? '${discount.toInt()}% ${'off'.tr}'
          : '${discount.toInt()} ${Get.find<SplashController>().configModel?.currencySymbol ?? 'ج.م'} ${'off'.tr}';
    } else if (store.offerLabel != null && store.offerLabel!.isNotEmpty) {
      offerText = store.offerLabel;
    }

    // Delivery Time Text
    String deliveryTimeText = '25-35 دقيقة';
    if (store.deliveryTime != null && store.deliveryTime!.isNotEmpty) {
      deliveryTimeText = '${store.deliveryTime} دقيقة';
    } else if (store.minDeliveryTime != null && store.maxDeliveryTime != null) {
      deliveryTimeText = '${store.minDeliveryTime}-${store.maxDeliveryTime} دقيقة';
    }

    // Rating
    double rating = store.avgRating ?? 0.0;
    int ratingCount = store.ratingCount ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.disabledColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (Get.find<SplashController>().moduleList != null) {
                for (ModuleModel module in Get.find<SplashController>().moduleList!) {
                  if (module.id == store.moduleId) {
                    Get.find<SplashController>().setModule(module);
                    break;
                  }
                }
              }
              Get.toNamed(
                RouteHelper.getStoreRoute(id: store.id, page: 'item'),
                arguments: StoreScreen(store: store, fromModule: false),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cover Image & Floating Badges ──
                Stack(
                  children: [
                    CustomImage(
                      image: (store.coverPhotoFullUrl != null && store.coverPhotoFullUrl!.isNotEmpty)
                          ? store.coverPhotoFullUrl!
                          : (store.logoFullUrl ?? ''),
                      height: 175,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.60),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Row: Offer Badge & Favorite Button
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Offer Badge
                          offerText != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isFreeDelivery
                                          ? [const Color(0xFF059669), const Color(0xFF10B981)]
                                          : [const Color(0xFFDC2626), const Color(0xFFF97316)],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isFreeDelivery
                                            ? Icons.electric_bolt_rounded
                                            : Icons.local_offer_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        offerText,
                                        style: robotoBold.copyWith(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : (store.isNew == true
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        'new'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : const SizedBox()),

                          // Favorite Heart Button
                          GetBuilder<FavouriteController>(
                            builder: (favouriteController) {
                              bool isWished =
                                  favouriteController.wishStoreIdList.contains(store.id);
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (AuthHelper.isLoggedIn()) {
                                      if (isWished) {
                                        favouriteController.removeFromFavouriteList(store.id, true);
                                      } else {
                                        favouriteController.addToFavouriteList(null, store.id, true);
                                      }
                                    } else {
                                      showCustomSnackBar('you_are_not_logged_in'.tr);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      isWished
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isWished ? const Color(0xFFFF3366) : Colors.white,
                                      size: 19,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Bottom Floating Row: Delivery Time & Distance
                    Positioned(
                      bottom: 12,
                      right: 12,
                      left: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Delivery Time Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.clock_fill,
                                  size: 12,
                                  color: Color(0xFFFBBF24),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  deliveryTimeText,
                                  style: robotoBold.copyWith(
                                    fontSize: 11.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Distance Pill
                          if (distanceKm > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 12,
                                    color: Color(0xFF60A5FA),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${distanceKm.toStringAsFixed(1)} ${'km'.tr}',
                                    style: robotoBold.copyWith(
                                      fontSize: 11.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Closed Overlay
                    if (!isOpen)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white30, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock_clock_rounded,
                                    color: Colors.amberAccent,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'closed_now'.tr,
                                    style: robotoBold.copyWith(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Card Body (Details) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Logo, Name & Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Restaurant Logo Squircle
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: theme.disabledColor.withValues(alpha: 0.15),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CustomImage(
                                image: store.logoFullUrl ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Name & Verified Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        store.name ?? '',
                                        style: robotoBold.copyWith(
                                          fontSize: 16,
                                          color: theme.textTheme.bodyLarge!.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (store.verifiedSeller == 1) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),

                                // Address or Cuisine
                                Row(
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 13,
                                      color: theme.hintColor.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        store.address ?? 'أشهى المأكولات والوجبات',
                                        style: robotoRegular.copyWith(
                                          fontSize: 12,
                                          color: theme.hintColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Rating Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFDE68A),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  rating > 0 ? rating.toStringAsFixed(1) : 'جديد',
                                  style: robotoBold.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                if (ratingCount > 0)
                                  Text(
                                    ' ($ratingCount)',
                                    style: robotoRegular.copyWith(
                                      fontSize: 10,
                                      color: const Color(0xFFD97706),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          thickness: 0.8,
                          color: theme.disabledColor.withValues(alpha: 0.1),
                        ),
                      ),

                      // Bottom Info Row: Status, Delivery & CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Status Dot
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOpen
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isOpen ? 'مفتوح للطلب' : 'مغلق',
                                style: robotoMedium.copyWith(
                                  fontSize: 12,
                                  color: isOpen
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: theme.disabledColor.withValues(alpha: 0.6),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Delivery Fee Indicator
                              Text(
                                isFreeDelivery ? 'free_delivery'.tr : 'توصيل متاح',
                                style: robotoRegular.copyWith(
                                  fontSize: 12,
                                  color: isFreeDelivery
                                      ? const Color(0xFF059669)
                                      : theme.hintColor,
                                ),
                              ),
                            ],
                          ),

                          // CTA Pill Button
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'عرض القائمة',
                                  style: robotoBold.copyWith(
                                    fontSize: 11,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 9,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
