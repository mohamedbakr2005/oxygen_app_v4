import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OrderLoginPromptWidget extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onLoginSuccess;

  const OrderLoginPromptWidget({
    super.key,
    required this.isRunning,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeExtraLarge,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🌟 1. Glowing Icon Container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.18),
                      theme.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      isRunning
                          ? Icons.local_shipping_rounded
                          : Icons.receipt_long_rounded,
                      size: 34,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              // 🏷️ 2. Header Title
              Text(
                'login_to_track_orders_title'.tr,
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: theme.textTheme.bodyLarge?.color,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // 📝 3. Persuasive Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeSmall,
                ),
                child: Text(
                  'login_to_track_orders_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.disabledColor,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // 🎁 4. Features & Benefits Card
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.disabledColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _BenefitItem(
                      icon: Icons.gps_fixed_rounded,
                      title: 'benefit_live_tracking_title'.tr,
                      subtitle: 'benefit_live_tracking_subtitle'.tr,
                    ),
                    Divider(
                      height: Dimensions.paddingSizeLarge,
                      thickness: 0.8,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    _BenefitItem(
                      icon: Icons.history_rounded,
                      title: 'benefit_order_history_title'.tr,
                      subtitle: 'benefit_order_history_subtitle'.tr,
                    ),
                    Divider(
                      height: Dimensions.paddingSizeLarge,
                      thickness: 0.8,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    _BenefitItem(
                      icon: Icons.card_giftcard_rounded,
                      title: 'benefit_exclusive_perks_title'.tr,
                      subtitle: 'benefit_exclusive_perks_subtitle'.tr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              // 🚀 5. Primary Login / Register Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  buttonText: 'login_or_register_now'.tr,
                  icon: Icons.login_rounded,
                  radius: 16,
                  height: 48,
                  isBold: true,
                  onPressed: () => _handleLogin(context, isDesktop),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              // ↩️ 6. Secondary Action (Back to Cart Tab)
              TextButton.icon(
                onPressed: () {
                  Get.find<CartController>().setSelectedFlowTab(0);
                },
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: theme.primaryColor,
                ),
                label: Text(
                  'continue_browsing_cart'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: theme.primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context, bool isDesktop) async {
    if (!isDesktop) {
      await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
    } else {
      await Get.dialog(
        const Center(
          child: AuthDialogWidget(exitFromApp: false, backFromThis: true),
        ),
        barrierDismissible: false,
      );
    }
    if (AuthHelper.isLoggedIn()) {
      onLoginSuccess();
    }
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: theme.disabledColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
