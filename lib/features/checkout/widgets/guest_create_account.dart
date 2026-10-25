import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuestCreateAccount extends StatelessWidget {
  final TextEditingController? guestPasswordController;
  final TextEditingController? guestConfirmPasswordController;
  final FocusNode? guestPasswordNode;
  final FocusNode? guestConfirmPasswordNode;
  final bool fromParcel;

  const GuestCreateAccount({
    super.key,
    this.guestPasswordController,
    this.guestConfirmPasswordController,
    this.guestPasswordNode,
    this.guestConfirmPasswordNode,
    this.fromParcel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      return Container(
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
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeDefault,
        ),
        child: InkWell(
          onTap: () => checkoutController.toggleCreateAccount(),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: checkoutController.isCreateAccount
                      ? theme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: checkoutController.isCreateAccount
                        ? theme.primaryColor
                        : theme.disabledColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: checkoutController.isCreateAccount
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Text(
                  'create_account_with_existing_info'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

