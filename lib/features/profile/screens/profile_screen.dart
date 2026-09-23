import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/confirmation_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:Oxygen_Mart/features/order/screens/my_items_screen.dart';
import 'package:Oxygen_Mart/features/pro/widgets/pro_badge_avatar_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/profile/widgets/profile_button_widget.dart';
import 'package:Oxygen_Mart/features/profile/widgets/profile_card_widget.dart';
import 'package:Oxygen_Mart/features/profile/widgets/web_profile_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showWalletCard =
        Get.find<SplashController>().configModel!.customerWalletStatus == 1 ||
            Get.find<SplashController>().configModel!.loyaltyPointStatus == 1;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      key: UniqueKey(),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        bool isLoggedIn = AuthHelper.isLoggedIn();
        return (isLoggedIn && profileController.userInfoModel == null)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(), // لمسة نعومة في السكرول
                child: FooterView(
                  minHeight: isLoggedIn
                      ? ResponsiveHelper.isDesktop(context)
                          ? 0.4
                          : 0.6
                      : 0.35,
                  child: (isLoggedIn && ResponsiveHelper.isDesktop(context))
                      ? const WebProfileWidget()
                      : SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Stack(
                            children: [
                              // 🚀 1. The Premium Gradient Header Background
                              Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).primaryColor.withOpacity(0.75),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                ),
                              ),

                              // 🚀 2. The Content
                              Column(
                                children: [
                                  // Top Bar (Back Button + Title)
                                  SafeArea(
                                    bottom: false,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Dimensions.paddingSizeLarge,
                                          vertical: Dimensions.paddingSizeSmall),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          !ResponsiveHelper.isDesktop(context)
                                              ? IconButton(
                                                  onPressed: () => Get.back(),
                                                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                                )
                                              : const SizedBox(width: 48),
                                          Text(
                                            'profile'.tr,
                                            style: robotoBold.copyWith(
                                                fontSize: Dimensions.fontSizeLarge,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(width: 48), // Balancing space
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 10),

                                  // 🚀 3. The Floating Profile/Guest Card
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: isLoggedIn
                                        ? _buildLoggedInProfileCard(context, profileController)
                                        : _buildGuestProfileCard(context, profileController),
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                  // 🚀 4. Wallet & Orders Section (If logged in)
                                  if (showWalletCard && isLoggedIn)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                      child: Row(
                                        children: [
                                          if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1)
                                            Expanded(
                                              child: ProfileCardWidget(
                                                image: Images.loyaltyIcon,
                                                data: profileController.userInfoModel!.loyaltyPoint != null
                                                    ? profileController.userInfoModel!.loyaltyPoint.toString()
                                                    : '0',
                                                title: 'loyalty_points'.tr,
                                              ),
                                            ),
                                          if (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 &&
                                              Get.find<SplashController>().configModel!.customerWalletStatus == 1)
                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                          Expanded(
                                            child: ProfileCardWidget(
                                              image: Images.shoppingBagIcon,
                                              data: profileController.userInfoModel!.orderCount.toString(),
                                              title: 'total_order'.tr,
                                            ),
                                          ),
                                          if (Get.find<SplashController>().configModel!.customerWalletStatus == 1)
                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                          if (Get.find<SplashController>().configModel!.customerWalletStatus == 1)
                                            Expanded(
                                              child: ProfileCardWidget(
                                                image: Images.walletProfile,
                                                data: PriceConverter.convertPrice(profileController.userInfoModel!.walletBalance),
                                                title: 'wallet_balance'.tr,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                  if (showWalletCard && isLoggedIn)
                                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                  // 🚀 5. Grouped Settings Section (iOS Style)
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
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
                                    child: Column(
                                      children: [
                                        // Dark Mode
                                        ProfileButtonWidget(
                                          icon: Icons.tonality_outlined,
                                          title: 'dark_mode'.tr,
                                          isButtonActive: Get.isDarkMode,
                                          onTap: () {
                                            Get.find<ThemeController>().toggleTheme();
                                          },
                                        ),

                                        // Monthly Cart List (If logged in & enabled)
                                        if (isLoggedIn &&
                                            Get.find<SplashController>()
                                                    .configModel
                                                    ?.monthlyOrderRemainder ==
                                                1)
                                          ProfileButtonWidget(
                                            iconImage: Images.monthlyCart,
                                            title: 'monthly_cart_list'.tr,
                                            onTap: () {
                                              Get.to(() => const MyItemsScreen());
                                            },
                                          ),

                                        // My Subscription (If Pro is active)
                                        if (Get.find<SplashController>().proStaus)
                                          ProfileButtonWidget(
                                            iconImage: Images.proPlanCrown,
                                            title: 'my_subscription'.tr,
                                            onTap: () {
                                              Get.toNamed(RouteHelper.getSubscriptionPlanRoute());
                                            },
                                          ),
                                        
                                        // Notifications (If logged in)
                                        if (isLoggedIn)
                                          GetBuilder<AuthController>(
                                            builder: (authController) {
                                              return ProfileButtonWidget(
                                                icon: Icons.notifications,
                                                title: 'notification'.tr,
                                                isButtonActive: authController.notification,
                                                onTap: () {
                                                  Get.bottomSheet(const NotificationStatusChangeBottomSheet());
                                                },
                                              );
                                            },
                                          ),

                                        // Change Password (If logged in & allowed)
                                        if (isLoggedIn && Get.find<SplashController>().configModel!.centralizeLoginSetup!.manualLoginStatus!)
                                          ProfileButtonWidget(
                                            icon: Icons.lock,
                                            title: 'change_password'.tr,
                                            onTap: () {
                                              Get.toNamed(RouteHelper.getResetPasswordRoute(phone: '', email: '', token: '', page: 'password-change'));
                                            },
                                          ),

                                        // Delete Account (If logged in)
                                        if (isLoggedIn)
                                          ProfileButtonWidget(
                                            icon: Icons.delete,
                                            title: 'delete_account'.tr,
                                            iconImage: Images.profileDelete,
                                            color: Theme.of(context).colorScheme.error,
                                            onTap: () {
                                              Get.dialog(
                                                ConfirmationDialog(
                                                  icon: Images.support,
                                                  title: 'are_you_sure_to_delete_account'.tr,
                                                  description: 'it_will_remove_your_all_information'.tr,
                                                  isLogOut: true,
                                                  onYesPressed: () => profileController.deleteUser(),
                                                ),
                                                useSafeArea: false,
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 50), // Bottom padding
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              );
      }),
    );
  }

  // 🪄 Widget: Logged In Card 
  Widget _buildLoggedInProfileCard(BuildContext context, ProfileController profileController) {
    return Row(
      children: [
        ProBadgeAvatarWidget(
          badgeSize: 28,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2), width: 3),
            ),
            child: ClipOval(
              child: CustomImage(
                placeholder: Images.guestIcon,
                image: '${profileController.userInfoModel?.imageFullUrl ?? ''}',
                height: 75,
                width: 75,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                '${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!)}',
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Icon(Icons.edit_outlined, size: 24, color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  // 🪄 Widget: The Afsh5 Guest Card with Big CTA
  Widget _buildGuestProfileCard(BuildContext context, ProfileController profileController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Guest Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).disabledColor.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(15),
          child: Image.asset(Images.guestIcon, height: 50, width: 50, color: Theme.of(context).disabledColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Text(
          'guest_user'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(
          'login_to_view_all_feature'.tr,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        
        // 🚀 Massive Premium Sign-In Button
        InkWell(
          onTap: () async {
            if (!ResponsiveHelper.isDesktop(context)) {
              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
              if (AuthHelper.isLoggedIn()) {
                profileController.getUserInfo();
              }
            } else {
              Get.dialog(const Center(
                  child: AuthDialogWidget(exitFromApp: false, backFromThis: false)));
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'login'.tr,
                  style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}