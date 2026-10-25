import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class WalletCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const WalletCardWidget({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final ScrollController cardScrollController = ScrollController();

    return GetBuilder<ProfileController>(builder: (profileController) {
      double balance = profileController.userInfoModel?.walletBalance ?? 0.0;
      bool canAddFund = Get.find<SplashController>().configModel?.addFundStatus == true &&
          Get.find<SplashController>().configModel?.digitalPayment == true;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isDesktop
              ? const SizedBox()
              : const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0A582C),
                  Color(0xFF0F7A42),
                  Color(0xFF1EA35D),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F7A42).withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Decorative background elements
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: -20,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 60,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),

                  // Main card content
                  Padding(
                    padding: EdgeInsets.all(
                        isDesktop ? 30 : Dimensions.paddingSizeLarge + 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Wallet chip label & Add fund button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'wallet_amount'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (canAddFund)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Get.dialog(
                                      Dialog(
                                        backgroundColor: Colors.transparent,
                                        surfaceTintColor: Colors.transparent,
                                        child: SizedBox(
                                          width: 500,
                                          child: SingleChildScrollView(
                                            controller: cardScrollController,
                                            child: AddFundDialogueWidget(
                                              cardScrollController:
                                                  cardScrollController,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add_circle_rounded,
                                          color: Color(0xFF0F7A42),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'add_fund'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: const Color(0xFF0F7A42),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Balance display & Info tooltip
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              PriceConverter.convertPrice(balance),
                              style: robotoBold.copyWith(
                                fontSize: 32,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            if (canAddFund)
                              JustTheTooltip(
                                backgroundColor: Colors.black87,
                                controller: tooltipController,
                                preferredDirection: AxisDirection.right,
                                tailLength: 14,
                                tailBaseWidth: 20,
                                content: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'if_you_want_to_add_fund_to_your_wallet_then_click_add_fund_button'
                                        .tr,
                                    style: robotoRegular.copyWith(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => tooltipController.showTooltip(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Card Subtitle / Secure tag
                        Row(
                          children: [
                            Container(
                              height: 6,
                              width: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF69E79B),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'oxygen_mart_wallet'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall + 1,
                                color: Colors.white.withOpacity(0.75),
                                letterSpacing: 0.3,
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
          isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(height: Dimensions.paddingSizeSmall),
          if (isDesktop) ...[
            Text('how_to_use'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            const WalletStepper(),
          ],
        ],
      );
    });
  }
}

class WalletStepper extends StatelessWidget {
  const WalletStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).disabledColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          _buildStepItem(
            context,
            Icons.card_giftcard_rounded,
            'earn_money_to_your_wallet_by_completing_the_offer_challenged'.tr,
          ),
          const Divider(height: 20),
          _buildStepItem(
            context,
            Icons.stars_rounded,
            'convert_your_loyalty_points_into_wallet_money'.tr,
          ),
          const Divider(height: 20),
          _buildStepItem(
            context,
            Icons.workspace_premium_rounded,
            'amin_also_reward_their_top_customers_with_wallet_money'.tr,
          ),
          const Divider(height: 20),
          _buildStepItem(
            context,
            Icons.shopping_bag_rounded,
            'send_your_wallet_money_while_order'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Text(
            title,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ),
      ],
    );
  }
}

