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
      backgroundColor: Theme.of(context).colorScheme.surface, // Clean background
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(
          children: [
            // 🚀 1. The Premium Curved Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeExtremeLarge,
                right: Dimensions.paddingSizeExtremeLarge,
                top: 60,
                bottom: Dimensions.paddingSizeExtremeLarge,
              ),
              child: Row(
                children: [
                  // Avatar Box with Glow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: CustomImage(
                        placeholder: Images.guestIconLight,
                        image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                        height: 75,
                        width: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeLarge),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoggedIn && profileController.userInfoModel == null)
                          Shimmer.fromColors(
                            period: const Duration(milliseconds: 2000),
                            baseColor: Colors.white.withOpacity(0.5),
                            highlightColor: Colors.white,
                            child: Container(
                              height: 18, width: 150,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                            ),
                          )
                        else
                          Text(
                            isLoggedIn ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}' : 'guest_user'.tr,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        SizedBox(height: isLoggedIn && profileController.userInfoModel == null ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeExtraSmall),
                        
                        if (isLoggedIn && profileController.userInfoModel == null)
                          Shimmer.fromColors(
                            period: const Duration(milliseconds: 2000),
                            baseColor: Colors.white.withOpacity(0.5),
                            highlightColor: Colors.white,
                            child: Container(
                              height: 14, width: 100,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                            ),
                          )
                        else if (isLoggedIn)
                          Text(
                            profileController.userInfoModel != null ? DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!) : '',
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white.withOpacity(0.8)),
                          )
                        else
                          Text(
                            'welcome_to_our_app'.tr, // رسالة ترحيب خفيفة للـ Guest
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white.withOpacity(0.8)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🚀 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: 100),
                  child: Column(
                    children: [
                      // 🌟 3. THE VIP SIGN-IN CTA (For Guests Only)
                      if (!isLoggedIn)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              if (!ResponsiveHelper.isDesktop(context)) {
                                await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                                if (AuthHelper.isLoggedIn()) {
                                  profileController.getUserInfo();
                                  Get.find<FavouriteController>().getFavouriteList();
                                }
                              } else {
                                Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: true, backFromThis: true)));
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                    child: const Icon(Icons.login_rounded, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeDefault),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('sign_in'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge)),
                                        const SizedBox(height: 4),
                                        Text('login_to_view_all_feature'.tr, style: robotoRegular.copyWith(color: Colors.white.withOpacity(0.9), fontSize: Dimensions.fontSizeSmall)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // 📱 4. Grouped Settings Sections (iOS Style)
                      
                      // -- GENERAL SECTION --
                      _buildMenuCategory(
                        context,
                        title: 'general'.tr,
                        children: [
                          PortionWidget(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
                          PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
                          if (Get.find<SplashController>().proStaus)
                            PortionWidget(icon: Images.proPlanCrown, title: 'my_subscription'.tr, route: RouteHelper.getSubscriptionPlanRoute()),
                          PortionWidget(icon: Images.languageIcon, title: 'language'.tr, hideDivider: true, onTap: () => _manageLanguageFunctionality(), route: ''),
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
                            hideDivider: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 || Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                          ),
                          if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1)
                            PortionWidget(
                              icon: Images.pointIcon,
                              title: 'loyalty_points'.tr,
                              route: RouteHelper.getLoyaltyRoute(),
                              hideDivider: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                              suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                            ),
                          if (Get.find<SplashController>().configModel!.customerWalletStatus == 1)
                            PortionWidget(
                              icon: Images.walletIcon,
                              title: 'my_wallet'.tr,
                              hideDivider: true,
                              route: RouteHelper.getWalletRoute(),
                              suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? profileController.userInfoModel!.walletBalance : 0),
                            ),
                        ],
                      ),

                      // -- EARNINGS / DELIVERY MAN / STORE SECTION --
                      if ((Get.find<SplashController>().configModel!.refEarningStatus == 1) ||
                          (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                          (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)))
                        _buildMenuCategory(
                          context,
                          title: 'earnings'.tr,
                          children: [
                            if (Get.find<SplashController>().configModel!.refEarningStatus == 1)
                              PortionWidget(
                                icon: Images.referIcon,
                                title: 'refer_and_earn'.tr,
                                route: RouteHelper.getReferAndEarnRoute(),
                                hideDivider: ((Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                                        (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context))) ? false : true,
                              ),
                            if (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context))
                              PortionWidget(
                                icon: Images.dmIcon,
                                title: 'join_as_a_delivery_man'.tr,
                                route: RouteHelper.getDeliverymanRegistrationRoute(),
                                hideDivider: (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
                              ),
                            if (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context))
                              PortionWidget(
                                icon: Images.storeIcon,
                                title: 'open_store'.tr,
                                hideDivider: true,
                                route: RouteHelper.getRestaurantRegistrationRoute(),
                              ),
                          ],
                        ),

                      // -- HELP & SUPPORT SECTION --
                      _buildMenuCategory(
                        context,
                        title: 'help_and_support'.tr,
                        children: [
                          PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                          PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                          PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                          PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                          PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
                          if (Get.find<SplashController>().configModel!.refundPolicyStatus == 1)
                            PortionWidget(
                              icon: Images.refundIcon,
                              title: 'refund_policy'.tr,
                              route: RouteHelper.getHtmlRoute('refund-policy'),
                              hideDivider: (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1) || (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1) ? false : true,
                            ),
                          if (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1)
                            PortionWidget(
                              icon: Images.cancelationIcon,
                              title: 'cancellation_policy'.tr,
                              route: RouteHelper.getHtmlRoute('cancellation-policy'),
                              hideDivider: (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1) ? false : true,
                            ),
                          if (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1)
                            PortionWidget(
                              icon: Images.shippingIcon,
                              title: 'shipping_policy'.tr,
                              hideDivider: true,
                              route: RouteHelper.getHtmlRoute('shipping-policy'),
                            ),
                        ],
                      ),

                      // 🔴 5. Modern Logout/SignIn Button (Bottom)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isLoggedIn ? Theme.of(context).colorScheme.error.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: isLoggedIn ? Theme.of(context).colorScheme.error.withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                                  color: isLoggedIn ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                                  size: 22,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(
                                  isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: isLoggedIn ? Theme.of(context).colorScheme.error : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 20),
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
  Widget _buildMenuCategory(BuildContext context, {required String title, required List<Widget> children}) {
    // If the children list is empty or only contains null/SizedBoxes due to conditions, we don't render the category
    if (children.every((element) => element is SizedBox)) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 8, top: 10),
          child: Text(
            title.toUpperCase(),
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor.withOpacity(0.8),
              letterSpacing: 1.2, // لمسة بريميوم
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
          child: Column(children: children),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
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
            topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}