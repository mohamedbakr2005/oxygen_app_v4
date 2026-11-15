import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:Oxygen_Mart/common/widgets/address_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_dropdown.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ParcelViewWidget extends StatefulWidget {
  final bool isSender;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final TextEditingController manualAddressController;
  final TextEditingController? guestEmailController;
  final String? countryCode;
  final bool isManualAddress;
  final Function(bool isManual) onAddressModeChanged;
  final Function() onPickMap;

  const ParcelViewWidget({super.key,
    required this.isSender, required this.nameController, required this.phoneController, required this.streetController, required this.houseController,
    required this.floorController, required this.manualAddressController, required this.countryCode, required this.isManualAddress, required this.onAddressModeChanged,
    required this.onPickMap, this.guestEmailController,
  });

  @override
  State<ParcelViewWidget> createState() => _ParcelViewWidgetState();
}

class _ParcelViewWidgetState extends State<ParcelViewWidget> {
  final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();
  final FocusNode nameNode = FocusNode();
  final FocusNode phoneNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode manualAddressNode = FocusNode();

  String? _countryCode;
  String? _addressCountryCode;

  @override
  void initState() {
    super.initState();
    _addressCountryCode = null;
    _countryCode = _addressCountryCode ?? widget.countryCode;
  }

  @override
  void dispose() {
    streetNode.dispose();
    houseNode.dispose();
    floorNode.dispose();
    nameNode.dispose();
    phoneNode.dispose();
    guestEmailNode.dispose();
    manualAddressNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _countryCode = _addressCountryCode ?? widget.countryCode;
    String? countryDialCode;

    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: GetBuilder<AddressController>(builder: (addressController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          final List<DropdownItem<int>> dropdownList = _getDropdownAddressList(
            context: context,
            addressList: addressController.addressList,
            isSender: widget.isSender,
            pickupAddress: parcelController.pickupAddress,
            destinationAddress: parcelController.destinationAddress,
          );
          final List<AddressModel> addressList = _getAddressList(
            addressList: addressController.addressList,
            isSender: widget.isSender,
            pickupAddress: parcelController.pickupAddress,
            destinationAddress: parcelController.destinationAddress,
          );

          final AddressModel? currentAddress = widget.isSender
              ? parcelController.pickupAddress
              : parcelController.destinationAddress;

          return SingleChildScrollView(
            controller: ScrollController(),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Center(
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(children: [
                    // Location card
                    _LocationCard(
                      isSender: widget.isSender,
                      isManualAddress: widget.isManualAddress,
                      currentAddress: currentAddress,
                      dropdownList: dropdownList,
                      addressList: addressList,
                      manualAddressController: widget.manualAddressController,
                      streetController: widget.streetController,
                      houseController: widget.houseController,
                      floorController: widget.floorController,
                      streetNode: streetNode,
                      houseNode: houseNode,
                      floorNode: floorNode,
                      manualAddressNode: manualAddressNode,
                      onAddressModeChanged: widget.onAddressModeChanged,
                      onPickMap: widget.onPickMap,
                      onAddressSelected: (int index) async {
                        await _handleSavedAddressSelect(
                          index: index,
                          addressList: addressList,
                          parcelController: parcelController,
                        );
                      },
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Contact info card
                    _ContactInfoCard(
                      isSender: widget.isSender,
                      nameController: widget.nameController,
                      phoneController: widget.phoneController,
                      guestEmailController: widget.guestEmailController,
                      nameNode: nameNode,
                      phoneNode: phoneNode,
                      guestEmailNode: guestEmailNode,
                      countryDialCode: countryDialCode ?? _countryCode,
                      onCountryChanged: (CountryCode code) {
                        countryDialCode = code.dialCode;
                        parcelController.setCountryCode(countryDialCode!, widget.isSender);
                      },
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  ]),
                ),
              ),
            ),
          );
        });
      }),
    );
  }

  Future<void> _handleSavedAddressSelect({
    required int index,
    required List<AddressModel> addressList,
    required ParcelController parcelController,
  }) async {
    if (index >= addressList.length) return;
    final selected = addressList[index];

    ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(
      selected.latitude.toString(),
      selected.longitude.toString(),
      false,
    );

    AddressModel updated = AddressModel(
      id: selected.id,
      addressType: selected.addressType,
      contactPersonNumber: selected.contactPersonNumber,
      contactPersonName: selected.contactPersonName,
      address: selected.address,
      latitude: selected.latitude,
      longitude: selected.longitude,
      zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
      zoneIds: responseModel.zoneIds,
      method: selected.method,
      streetNumber: selected.streetNumber,
      house: selected.house,
      floor: selected.floor,
      zoneData: responseModel.zoneData,
    );

    if (widget.isSender) {
      parcelController.setPickupAddress(updated, true);
      parcelController.setSenderAddressIndex(index);
      widget.manualAddressController.text = selected.address ?? '';
      widget.streetController.text = selected.streetNumber ?? '';
      widget.houseController.text = selected.house ?? '';
      widget.floorController.text = selected.floor ?? '';
      if (selected.contactPersonName != null && selected.contactPersonName!.isNotEmpty) {
        widget.nameController.text = selected.contactPersonName!;
      }
      if (selected.contactPersonNumber != null && selected.contactPersonNumber!.isNotEmpty) {
        await _splitPhoneNumber(selected.contactPersonNumber!);
        parcelController.setCountryCode(_addressCountryCode ?? _countryCode!, true);
      }
    } else {
      parcelController.setDestinationAddress(updated);
      parcelController.setReceiverAddressIndex(index);
      widget.manualAddressController.text = selected.address ?? '';
      widget.streetController.text = selected.streetNumber ?? '';
      widget.houseController.text = selected.house ?? '';
      widget.floorController.text = selected.floor ?? '';
      if (selected.contactPersonName != null && selected.contactPersonName!.isNotEmpty) {
        widget.nameController.text = selected.contactPersonName!;
      }
    }
  }

  List<DropdownItem<int>> _getDropdownAddressList({
    required BuildContext context,
    required List<AddressModel>? addressList,
    required bool isSender,
    required AddressModel? pickupAddress,
    required AddressModel? destinationAddress,
  }) {
    List<DropdownItem<int>> dropDownAddressList = [];
    final activeAddress = isSender ? pickupAddress : destinationAddress;

    dropDownAddressList.add(DropdownItem<int>(
      value: 0,
      child: SizedBox(
        width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 70 : context.width - 70,
        child: AddressWidget(
          address: activeAddress,
          fromAddress: false,
          fromCheckout: true,
        ),
      ),
    ));

    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        dropDownAddressList.add(DropdownItem<int>(
          value: index + 1,
          child: SizedBox(
            width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 70 : context.width - 70,
            child: AddressWidget(
              address: addressList[index],
              fromAddress: false,
              fromCheckout: true,
            ),
          ),
        ));
      }
    }
    return dropDownAddressList;
  }

  List<AddressModel> _getAddressList({
    required List<AddressModel>? addressList,
    required bool isSender,
    required AddressModel? pickupAddress,
    required AddressModel? destinationAddress,
  }) {
    List<AddressModel> address = [];
    if (isSender && pickupAddress != null) {
      address.add(pickupAddress);
    } else if (!isSender && destinationAddress != null) {
      address.add(destinationAddress);
    }
    if (addressList != null && AuthHelper.isLoggedIn()) {
      for (int index = 0; index < addressList.length; index++) {
        address.add(addressList[index]);
      }
    }
    return address;
  }

  Future<void> _splitPhoneNumber(String number) async {
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      _addressCountryCode = '+${phoneNumber.countryCode}';
      widget.phoneController.text = phoneNumber.international.substring(_addressCountryCode!.length);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
  }
}

