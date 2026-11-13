import 'package:Oxygen_Mart/common/widgets/address_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_dropdown.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/guest_delivery_address.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliverySection extends StatelessWidget {
  final CheckoutController checkoutController;
  final List<AddressModel> address;
  final List<DropdownItem<int>> addressList;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;

  const DeliverySection({
    super.key,
    required this.checkoutController,
    required this.address,
    required this.addressList,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestEmailController,
    required this.guestNumberNode,
    required this.guestEmailNode,
  });

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        isGuestLoggedIn
            ? GuestDeliveryAddress(
                checkoutController: checkoutController,
                guestNumberNode: guestNumberNode,
                guestNameTextEditingController: guestNameTextEditingController,
                guestNumberTextEditingController:
                    guestNumberTextEditingController,
                guestEmailController: guestEmailController,
                guestEmailNode: guestEmailNode,
              )
            : !takeAway
                ? Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    Icons.location_on_rounded,
                                    size: 18,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(
                                  'deliver_to'.tr,
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                var newAddress = await Get.toNamed(
                                  RouteHelper.getAddAddressRoute(
                                    true,
                                    false,
                                    checkoutController.store!.zoneId,
                                  ),
                                );
                                if (newAddress != null) {
                                  checkoutController.getDistanceInKM(
                                    LatLng(
                                      double.parse(newAddress.latitude),
                                      double.parse(newAddress.longitude),
                                    ),
                                    LatLng(
                                      double.parse(
                                          checkoutController.store!.latitude!),
                                      double.parse(
                                          checkoutController.store!.longitude!),
                                    ),
                                  );
                                  checkoutController.streetNumberController.text =
                                      newAddress.streetNumber ?? '';
                                  checkoutController.houseController.text =
                                      newAddress.house ?? '';
                                  checkoutController.floorController.text =
                                      newAddress.floor ?? '';
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
                                      Icons.add_rounded,
                                      size: 16,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'add_new'.tr,
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

                        isDesktop
                            ? Stack(
                                children: [
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 80),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: theme.primaryColor.withValues(alpha: 0.06),
                                      border: Border.all(
                                        color: theme.primaryColor.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeSmall,
                                        horizontal: Dimensions.paddingSizeSmall,
                                      ),
                                      child: AddressWidget(
                                        address: address[
                                            checkoutController.addressIndex!],
                                        fromAddress: false,
                                        fromCheckout: true,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: PopupMenuButton(
                                        position: PopupMenuPosition.under,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down_rounded),
                                        onSelected: (value) {},
                                        itemBuilder: (context) => List.generate(
                                          address.length,
                                          (index) => PopupMenuItem(
                                            child: InkWell(
                                              onTap: () {
                                                checkoutController.getDistanceInKM(
                                                  LatLng(
                                                    double.parse(
                                                        address[index].latitude!),
                                                    double.parse(
                                                        address[index].longitude!),
                                                  ),
                                                  LatLng(
                                                    double.parse(
                                                        checkoutController
                                                            .store!.latitude!),
                                                    double.parse(
                                                        checkoutController
                                                            .store!.longitude!),
                                                  ),
                                                );
                                                checkoutController
                                                    .setAddressIndex(index);
                                                checkoutController
                                                    .streetNumberController
                                                    .text = address[
                                                            checkoutController
                                                                .addressIndex!]
                                                        .streetNumber ??
                                                    '';
                                                checkoutController
                                                    .houseController
                                                    .text = address[
                                                            checkoutController
                                                                .addressIndex!]
                                                        .house ??
                                                    '';
                                                checkoutController
                                                    .floorController
                                                    .text = address[
                                                            checkoutController
                                                                .addressIndex!]
                                                        .floor ??
                                                    '';
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 20,
                                                    width: 20,
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: checkoutController
                                                                    .addressIndex ==
                                                                index
                                                            ? theme.primaryColor
                                                            : theme.disabledColor,
                                                      ),
                                                    ),
                                                    child: checkoutController
                                                                .addressIndex ==
                                                            index
                                                        ? Container(
                                                            height: 14,
                                                            width: 14,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              color: theme
                                                                  .primaryColor,
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ),
                                                  const SizedBox(
                                                      width: Dimensions
                                                          .paddingSizeSmall),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          address[index]
                                                              .addressType!
                                                              .tr,
                                                          style: robotoMedium.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          address[index].address!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: robotoRegular
                                                              .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeExtraSmall,
                                                            color: theme
                                                                .disabledColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                constraints: BoxConstraints(
                                  minHeight: isDesktop ? 90 : 80,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.primaryColor.withValues(alpha: 0.05),
                                  border: Border.all(
                                    color: theme.primaryColor.withValues(alpha: 0.18),
                                    width: 1,
                                  ),
                                ),
                                child: CustomDropdown<int>(
                                  onChange: (int? value, int index) {
                                    checkoutController.getDistanceInKM(
                                      LatLng(
                                        double.parse(address[index].latitude!),
                                        double.parse(address[index].longitude!),
                                      ),
                                      LatLng(
                                        double.parse(checkoutController
                                            .store!.latitude!),
                                        double.parse(checkoutController
                                            .store!.longitude!),
                                      ),
                                    );
                                    checkoutController.setAddressIndex(index);

                                    checkoutController.streetNumberController
                                        .text = address[checkoutController
                                                .addressIndex!]
                                            .streetNumber ??
                                        '';
                                    checkoutController.houseController.text =
                                        address[checkoutController
                                                    .addressIndex!]
                                                .house ??
                                            '';
                                    checkoutController.floorController.text =
                                        address[checkoutController
                                                    .addressIndex!]
                                                .floor ??
                                            '';
                                  },
                                  dropdownButtonStyle: DropdownButtonStyle(
                                    height: isDesktop ? 86 : 80,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: Dimensions.paddingSizeSmall,
                                    ),
                                    primaryColor:
                                        theme.textTheme.bodyLarge!.color,
                                  ),
                                  dropdownStyle: DropdownStyle(
                                    elevation: 10,
                                    borderRadius: BorderRadius.circular(16),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeExtraSmall),
                                  ),
                                  items: addressList,
                                  child: AddressWidget(
                                    address: address[
                                        checkoutController.addressIndex!],
                                    fromAddress: false,
                                    fromCheckout: true,
                                  ),
                                ),
                              ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        !isDesktop
                            ? CustomTextField(
                                labelText: 'street_number'.tr,
                                titleText: 'write_street_number'.tr,
                                inputType: TextInputType.streetAddress,
                                focusNode: checkoutController.streetNode,
                                nextFocus: checkoutController.houseNode,
                                controller:
                                    checkoutController.streetNumberController,
                                prefixIcon: Icons.signpost_outlined,
                              )
                            : const SizedBox(),
                        SizedBox(
                            height: !isDesktop
                                ? Dimensions.paddingSizeSmall
                                : 0),
                        Row(
                          children: [
                            if (isDesktop) ...[
                              Expanded(
                                child: CustomTextField(
                                  titleText: 'write_street_number'.tr,
                                  labelText: 'street_number'.tr,
                                  inputType: TextInputType.streetAddress,
                                  focusNode: checkoutController.streetNode,
                                  nextFocus: checkoutController.houseNode,
                                  controller: checkoutController
                                      .streetNumberController,
                                  prefixIcon: Icons.signpost_outlined,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                            ],
                            Expanded(
                              child: CustomTextField(
                                titleText: 'write_house_number'.tr,
                                labelText: 'house'.tr,
                                inputType: TextInputType.text,
                                focusNode: checkoutController.houseNode,
                                nextFocus: checkoutController.floorNode,
                                controller: checkoutController.houseController,
                                prefixIcon: Icons.apartment_rounded,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: CustomTextField(
                                titleText: 'write_floor_number'.tr,
                                labelText: 'floor'.tr,
                                inputType: TextInputType.text,
                                focusNode: checkoutController.floorNode,
                                inputAction: TextInputAction.done,
                                controller: checkoutController.floorController,
                                prefixIcon: Icons.layers_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
      ],
    );
  }
}
