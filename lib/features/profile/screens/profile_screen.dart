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
        Get.find<SplashController>().configModel?.customerWalletStatus == 1 ||
            Get.find<SplashController>().configModel?.loyaltyPointStatus == 1;

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
                physics: const BouncingScrollPhysics(),
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
                              // 🚀 1. The Premium Gradient Header Background with ambient glow
                              Container(
                                height: 250,
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
                                    bottomLeft: Radius.circular(36),
                                    bottomRight: Radius.circular(36),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).primaryColor.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: -30,
                                      right: -30,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      left: -20,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.06),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 🚀 2. The Screen Content
                              Column(
                                children: [
                                  // Top Bar (Back Button + Title)
                                  SafeArea(
                                    bottom: false,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeLarge,
                                        vertical: Dimensions.paddingSizeSmall,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          !ResponsiveHelper.isDesktop(context)
                                              ? InkWell(
                                                  onTap: () => Get.back(),
                                                  borderRadius: BorderRadius.circular(50),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.18),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.arrow_back_ios_new_rounded,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(width: 40),
                                          Text(
                                            'profile'.tr,
                                            style: robotoBold.copyWith(
                                              fontSize: Dimensions.fontSizeExtraLarge,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 40),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // 🚀 3. The Floating Profile Card
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeLarge,
                                    ),
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(26),
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor.withOpacity(0.08),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 24,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: isLoggedIn
                                        ? _buildLoggedInProfileCard(context, profileController)
                                        : _buildGuestProfileCard(context, profileController),
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeLarge),

                                  // 🚀 4. Metric Stats Row (Loyalty Points, Orders, Wallet)
                                  if (showWalletCard && isLoggedIn && profileController.userInfoModel != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeLarge,
                                      ),
                                      child: Row(
                                        children: [
                                          if (Get.find<SplashController>().configModel?.loyaltyPointStatus == 1) ...[
                                            Expanded(
                                              child: ProfileCardWidget(
                                                image: Images.pointIcon,
                                                data: profileController.userInfoModel!.loyaltyPoint != null
                                                    ? profileController.userInfoModel!.loyaltyPoint.toString()
                                                    : '0',
                                                title: 'loyalty_points'.tr,
                                                onTap: () => Get.toNamed(RouteHelper.getLoyaltyRoute()),
                                              ),
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                          ],
                                          Expanded(
                                            child: ProfileCardWidget(
                                              image: Images.shoppingBagIcon,
                                              data: (profileController.userInfoModel!.orderCount ?? 0).toString(),
                                              title: 'total_order'.tr,
                                              onTap: () => Get.toNamed(RouteHelper.getOrderRoute()),
                                            ),
                                          ),
                                          if (Get.find<SplashController>().configModel?.customerWalletStatus == 1) ...[
                                            const SizedBox(width: Dimensions.paddingSizeSmall),
                                            Expanded(
                                              child: ProfileCardWidget(
                                                image: Images.walletProfile,
                                                data: PriceConverter.convertPrice(
                                                  profileController.userInfoModel!.walletBalance,
                                                ),
                                                title: 'wallet_balance'.tr,
                                                onTap: () => Get.toNamed(RouteHelper.getWalletRoute()),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeLarge),
                                  ],

                                  // 🚀 5. Grouped Settings Section
                                  _buildSectionCard(
                                    context,
                                    title: 'general'.tr,
                                    children: [
                                      // Dark Mode Toggle
                                      ProfileButtonWidget(
                                        icon: Icons.tonality_rounded,
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
                                              1) ...[
                                        _buildDivider(context),
                                        ProfileButtonWidget(
                                          iconImage: Images.monthlyCart,
                                          title: 'monthly_cart_list'.tr,
                                          onTap: () {
                                            Get.to(() => const MyItemsScreen());
                                          },
                                        ),
                                      ],

                                      // My Subscription (If Pro is active)
                                      if (Get.find<SplashController>().proStaus) ...[
                                        _buildDivider(context),
                                        ProfileButtonWidget(
                                          iconImage: Images.proPlanCrown,
                                          title: 'my_subscription'.tr,
                                          color: const Color(0xFFE5A919),
                                          onTap: () {
                                            Get.toNamed(RouteHelper.getSubscriptionPlanRoute());
                                          },
                                        ),
                                      ],

                                      // Notifications
                                      if (isLoggedIn) ...[
                                        _buildDivider(context),
                                        GetBuilder<AuthController>(
                                          builder: (authController) {
                                            return ProfileButtonWidget(
                                              icon: Icons.notifications_active_outlined,
                                              title: 'notification'.tr,
                                              isButtonActive: authController.notification,
                                              onTap: () {
                                                Get.bottomSheet(
                                                  const NotificationStatusChangeBottomSheet(),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeDefault),

                                  // 🚀 6. Security & Account Actions
                                  if (isLoggedIn)
                                    _buildSectionCard(
                                      context,
                                      title: 'account'.tr,
                                      children: [
                                        // Change Password
                                        if (Get.find<SplashController>()
                                                .configModel
                                                ?.centralizeLoginSetup
                                                ?.manualLoginStatus ==
                                            true) ...[
                                          ProfileButtonWidget(
                                            icon: Icons.lock_outline_rounded,
                                            title: 'change_password'.tr,
                                            onTap: () {
                                              Get.toNamed(RouteHelper.getResetPasswordRoute(
                                                phone: '',
                                                email: '',
                                                token: '',
                                                page: 'password-change',
                                              ));
                                            },
                                          ),
                                          _buildDivider(context),
                                        ],

                                        // Delete Account
                                        ProfileButtonWidget(
                                          icon: Icons.delete_outline_rounded,
                                          title: 'delete_account'.tr,
                                          iconImage: Images.profileDelete,
                                          color: Theme.of(context).colorScheme.error,
                                          onTap: () {
                                            Get.dialog(
                                              ConfirmationDialog(
                                                icon: Images.support,
                                                title: 'are_you_sure_to_delete_account'.tr,
                                                description:
                                                    'it_will_remove_your_all_information'.tr,
                                                isLogOut: true,
                                                onYesPressed: () =>
                                                    profileController.deleteUser(),
                                              ),
                                              useSafeArea: false,
                                            );
                                          },
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 60),
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

  // 🪄 Helper: Section Card Container
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault,
              bottom: 4,
            ),
            child: Text(
              title.toUpperCase(),
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Theme.of(context).disabledColor,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // 🪄 Helper: Subtle Divider
  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 64,
      endIndent: Dimensions.paddingSizeDefault,
      color: Theme.of(context).disabledColor.withOpacity(0.12),
    );
  }

  // 🪄 Widget: Logged In Card
  Widget _buildLoggedInProfileCard(
    BuildContext context,
    ProfileController profileController,
  ) {
    final user = profileController.userInfoModel;
    final String fullName = '${user?.fName ?? ''} ${user?.lName ?? ''}'.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with Glowing Accent Border
        ProBadgeAvatarWidget(
          badgeSize: 28,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: CustomImage(
                placeholder: Images.guestIcon,
                image: '${user?.imageFullUrl ?? ''}',
                height: 72,
                width: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),

        // User Identity Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName.isNotEmpty ? fullName : 'user'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge + 1,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                Text(
                  user.phone!,
                  textDirection: TextDirection.ltr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Joined Date Pill
              if (user?.createdAt != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(user!.createdAt!)}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Edit Profile Button
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.edit_outlined,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // 🪄 Widget: Guest Profile Card with VIP CTA
  Widget _buildGuestProfileCard(
    BuildContext context,
    ProfileController profileController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Guest Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withOpacity(0.08),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            Images.guestIcon,
            height: 48,
            width: 48,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(
          'guest_user'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
        ),
        const SizedBox(height: 6),

        Text(
          'login_to_view_all_feature'.tr,
          textAlign: TextAlign.center,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        // VIP Sign-In Button
        InkWell(
          onTap: () async {
            if (!ResponsiveHelper.isDesktop(context)) {
              await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
              if (AuthHelper.isLoggedIn()) {
                profileController.getUserInfo();
              }
            } else {
              Get.dialog(
                const Center(
                  child: AuthDialogWidget(exitFromApp: false, backFromThis: false),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'login'.tr,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}