class _LocationCard extends StatelessWidget {
  final bool isSender;
  final bool isManualAddress;
  final AddressModel? currentAddress;
  final List<DropdownItem<int>> dropdownList;
  final List<AddressModel> addressList;
  final TextEditingController manualAddressController;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final FocusNode streetNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  final FocusNode manualAddressNode;
  final Function(bool isManual) onAddressModeChanged;
  final Function() onPickMap;
  final Function(int index) onAddressSelected;

  const _LocationCard({
    required this.isSender, required this.isManualAddress, required this.currentAddress, required this.dropdownList, required this.addressList,
    required this.manualAddressController, required this.streetController, required this.houseController, required this.floorController, required this.streetNode,
    required this.houseNode, required this.floorNode, required this.manualAddressNode, required this.onAddressModeChanged, required this.onPickMap,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              isSender ? 'pickup_location'.tr : 'delivery_location'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ]),

          TextButton.icon(
            onPressed: onPickMap,
            icon: Icon(Icons.add_circle_outline_rounded, size: 18, color: Theme.of(context).primaryColor),
            label: Text(
              'add_new'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Dual Mode Switch: Map / Saved vs Manual Typing
        _AddressModeSelector(
          isManualAddress: isManualAddress,
          onModeChanged: onAddressModeChanged,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Mode Content
        if (!isManualAddress) ...[
          // Map / Saved Addresses Mode
          Container(
            constraints: const BoxConstraints(minHeight: 72),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
            ),
            child: dropdownList.isNotEmpty
                ? CustomDropdown<int>(
                    onChange: (int? value, int index) {
                      onAddressSelected(index);
                    },
                    dropdownButtonStyle: DropdownButtonStyle(
                      height: 72,
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: Dimensions.paddingSizeExtraSmall,
                      ),
                      primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    dropdownStyle: DropdownStyle(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    ),
                    items: dropdownList,
                    child: AddressWidget(
                      address: currentAddress,
                      fromAddress: false,
                      fromCheckout: true,
                    ),
                  )
                : InkWell(
                    onTap: onPickMap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Row(children: [
                        Icon(Icons.add_location_alt_outlined, color: Theme.of(context).primaryColor),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            'select_from_map'.tr,
                            style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ]),
                    ),
                  ),
          ),
        ] else ...[
          // Manual Address Writing Mode
          CustomTextField(
            titleText: 'enter_detailed_address'.tr,
            labelText: 'detailed_address'.tr,
            hintText: 'enter_detailed_address'.tr,
            inputType: TextInputType.streetAddress,
            focusNode: manualAddressNode,
            nextFocus: streetNode,
            controller: manualAddressController,
            prefixIcon: Icons.edit_location_alt_outlined,
            maxLines: 2,
          ),
        ],

        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Address details: Street, House, Floor in a clean row
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: CustomTextField(
              titleText: 'street_number'.tr,
              labelText: 'street_number'.tr,
              hintText: 'street_number'.tr,
              inputType: TextInputType.streetAddress,
              focusNode: streetNode,
              nextFocus: houseNode,
              controller: streetController,
              prefixIcon: Icons.signpost_outlined,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: CustomTextField(
              titleText: 'house'.tr,
              labelText: 'house'.tr,
              hintText: 'house'.tr,
              inputType: TextInputType.text,
              focusNode: houseNode,
              nextFocus: floorNode,
              controller: houseController,
              prefixIcon: Icons.apartment_outlined,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: CustomTextField(
              titleText: 'floor'.tr,
              labelText: 'floor'.tr,
              hintText: 'floor'.tr,
              inputType: TextInputType.text,
              focusNode: floorNode,
              controller: floorController,
              prefixIcon: Icons.layers_outlined,
            ),
          ),
        ]),
      ]),
    );
  }
}

