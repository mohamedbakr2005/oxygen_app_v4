import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GuestDeliveryAddress extends StatelessWidget {
  final CheckoutController checkoutController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  const GuestDeliveryAddress({
    super.key,
    required this.checkoutController,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestEmailController,
    required this.guestNumberNode,
    required this.guestEmailNode,
  });

  @override
  Widget build(BuildContext context) {
    bool takeAway = (checkoutController.orderType == 'take_away');
    final theme = Theme.of(context);

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
                  takeAway ? Icons.person_pin_rounded : Icons.local_shipping_rounded,
                  size: 18,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                takeAway ? 'contact_information'.tr : 'delivery_information'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const Spacer(),
              takeAway
                  ? const SizedBox()
                  : InkWell(
                      onTap: () async {
                        String? previousGuestAddress =
                            checkoutController.guestAddress?.address;
                        var address = await Get.toNamed(
                          RouteHelper.getEditAddressRoute(
                            checkoutController.guestAddress,
                            fromGuest: true,
                          ),
                        );

                        if (address != null) {
                          checkoutController.setGuestAddress(address);
                          if (address.contactPersonName != null &&
                              address.contactPersonName!.isNotEmpty &&
                              address.contactPersonName != 'null') {
                            guestNameTextEditingController.text =
                                address.contactPersonName!;
                          }
                          if (address.contactPersonNumber != null &&
                              address.contactPersonNumber!.isNotEmpty &&
                              address.contactPersonNumber != 'null') {
                            guestNumberTextEditingController.text =
                                address.contactPersonNumber!;
                          } else {
                            guestNumberTextEditingController.text = '';
                          }
                          if (address.email != null &&
                              address.email!.isNotEmpty &&
                              address.email != 'null') {
                            guestEmailController.text = address.email!;
                          }
                          if (previousGuestAddress != address.address &&
                              checkoutController.store != null &&
                              checkoutController.store!.latitude != null &&
                              checkoutController.store!.longitude != null) {
                            checkoutController.getDistanceInKM(
                              LatLng(
                                double.tryParse(
                                        address.latitude?.toString() ?? '0') ??
                                    0,
                                double.tryParse(
                                        address.longitude?.toString() ?? '0') ??
                                    0,
                              ),
                              LatLng(
                                double.tryParse(
                                        checkoutController.store!.latitude ??
                                            '0') ??
                                    0,
                                double.tryParse(
                                        checkoutController.store!.longitude ??
                                            '0') ??
                                    0,
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall + 2,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_location_alt_rounded,
                              size: 15,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'edit'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          takeAway
              ? Column(
                  children: [
                    CustomTextField(
                      labelText: 'contact_person_name'.tr,
                      titleText: 'write_name'.tr,
                      inputType: TextInputType.name,
                      controller: guestNameTextEditingController,
                      nextFocus: guestNumberNode,
                      capitalization: TextCapitalization.words,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextField(
                      labelText: 'contact_person_number'.tr,
                      titleText: 'write_number'.tr,
                      controller: guestNumberTextEditingController,
                      focusNode: guestNumberNode,
                      nextFocus: guestEmailNode,
                      inputType: TextInputType.phone,
                      isPhone: true,
                      onCountryChanged: (CountryCode countryCode) {
                        checkoutController.countryDialCode =
                            countryCode.dialCode;
                      },
                      countryDialCode: checkoutController.countryDialCode ??
                          Get.find<LocalizationController>().locale.countryCode,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    CustomTextField(
                      titleText: "${'email'.tr} (${'optional'.tr})",
                      labelText: "${'email'.tr} (${'optional'.tr})",
                      controller: guestEmailController,
                      focusNode: guestEmailNode,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                  ],
                )
              : checkoutController.guestAddress == null
                  ? InkWell(
                      onTap: () async {
                        String? previousGuestAddress =
                            checkoutController.guestAddress?.address;
                        var address = await Get.toNamed(
                          RouteHelper.getEditAddressRoute(
                            checkoutController.guestAddress,
                            fromGuest: true,
                          ),
                        );

                        if (address != null) {
                          checkoutController.setGuestAddress(address);
                          if (address.contactPersonName != null &&
                              address.contactPersonName!.isNotEmpty &&
                              address.contactPersonName != 'null') {
                            guestNameTextEditingController.text =
                                address.contactPersonName!;
                          }
                          if (address.contactPersonNumber != null &&
                              address.contactPersonNumber!.isNotEmpty &&
                              address.contactPersonNumber != 'null') {
                            guestNumberTextEditingController.text =
                                address.contactPersonNumber!;
                          } else {
                            guestNumberTextEditingController.text = '';
                          }
                          if (address.email != null &&
                              address.email!.isNotEmpty &&
                              address.email != 'null') {
                            guestEmailController.text = address.email!;
                          }
                          if (previousGuestAddress != address.address &&
                              checkoutController.store != null &&
                              checkoutController.store!.latitude != null &&
                              checkoutController.store!.longitude != null) {
                            checkoutController.getDistanceInKM(
                              LatLng(
                                double.tryParse(
                                        address.latitude?.toString() ?? '0') ??
                                    0,
                                double.tryParse(
                                        address.longitude?.toString() ?? '0') ??
                                    0,
                              ),
                              LatLng(
                                double.tryParse(
                                        checkoutController.store!.latitude ??
                                            '0') ??
                                    0,
                              double.tryParse(
                                        checkoutController.store!.longitude ??
                                            '0') ??
                                    0,
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_location_alt_outlined,
                              size: 32,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Text(
                              'please_update_your_delivery_info'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Flexible(
                                child: Text(
                                  checkoutController.guestAddress?.address ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          const Divider(height: 1),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _AddressInfo(
                                      title: 'address_type'.tr,
                                      value: checkoutController
                                          .guestAddress?.addressType,
                                    ),
                                    _AddressInfo(
                                      title: 'name'.tr,
                                      value: checkoutController
                                          .guestAddress?.contactPersonName,
                                    ),
                                    _AddressInfo(
                                      title: 'phone'.tr,
                                      value: checkoutController
                                          .guestAddress?.contactPersonNumber,
                                    ),
                                    _AddressInfo(
                                      title: 'email'.tr,
                                      value: checkoutController
                                          .guestAddress?.email,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _AddressInfo(
                                      title: 'street'.tr,
                                      value: checkoutController
                                          .guestAddress?.streetNumber,
                                    ),
                                    _AddressInfo(
                                      title: 'house'.tr,
                                      value: checkoutController
                                          .guestAddress?.house,
                                    ),
                                    _AddressInfo(
                                      title: 'floor'.tr,
                                      value: checkoutController
                                          .guestAddress?.floor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}

class _AddressInfo extends StatelessWidget {
  final String title;
  final String? value;
  const _AddressInfo({required this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: robotoRegular.copyWith(
              color: Theme.of(context).disabledColor,
              fontSize: Dimensions.fontSizeExtraSmall + 1,
            ),
          ),
          Flexible(
            child: Text(
              (value != null && value!.isNotEmpty && value != 'null')
                  ? value!
                  : '-',
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall + 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
