import 'dart:io';

import 'package:Oxygen_Mart/common/models/config_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_dropdown.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/widgets/delivery_option_button_widget.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/coupon_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/delivery_instruction_view.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/delivery_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/deliveryman_tips_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/guest_create_account.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/partial_pay_view.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/payment_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/prescription_image_picker_widget.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/saver_delivery_time_widget.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/time_slot_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/web_delivery_instruction_view.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/widgets/camera_button_sheet_widget.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class TopSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final double charge;
  final double deliveryCharge;
  final List<DropdownItem<int>> addressList;
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  final double price;
  final double discount;
  final double addOns;
  final int? storeId;
  final List<AddressModel> address;
  final List<CartModel?>? cartList;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final double total;
  final bool isOfflinePaymentActive;
  final bool isPrescriptionRequired;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController tooltipController1;
  final JustTheController tooltipController2;
  final JustTheController dmTipsTooltipController;
  final TextEditingController guestPasswordController;
  final TextEditingController guestConfirmPasswordController;
  final FocusNode guestPasswordNode;
  final FocusNode guestConfirmPasswordNode;
  final double variationPrice;
  final String deliveryChargeForView;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final bool proFreeDelivery;

  const TopSection({
    super.key,
    required this.deliveryCharge,
    required this.charge,
    required this.tomorrowClosed,
    required this.todayClosed,
    required this.price,
    required this.discount,
    required this.addOns,
    required this.addressList,
    required this.checkoutController,
    this.module,
    this.storeId,
    required this.address,
    required this.cartList,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.isOfflinePaymentActive,
    required this.isPrescriptionRequired,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.tooltipController1,
    required this.tooltipController2,
    required this.dmTipsTooltipController,
    required this.guestPasswordController,
    required this.guestConfirmPasswordController,
    required this.guestPasswordNode,
    required this.guestConfirmPasswordNode,
    required this.variationPrice,
    required this.deliveryChargeForView,
    required this.badWeatherCharge,
    required this.extraChargeForToolTip,
    this.proFreeDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    final theme = Theme.of(context);

    return Container(
      decoration: isDesktop
          ? BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            )
          : null,
      child: Column(
        children: [
          storeId != null
              ? Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.disabledColor.withValues(alpha: 0.15),
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
                  margin: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.medical_services_outlined,
                              size: 18,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            'your_prescription'.tr,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          JustTheTooltip(
                            backgroundColor: Colors.black87,
                            controller: tooltipController1,
                            preferredDirection: AxisDirection.right,
                            tailLength: 14,
                            tailBaseWidth: 20,
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'prescription_tool_tip'.tr,
                                style: robotoRegular.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => tooltipController1.showTooltip(),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              checkoutController.pickedPrescriptions.length + 1,
                          padding: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeExtraSmall,
                          ),
                          itemBuilder: (context, index) {
                            XFile? file = index ==
                                    checkoutController
                                        .pickedPrescriptions.length
                                ? null
                                : checkoutController.pickedPrescriptions[index];
                            if (index < 5 &&
                                index ==
                                    checkoutController
                                        .pickedPrescriptions.length) {
                              return InkWell(
                                onTap: () {
                                  if (ResponsiveHelper.isDesktop(context) ||
                                      GetPlatform.isIOS) {
                                    checkoutController.pickPrescriptionImage(
                                      isRemove: false,
                                      isCamera: false,
                                    );
                                  } else {
                                    Get.bottomSheet(
                                      const CameraButtonSheetWidget(),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 98,
                                  width: 98,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.3),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_rounded,
                                        color: theme.primaryColor,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'upload_your_prescription'.tr,
                                        style: robotoMedium.copyWith(
                                          color: theme.primaryColor,
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return file != null
                                ? Container(
                                    margin: const EdgeInsets.only(
                                      right: Dimensions.paddingSizeSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.primaryColor
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        children: [
                                          GetPlatform.isWeb
                                              ? Image.network(
                                                  file.path,
                                                  width: 98,
                                                  height: 98,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(file.path),
                                                  width: 98,
                                                  height: 98,
                                                  fit: BoxFit.cover,
                                                ),
                                          Positioned(
                                            right: 4,
                                            top: 4,
                                            child: InkWell(
                                              onTap: () => checkoutController
                                                  .removePrescriptionImage(
                                                index,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),

          // delivery option card
          Container(
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
            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.moped_rounded,
                        size: 18,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Text(
                      'delivery_type'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                storeId != null
                    ? DeliveryOptionButtonWidget(
                        value: 'delivery',
                        title: 'home_delivery'.tr,
                        charge: charge,
                        isFree: checkoutController.store!.freeDelivery,
                        fromWeb: true,
                        total: total,
                        deliveryChargeForView: deliveryChargeForView,
                        badWeatherCharge: badWeatherCharge,
                        extraChargeForToolTip: extraChargeForToolTip,
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            Get.find<SplashController>()
                                            .configModel!
                                            .homeDeliveryStatus ==
                                        1 &&
                                    checkoutController.store!.delivery!
                                ? DeliveryOptionButtonWidget(
                                    value: 'delivery',
                                    title: 'home_delivery'.tr,
                                    charge: charge,
                                    isFree:
                                        checkoutController.store!.freeDelivery,
                                    fromWeb: true,
                                    total: total,
                                    deliveryChargeForView: deliveryChargeForView,
                                    badWeatherCharge: badWeatherCharge,
                                    extraChargeForToolTip:
                                        extraChargeForToolTip,
                                  )
                                : const SizedBox(),
                            const SizedBox(
                              width: Dimensions.paddingSizeSmall,
                            ),
                            Get.find<SplashController>()
                                            .configModel!
                                            .takeawayStatus ==
                                        1 &&
                                    checkoutController.store!.takeAway!
                                ? DeliveryOptionButtonWidget(
                                    value: 'take_away',
                                    title: 'take_away'.tr,
                                    charge: deliveryCharge,
                                    isFree: true,
                                    fromWeb: true,
                                    total: total,
                                    deliveryChargeForView: deliveryChargeForView,
                                    badWeatherCharge: badWeatherCharge,
                                    extraChargeForToolTip:
                                        extraChargeForToolTip,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
              ],
            ),
          ),

          (!isDesktop &&
                  storeId == null &&
                  (Get.find<SplashController>()
                          .configModel!
                          .moduleConfig
                          ?.module
                          ?.orderAttachment ??
                      false))
              ? Padding(
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeSmall,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.disabledColor.withValues(alpha: 0.15),
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
                    child: PrescriptionImagePickerWidget(
                      checkoutController: checkoutController,
                      storeId: storeId,
                      isPrescriptionRequired: isPrescriptionRequired,
                    ),
                  ),
                )
              : const SizedBox(),

          /// delivery section
          DeliverySection(
            checkoutController: checkoutController,
            address: address,
            addressList: addressList,
            guestNameTextEditingController: guestNameTextEditingController,
            guestNumberTextEditingController: guestNumberTextEditingController,
            guestNumberNode: guestNumberNode,
            guestEmailController: guestEmailController,
            guestEmailNode: guestEmailNode,
          ),

          SizedBox(
            height: !takeAway ? Dimensions.paddingSizeSmall : 0,
          ),

          /// delivery instruction
          !takeAway
              ? isDesktop
                  ? const WebDeliveryInstructionView()
                  : const DeliveryInstructionView()
              : const SizedBox(),
          SizedBox(
            height: !takeAway ? Dimensions.paddingSizeSmall : 0,
          ),

          /// Create Account with existing info
          isGuestLoggedIn
              ? GuestCreateAccount(
                  guestPasswordController: guestPasswordController,
                  guestConfirmPasswordController:
                      guestConfirmPasswordController,
                  guestPasswordNode: guestPasswordNode,
                  guestConfirmPasswordNode: guestConfirmPasswordNode,
                )
              : const SizedBox(),

          SizedBox(
            height: isGuestLoggedIn ? Dimensions.paddingSizeSmall : 0,
          ),

          /// Time Slot
          TimeSlotSection(
            storeId: storeId,
            checkoutController: checkoutController,
            cartList: cartList,
            tooltipController2: tooltipController2,
            tomorrowClosed: tomorrowClosed,
            todayClosed: todayClosed,
            module: module,
          ),

          /// Saver Delivery Options
          GetBuilder<CheckoutController>(builder: (controller) {
            final bool showSaver = controller.isInstantDelivery &&
                SaverDeliveryTimeWidget.canShow(
                  controller: controller,
                  deliveryCharge: deliveryCharge,
                  originalDeliveryCharge: charge,
                  proFreeDelivery: proFreeDelivery,
                );

            if (!showSaver) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SaverDeliveryTimeWidget(
                  checkoutController: controller,
                  deliveryCharge: deliveryCharge,
                  originalDeliveryCharge: charge,
                  proFreeDelivery: proFreeDelivery,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            );
          }),

          /// Coupon
          !isDesktop && !isGuestLoggedIn
              ? CouponSection(
                  storeId: storeId,
                  checkoutController: checkoutController,
                  total: total,
                  price: price,
                  discount: discount,
                  addOns: addOns,
                  deliveryCharge: deliveryCharge,
                  variationPrice: variationPrice,
                )
              : const SizedBox(),

          /// Delivery man tips
          DeliveryManTipsSection(
            takeAway: takeAway,
            tooltipController3: dmTipsTooltipController,
            totalPrice: total,
            onTotalChange: (double p) => total + p,
            storeId: storeId,
          ),

          /// Payment Section
          Container(
            decoration: isDesktop
                ? const BoxDecoration()
                : BoxDecoration(
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
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeLarge,
            ),
            child: Column(
              children: [
                PaymentSection(
                  storeId: storeId,
                  isCashOnDeliveryActive: isCashOnDeliveryActive,
                  isDigitalPaymentActive: isDigitalPaymentActive,
                  isWalletActive: isWalletActive,
                  total: total,
                  checkoutController: checkoutController,
                  isOfflinePaymentActive: isOfflinePaymentActive,
                ),
                if (!isDesktop && !isGuestLoggedIn) ...[
                  PartialPayView(
                    totalPrice: total,
                    isPrescription: storeId != null,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),
        ],
      ),
    );
  }
}
