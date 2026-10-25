import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/loyalty/controllers/loyalty_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class LoyaltyBottomSheetWidget extends StatefulWidget {
  final String amount;
  const LoyaltyBottomSheetWidget({super.key, required this.amount});

  @override
  State<LoyaltyBottomSheetWidget> createState() =>
      _LoyaltyBottomSheetWidgetState();
}

class _LoyaltyBottomSheetWidgetState extends State<LoyaltyBottomSheetWidget> {
  final TextEditingController _amountController = TextEditingController();

  int get exchangePointRate =>
      Get.find<SplashController>().configModel!.loyaltyPointExchangeRate ?? 1;
  int get minimumExchangePoint =>
      Get.find<SplashController>().configModel!.minimumPointToTransfer ?? 0;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount;
  }

  void _setPercentAmount(double fraction) {
    int totalPoints = int.tryParse(widget.amount) ?? 0;
    int calculated = (totalPoints * fraction).floor();
    setState(() {
      _amountController.text = calculated.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentInput = int.tryParse(_amountController.text) ?? 0;
    double estimatedMoney =
        exchangePointRate > 0 ? (currentInput / exchangePointRate) : 0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: ResponsiveHelper.isDesktop(context) ? 420 : context.width * 0.9,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top close button & icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F7A42), Color(0xFF1EA35D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1EA35D).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.currency_exchange_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).disabledColor.withOpacity(0.15),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  'convert_to_wallet_money'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge + 1,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Exchange Rate Preview Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF1EA35D).withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF0F7A42), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$exchangePointRate ${'points'.tr} = ${PriceConverter.convertPrice(1)}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFF0F7A42),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Total convertible points indicator
                Text(
                  '${'available_points'.tr}: ${widget.amount} ${'points'.tr}',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 14),

                // Amount Text Field
                CustomTextField(
                  titleText: 'enter_amount'.tr,
                  hintText: '0',
                  controller: _amountController,
                  inputType: TextInputType.number,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 10),

                // Quick percentage chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPercentChip('25%', () => _setPercentAmount(0.25)),
                    const SizedBox(width: 8),
                    _buildPercentChip('50%', () => _setPercentAmount(0.50)),
                    const SizedBox(width: 8),
                    _buildPercentChip('75%', () => _setPercentAmount(0.75)),
                    const SizedBox(width: 8),
                    _buildPercentChip('100% (${'all'.tr})',
                        () => _setPercentAmount(1.0)),
                  ],
                ),
                const SizedBox(height: 14),

                // Estimated wallet balance conversion result
                if (estimatedMoney > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            Theme.of(context).disabledColor.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'will_receive_in_wallet'.tr}: ',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Text(
                          PriceConverter.convertPrice(estimatedMoney),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: const Color(0xFF0F7A42),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Convert CTA button
                GetBuilder<LoyaltyController>(builder: (walletController) {
                  return CustomButton(
                    radius: Dimensions.radiusDefault,
                    isBold: true,
                    buttonText: 'convert'.tr,
                    isLoading: walletController.isLoading,
                    onPressed: () {
                      if (_amountController.text.trim().isEmpty) {
                        showCustomSnackBar('input_field_is_empty'.tr);
                        return;
                      }
                      int amount =
                          int.tryParse(_amountController.text.trim()) ?? 0;
                      int? point = Get.find<ProfileController>()
                          .userInfoModel
                          ?.loyaltyPoint;

                      if (amount <= 0) {
                        showCustomSnackBar('input_field_is_empty'.tr);
                      } else if (amount < minimumExchangePoint) {
                        if (Get.isBottomSheetOpen ?? false) Get.back();
                        showCustomSnackBar(
                            '${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                      } else if ((point ?? 0) < amount) {
                        if (Get.isBottomSheetOpen ?? false) Get.back();
                        showCustomSnackBar(
                            'you_do_not_have_enough_point_to_exchange'.tr);
                      } else {
                        walletController.pointToWallet(amount);
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 11,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
