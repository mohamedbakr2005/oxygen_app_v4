import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/wallet/controllers/wallet_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class AddFundDialogueWidget extends StatefulWidget {
  final ScrollController cardScrollController;
  const AddFundDialogueWidget({super.key, required this.cardScrollController});

  @override
  State<AddFundDialogueWidget> createState() => _AddFundDialogueWidgetState();
}

class _AddFundDialogueWidgetState extends State<AddFundDialogueWidget> {
  final TextEditingController inputAmountController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        widget.cardScrollController.jumpTo(50);
      }
    });

    Get.find<WalletController>().isTextFieldEmpty('', isUpdate: false);
    Get.find<WalletController>().changeDigitalPaymentName('', isUpdate: false);

    if (Get.find<SplashController>()
            .configModel!
            .activePaymentMethodList!
            .length ==
        1) {
      Get.find<WalletController>().changeDigitalPaymentName(
          Get.find<SplashController>()
              .configModel!
              .activePaymentMethodList!
              .first
              .getWay!,
          isUpdate: false);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _addQuickAmount(int amount) {
    double current = double.tryParse(inputAmountController.text) ?? 0;
    double next = current + amount;
    setState(() {
      inputAmountController.text = next.toStringAsFixed(0);
      Get.find<WalletController>().isTextFieldEmpty(inputAmountController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: context.width * 0.9,
          constraints: BoxConstraints(
            minHeight: context.height * 0.34,
            maxHeight: context.height * 0.8,
            maxWidth: 500,
          ),
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
          child: GetBuilder<WalletController>(builder: (walletController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with Close Button
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
                          Icons.account_balance_wallet_rounded,
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
                            color: Theme.of(context)
                                .disabledColor
                                .withOpacity(0.15),
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

                  Text(
                    'add_fund_to_wallet'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge + 2,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'add_fund_form_secured_digital_payment_gateways'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),

                  // Amount TextField
                  CustomTextField(
                    hintText: '0',
                    titleText: 'enter_amount'.tr,
                    showLabelText: false,
                    inputType: TextInputType.number,
                    focusNode: focusNode,
                    inputAction: TextInputAction.done,
                    controller: inputAmountController,
                    textAlign: TextAlign.center,
                    isAmount: true,
                    onChanged: (String value) {
                      _checkFormatters(value);
                      try {
                        if (double.parse(value) > 0) {
                          walletController.isTextFieldEmpty(value);
                        }
                      } catch (e) {
                        walletController.isTextFieldEmpty('');
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Quick Amount Chips (+50, +100, +200, +500)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQuickAmountChip('+50', () => _addQuickAmount(50)),
                      const SizedBox(width: 8),
                      _buildQuickAmountChip('+100', () => _addQuickAmount(100)),
                      const SizedBox(width: 8),
                      _buildQuickAmountChip('+200', () => _addQuickAmount(200)),
                      const SizedBox(width: 8),
                      _buildQuickAmountChip('+500', () => _addQuickAmount(500)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Payment method selector header
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'choose_payment_method'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Payment method list
                  ListView.separated(
                    itemCount: Get.find<SplashController>()
                            .configModel
                            ?.activePaymentMethodList
                            ?.length ??
                        0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = Get.find<SplashController>()
                          .configModel!
                          .activePaymentMethodList![index];
                      bool isSelected =
                          item.getWay == walletController.digitalPaymentName;

                      return InkWell(
                        onTap: () {
                          walletController
                              .changeDigitalPaymentName(item.getWay!);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.06)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context)
                                      .disabledColor
                                      .withOpacity(0.2),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                height: 22,
                                width: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF0F7A42)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0F7A42)
                                        : Theme.of(context).disabledColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 15,
                                      )
                                    : null,
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeDefault),
                              CustomImage(
                                height: 24,
                                width: 40,
                                fit: BoxFit.contain,
                                image: '${item.getWayImageFullUrl}',
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: Text(
                                  item.getWayTitle ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Add Fund Action Button
                  CustomButton(
                    radius: Dimensions.radiusDefault,
                    isBold: true,
                    buttonText: 'add_fund'.tr,
                    isLoading: walletController.isLoading,
                    onPressed: () => _onAddFundButtonClicked(walletController),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          style: robotoBold.copyWith(
            fontSize: 12,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  void _checkFormatters(String value) {
    String test = value;
    if (value.contains('-')) {
      test = value.replaceAll('-', '');
    } else if (value.contains(' ')) {
      test = value.replaceAll(' ', '');
    } else if (value.contains(',')) {
      test = value.replaceAll(',', '');
    } else {
      test = value;
    }
    setState(() {
      inputAmountController.text = test;
      inputAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: test.length),
      );
    });
  }

  void _onAddFundButtonClicked(WalletController walletController) {
    if (inputAmountController.text.isEmpty) {
      showCustomSnackBar('please_provide_transfer_amount'.tr);
    } else if (inputAmountController.text == '0') {
      showCustomSnackBar('you_can_not_add_zero_amount_in_wallet'.tr);
    } else if (walletController.digitalPaymentName == '') {
      showCustomSnackBar('please_select_payment_method'.tr);
    } else {
      double amount = double.parse(inputAmountController.text.replaceAll(
          Get.find<SplashController>().configModel!.currencySymbol!, ''));
      walletController.addFundToWallet(
          amount, walletController.digitalPaymentName!);
    }
  }
}