class _AddressModeSelector extends StatelessWidget {
  final bool isManualAddress;
  final Function(bool isManual) onModeChanged;

  const _AddressModeSelector({required this.isManualAddress, required this.onModeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Expanded(
          child: _ModeTabButton(
            title: 'choose_from_map'.tr,
            icon: Icons.map_outlined,
            isSelected: !isManualAddress,
            onTap: () => onModeChanged(false),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _ModeTabButton(
            title: 'write_address_manually'.tr,
            icon: Icons.edit_note_rounded,
            isSelected: isManualAddress,
            onTap: () => onModeChanged(true),
          ),
        ),
      ]),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTabButton({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Theme.of(context).disabledColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final bool isSender;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController? guestEmailController;
  final FocusNode nameNode;
  final FocusNode phoneNode;
  final FocusNode guestEmailNode;
  final String? countryDialCode;
  final Function(CountryCode) onCountryChanged;

  const _ContactInfoCard({
    required this.isSender, required this.nameController, required this.phoneController, required this.guestEmailController, required this.nameNode,
    required this.phoneNode, required this.guestEmailNode, required this.countryDialCode, required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String emailLabel = '${isSender ? 'sender_email'.tr : 'receiver_email'.tr} (${'optional'.tr})';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section Header
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_pin_circle_outlined,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            isSender ? 'sender_information'.tr : 'receiver_information'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Name Field
        CustomTextField(
          labelText: isSender ? 'sender_name'.tr : 'receiver_name'.tr,
          titleText: isSender ? 'sender_name'.tr : 'receiver_name'.tr,
          hintText: isSender ? 'sender_name'.tr : 'receiver_name'.tr,
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
          focusNode: nameNode,
          nextFocus: phoneNode,
          controller: nameController,
          prefixIcon: Icons.person_outline_rounded,
          required: true,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Phone Field
        CustomTextField(
          titleText: isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
          labelText: isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
          hintText: isSender ? 'sender_phone_number'.tr : 'receiver_phone_number'.tr,
          controller: phoneController,
          focusNode: phoneNode,
          nextFocus: guestEmailNode,
          inputType: TextInputType.phone,
          isPhone: true,
          countryDialCode: countryDialCode,
          onCountryChanged: onCountryChanged,
          required: true,
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Email Field: Always Optional with clear "(اختياري)" badge
        CustomTextField(
          titleText: emailLabel,
          labelText: emailLabel,
          hintText: emailLabel,
          controller: guestEmailController,
          inputType: TextInputType.emailAddress,
          focusNode: guestEmailNode,
          prefixIcon: Icons.email_outlined,
          inputAction: TextInputAction.done,
          required: false,
        ),
      ]),
    );
  }
}
