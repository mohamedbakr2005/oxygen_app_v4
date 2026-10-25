import 'package:Oxygen_Mart/common/widgets/confirmation_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/menu/widgets/portion_widget.dart';
import 'package:Oxygen_Mart/features/pro/widgets/pro_badge_avatar_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();
        final bool showWallet =
            Get.find<SplashController>().configModel?.customerWalletStatus == 1;
        final bool showLoyalty =
            Get.find<SplashController>().configModel?.loyaltyPointStatus == 1;

        return Column(
          children: [
            // 🚀 1. The Premium Hero Header with Glow and Background Details
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.82),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Ambient Circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),

                  // Header Content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeLarge,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeLarge,
                        Dimensions.paddingSizeLarge,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Avatar Box with Glow
                              ProBadgeAvatarWidget(
                                badgeSize: 26,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.6),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: ClipOval(
                                    child: CustomImage(
                                      placeholder: Images.guestIconLight,
                                      image:
                                          '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                                      height: 68,
                                      width: 68,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              // User Name & Subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isLoggedIn &&
                                        profileController.userInfoModel == null)
                                      Shimmer.fromColors(
                                        period: const Duration(milliseconds: 1500),
                                        baseColor: Colors.white.withOpacity(0.4),
                                        highlightColor: Colors.white.withOpacity(0.9),
                                        child: Container(
                                          height: 18,
                                          width: 140,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        isLoggedIn
                                            ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}'
                                                .trim()
                                            : 'guest_user'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge + 2,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                    const SizedBox(height: 5),

                                    if (isLoggedIn &&
                                        profileController.userInfoModel == null)
                                      Shimmer.fromColors(
                                        period: const Duration(milliseconds: 1500),
                                        baseColor: Colors.white.withOpacity(0.3),
                                        highlightColor: Colors.white.withOpacity(0.8),
                                        child: Container(
                                          height: 13,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      )
                                    else if (isLoggedIn &&
                                        profileController.userInfoModel?.createdAt !=
                                            null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!)}',
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                            color: Colors.white.withOpacity(0.95),
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        'welcome_to_our_app'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Colors.white.withOpacity(0.85),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Edit Profile shortcut (If Logged In)
                              if (isLoggedIn)
                                InkWell(
                                  onTap: () => Get.toNamed(
                                      RouteHelper.getUpdateProfileRoute()),
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // 🚀 2. Quick Wallet & Loyalty Highlight Bar (Logged In only)
                          if (isLoggedIn &&
                              profileController.userInfoModel != null &&
                              (showWallet || showLoyalty)) ...[
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (showWallet)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Get.toNamed(
                                            RouteHelper.getWalletRoute()),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.25),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.account_balance_wallet_outlined,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'wallet_balance'.tr,
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                      profileController
                                                          .userInfoModel
                                                          ?.walletBalance,
                                                    ),
                                                    style: robotoBold.copyWith(
                                                      fontSize:
                                                          Dimensions.fontSizeSmall,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (showWallet && showLoyalty)
                                    Container(
                                      height: 28,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  if (showLoyalty)
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => Get.toNamed(
                                            RouteHelper.getLoyaltyRoute()),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.25),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.stars_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'loyalty_points'.tr,
                                                    style: robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeExtraSmall,
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${profileController.userInfoModel?.loyaltyPoint ?? 0} ${'points'.tr}',
                                                    style: robotoBold.copyWith(
                                                      fontSize:
                                                          Dimensions.fontSizeSmall,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🚀 3. Scrollable Grouped Categories
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: Dimensions.paddingSizeDefault,
                    bottom: 110,
                  ),
                  child: Column(
                    children: [
                      // 🌟 VIP SIGN-IN CTA (For Guests Only)
                      if (!isLoggedIn)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () async {
                              if (!ResponsiveHelper.isDesktop(context)) {
                                await Get.toNamed(
                                    RouteHelper.getSignInRoute(Get.currentRoute));
                                if (AuthHelper.isLoggedIn()) {
                                  profileController.getUserInfo();
                                  Get.find<FavouriteController>()
                                      .getFavouriteList();
                                }
                              } else {
                                Get.dialog(const Center(
                                    child: AuthDialogWidget(
                                        exitFromApp: true,
                                        backFromThis: true)));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: Dimensions.paddingSizeDefault),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.75),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.login_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'sign_in'.tr,
                                          style: robotoBold.copyWith(
                                            color: Colors.white,
                                            fontSize: Dimensions.fontSizeLarge,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'login_to_view_all_feature'.tr,
                                          style: robotoRegular.copyWith(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: Dimensions.fontSizeSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // 📱 4. Grouped Settings Sections

                      // -- GENERAL SECTION --
                      _buildMenuCategory(
                        context,
                        title: 'general'.tr,
                        children: [
                          PortionWidget(
                            icon: Images.profileIcon,
                            title: 'profile'.tr,
                            route: RouteHelper.getProfileRoute(),
                            iconColor: Theme.of(context).primaryColor,
                          ),
                          PortionWidget(
                            icon: Images.addressIcon,
                            title: 'my_address'.tr,
                            route: RouteHelper.getAddressRoute(),
                            iconColor: const Color(0xFF4A68FF),
                          ),
                          if (Get.find<SplashController>().proStaus)
                            PortionWidget(
                              icon: Images.proPlanCrown,
                              title: 'my_subscription'.tr,
                              route: RouteHelper.getSubscriptionPlanRoute(),
                              iconColor: const Color(0xFFE5A919),
                            ),
                          GetBuilder<LocalizationController>(
                            builder: (locController) {
                              return PortionWidget(
                                icon: Images.languageIcon,
                                title: 'language'.tr,
                                hideDivider: true,
                                iconColor: const Color(0xFF00B2A9),
                                suffix: locController.locale.languageCode.toUpperCase(),
                                suffixColor: const Color(0xFF00B2A9),
                                onTap: () => _manageLanguageFunctionality(),
                                route: '',
                              );
                            },
                          ),
                        ],
                      ),

                      // -- PROMOTIONAL ACTIVITY SECTION --
                      _buildMenuCategory(
                        context,
                        title: 'promotional_activity'.tr,
                        children: [
                          PortionWidget(
                            icon: Images.couponIcon,
                            title: 'coupon'.tr,
                            route: RouteHelper.getCouponRoute(),
                            iconColor: const Color(0xFFFF7A00),
                            hideDivider: !(showLoyalty || showWallet),
                          ),
                          if (showLoyalty)
                            PortionWidget(
                              icon: Images.pointIcon,
                              title: 'loyalty_points'.tr,
                              route: RouteHelper.getLoyaltyRoute(),
                              iconColor: const Color(0xFFE5A919),
                              hideDivider: !showWallet,
                              suffix: !isLoggedIn
                                  ? null
                                  : '${profileController.userInfoModel?.loyaltyPoint ?? 0} ${'points'.tr}',
                              suffixColor: const Color(0xFFE5A919),
                            ),
                          if (showWallet)
                            PortionWidget(
                              icon: Images.walletIcon,
                              title: 'my_wallet'.tr,
                              hideDivider: true,
                              iconColor: const Color(0xFF00A86B),
                              route: RouteHelper.getWalletRoute(),
                              suffix: !isLoggedIn
                                  ? null
                                  : PriceConverter.convertPrice(
                                      profileController.userInfoModel?.walletBalance ?? 0,
                                    ),
                              suffixColor: const Color(0xFF00A86B),
                            ),
                        ],
                      ),

                      // -- EARNINGS / DELIVERY MAN / STORE SECTION --
                      if ((Get.find<SplashController>().configModel?.refEarningStatus == 1) ||
                          (Get.find<SplashController>().configModel?.toggleDmRegistration == true &&
                              !ResponsiveHelper.isDesktop(context)) ||
                          (Get.find<SplashController>().configModel?.toggleStoreRegistration == true &&
                              !ResponsiveHelper.isDesktop(context)))
                        _buildMenuCategory(
                          context,
                          title: 'earnings'.tr,
                          children: [
                            if (Get.find<SplashController>().configModel?.refEarningStatus == 1)
                              PortionWidget(
                                icon: Images.referIcon,
                                title: 'refer_and_earn'.tr,
                                route: RouteHelper.getReferAndEarnRoute(),
                                iconColor: const Color(0xFF8E44AD),
                                hideDivider: ((Get.find<SplashController>().configModel?.toggleDmRegistration == true &&
                                            !ResponsiveHelper.isDesktop(context)) ||
                                        (Get.find<SplashController>().configModel?.toggleStoreRegistration == true &&
                                            !ResponsiveHelper.isDesktop(context)))
                                    ? false
                                    : true,
                              ),
                            if (Get.find<SplashController>().configModel?.toggleDmRegistration == true &&
                                !ResponsiveHelper.isDesktop(context))
                              PortionWidget(
                                icon: Images.dmIcon,
                                title: 'join_as_a_delivery_man'.tr,
                                route: RouteHelper.getDeliverymanRegistrationRoute(),
                                iconColor: const Color(0xFF2980B9),
                                hideDivider: (Get.find<SplashController>().configModel?.toggleStoreRegistration == true &&
                                        !ResponsiveHelper.isDesktop(context))
                                    ? false
                                    : true,
                              ),
                            if (Get.find<SplashController>().configModel?.toggleStoreRegistration == true &&
                                !ResponsiveHelper.isDesktop(context))
                              PortionWidget(
                                icon: Images.storeIcon,
                                title: 'open_store'.tr,
                                hideDivider: true,
                                iconColor: const Color(0xFF16A085),
                                route: RouteHelper.getRestaurantRegistrationRoute(),
                              ),
                          ],
                        ),

                      // -- HELP & SUPPORT SECTION --
                      _buildMenuCategory(
                        context,
                        title: 'help_and_support'.tr,
                        children: [
                          PortionWidget(
                            icon: Images.chatIcon,
                            title: 'live_chat'.tr,
                            route: RouteHelper.getConversationRoute(),
                            iconColor: const Color(0xFF0288D1),
                          ),
                          PortionWidget(
                            icon: Images.helpIcon,
                            title: 'help_and_support'.tr,
                            route: RouteHelper.getSupportRoute(),
                            iconColor: const Color(0xFF2E7D32),
                          ),
                          PortionWidget(
                            icon: Images.aboutIcon,
                            title: 'about_us'.tr,
                            route: RouteHelper.getHtmlRoute('about-us'),
                            iconColor: const Color(0xFF5C6BC0),
                          ),
                          PortionWidget(
                            icon: Images.termsIcon,
                            title: 'terms_conditions'.tr,
                            route: RouteHelper.getHtmlRoute('terms-and-condition'),
                            iconColor: const Color(0xFF78909C),
                          ),
                          PortionWidget(
                            icon: Images.privacyIcon,
                            title: 'privacy_policy'.tr,
                            route: RouteHelper.getHtmlRoute('privacy-policy'),
                            iconColor: const Color(0xFF78909C),
                            hideDivider: (Get.find<SplashController>().configModel?.refundPolicyStatus == 1 ||
                                    Get.find<SplashController>().configModel?.cancellationPolicyStatus == 1 ||
                                    Get.find<SplashController>().configModel?.shippingPolicyStatus == 1)
                                ? false
                                : true,
                          ),
                          if (Get.find<SplashController>().configModel?.refundPolicyStatus == 1)
                            PortionWidget(
                              icon: Images.refundIcon,
                              title: 'refund_policy'.tr,
                              route: RouteHelper.getHtmlRoute('refund-policy'),
                              iconColor: const Color(0xFF78909C),
                              hideDivider: (Get.find<SplashController>().configModel?.cancellationPolicyStatus == 1 ||
                                      Get.find<SplashController>().configModel?.shippingPolicyStatus == 1)
                                ? false
                                : true,
                            ),
                          if (Get.find<SplashController>().configModel?.cancellationPolicyStatus == 1)
                            PortionWidget(
                              icon: Images.cancelationIcon,
                              title: 'cancellation_policy'.tr,
                              route: RouteHelper.getHtmlRoute('cancellation-policy'),
                              iconColor: const Color(0xFF78909C),
                              hideDivider: Get.find<SplashController>().configModel?.shippingPolicyStatus == 1
                                  ? false
                                  : true,
                            ),
                          if (Get.find<SplashController>().configModel?.shippingPolicyStatus == 1)
                            PortionWidget(
                              icon: Images.shippingIcon,
                              title: 'shipping_policy'.tr,
                              hideDivider: true,
                              iconColor: const Color(0xFF78909C),
                              route: RouteHelper.getHtmlRoute('shipping-policy'),
                            ),
                        ],
                      ),

                      // 🔴 5. Modern Logout / SignIn Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeLarge,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            if (AuthHelper.isLoggedIn()) {
                              Get.dialog(
                                ConfirmationDialog(
                                  icon: Images.support,
                                  description: 'are_you_sure_to_logout'.tr,
                                  isLogOut: true,
                                  onYesPressed: () async {
                                    Get.find<AuthController>().resetOtpView();
                                    Get.find<ProfileController>().clearUserInfo();
                                    Get.find<AuthController>().socialLogout();
                                    Get.find<CartController>().clearCartList();
                                    Get.find<FavouriteController>().removeFavourite();
                                    await Get.find<AuthController>().clearSharedData();
                                    Get.find<HomeController>().forcefullyNullCashBackOffers();
                                    Get.back();
                                    showCustomSnackBar('logout_successful'.tr, isError: false);
                                  },
                                ),
                                useSafeArea: false,
                              );
                            } else {
                              Get.find<FavouriteController>().removeFavourite();
                              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                              if (AuthHelper.isLoggedIn()) {
                                await Get.find<FavouriteController>().getFavouriteList();
                                profileController.getUserInfo();
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: isLoggedIn
                                  ? Theme.of(context).colorScheme.error.withOpacity(0.08)
                                  : Theme.of(context).primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isLoggedIn
                                    ? Theme.of(context).colorScheme.error.withOpacity(0.25)
                                    : Theme.of(context).primaryColor.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                                  color: isLoggedIn
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(
                                  isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault + 1,
                                    color: isLoggedIn
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.isDesktop(context)
                            ? Dimensions.paddingSizeExtremeLarge
                            : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // 🪄 Helper Method for Premium Menu Categories
  Widget _buildMenuCategory(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    if (children.every((element) => element is SizedBox)) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 16),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 15,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault, // 14px instead of extra small 10px
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  // -------------------- Helpers --------------------

  _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
          Get.find<LocalizationController>().getCacheLocaleFromSharedPref(),
        ));
  }
}