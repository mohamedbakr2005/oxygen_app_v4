import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
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
  final TextEditingController? guestEmailController;
  final String? countryCode;
  final Function() onPickMap;

  const ParcelViewWidget({
    super.key,
    required this.isSender,
    required this.nameController,
    required this.phoneController,
    required this.streetController,
    required this.houseController,
    required this.floorController,
    required this.countryCode,
    required this.onPickMap,
    this.guestEmailController,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _countryCode = _addressCountryCode ?? widget.countryCode;
    String? countryDialCode;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompactScreen = screenWidth < 360;

    return SizedBox(
      width: Dimensions.webMaxWidth,
      child: GetBuilder<AddressController>(builder: (addressController) {
        return GetBuilder<ParcelController>(builder: (parcelController) {
          final List<AddressModel> savedAddresses =
              (AuthHelper.isLoggedIn() && addressController.addressList != null)
                  ? addressController.addressList!
                  : <AddressModel>[];

          final AddressModel? currentAddress = widget.isSender
              ? parcelController.pickupAddress
              : parcelController.destinationAddress;

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: isCompactScreen
                  ? Dimensions.paddingSizeSmall
                  : Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            child: Center(
              child: FooterView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(children: [
                    // Location card (Google Map selection only, fully responsive)
                    _LocationCard(
                      isSender: widget.isSender,
                      isCompactScreen: isCompactScreen,
                      currentAddress: currentAddress,
                      savedAddresses: savedAddresses,
                      streetController: widget.streetController,
                      houseController: widget.houseController,
                      floorController: widget.floorController,
                      streetNode: streetNode,
                      houseNode: houseNode,
                      floorNode: floorNode,
                      onPickMap: widget.onPickMap,
                      onSavedAddressSelected: (AddressModel selected, int index) async {
                        await _handleSavedAddressSelect(
                          selected: selected,
                          index: index,
                          parcelController: parcelController,
                        );
                      },
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Contact info card
                    _ContactInfoCard(
                      isSender: widget.isSender,
                      isCompactScreen: isCompactScreen,
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
    required AddressModel selected,
    required int index,
    required ParcelController parcelController,
  }) async {
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
      widget.streetController.text = selected.streetNumber ?? '';
      widget.houseController.text = selected.house ?? '';
      widget.floorController.text = selected.floor ?? '';
      if (selected.contactPersonName != null && selected.contactPersonName!.isNotEmpty) {
        widget.nameController.text = selected.contactPersonName!;
      }
    }
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
  final bool isCompactScreen;
  final AddressModel? currentAddress;
  final List<AddressModel> savedAddresses;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final TextEditingController floorController;
  final FocusNode streetNode;
  final FocusNode houseNode;
  final FocusNode floorNode;
  final Function() onPickMap;
  final Function(AddressModel address, int index) onSavedAddressSelected;

  const _LocationCard({
    required this.isSender,
    required this.isCompactScreen,
    required this.currentAddress,
    required this.savedAddresses,
    required this.streetController,
    required this.houseController,
    required this.floorController,
    required this.streetNode,
    required this.houseNode,
    required this.floorNode,
    required this.onPickMap,
    required this.onSavedAddressSelected,
  });

  IconData _addressIcon(String? type) {
    final String t = (type ?? 'home').toLowerCase();
    if (t == 'home') return Icons.home_rounded;
    if (t == 'office' || t == 'work') return Icons.work_rounded;
    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).primaryColor;
    final double cardPadding = isCompactScreen
        ? Dimensions.paddingSizeSmall + 2
        : Dimensions.paddingSizeDefault;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
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
      padding: EdgeInsets.all(cardPadding),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Section Header (safe against narrow widths / large font scale)
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 20,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(
              isSender ? 'pickup_location'.tr : 'delivery_location'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: onPickMap,
            icon: Icon(Icons.map_outlined, size: 17, color: primaryColor),
            label: Text(
              'set_from_map'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: primaryColor,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Selected Google Map Location Card (self-sizing, zero fixed-height overflow)
        if (currentAddress != null) ...[
          InkWell(
            onTap: onPickMap,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _addressIcon(currentAddress!.addressType),
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentAddress!.addressType != null &&
                            currentAddress!.addressType!.trim().isNotEmpty) ...[
                          Text(
                            currentAddress!.addressType!.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          currentAddress!.address ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_location_alt_outlined,
                    size: 20,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          InkWell(
            onTap: onPickMap,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeDefault,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(children: [
                Icon(Icons.add_location_alt_outlined, color: primaryColor, size: 22),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    'choose_from_map'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: primaryColor,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 15, color: primaryColor),
              ]),
            ),
          ),
        ],

        // Quick-select saved GPS addresses (horizontal chips, never overflows)
        if (savedAddresses.isNotEmpty) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(savedAddresses.length, (index) {
                final addr = savedAddresses[index];
                final bool isSelected = currentAddress != null &&
                    currentAddress!.latitude == addr.latitude &&
                    currentAddress!.longitude == addr.longitude &&
                    currentAddress!.address == addr.address;
                final String chipTitle = (addr.addressType != null &&
                        addr.addressType!.trim().isNotEmpty)
                    ? addr.addressType!.tr
                    : (addr.address ?? '');

                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: InkWell(
                    onTap: () => onSavedAddressSelected(addr, index),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.14)
                            : Theme.of(context).disabledColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : Theme.of(context).disabledColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _addressIcon(addr.addressType),
                            size: 15,
                            color: isSelected
                                ? primaryColor
                                : Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              chipTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isSelected
                                    ? primaryColor
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],

        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Responsive address details:
        // Street Number gets its own full-width line so its label never wraps/breaks.
        CustomTextField(
          titleText: 'street_number'.tr,
          labelText: 'street_number'.tr,
          hintText: 'street_number'.tr,
          inputType: TextInputType.streetAddress,
          focusNode: streetNode,
          nextFocus: houseNode,
          controller: streetController,
          prefixIcon: Icons.signpost_outlined,
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall + 2),

        // House & Floor side-by-side (50/50), stacking automatically on ultra-narrow widths or huge text scales
        LayoutBuilder(
          builder: (context, constraints) {
            final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
            final bool stackFields = constraints.maxWidth < 260 || textScale > 1.35;

            final Widget houseField = CustomTextField(
              titleText: 'house'.tr,
              labelText: 'house'.tr,
              hintText: 'house'.tr,
              inputType: TextInputType.text,
              focusNode: houseNode,
              nextFocus: floorNode,
              controller: houseController,
              prefixIcon: Icons.apartment_outlined,
            );

            final Widget floorField = CustomTextField(
              titleText: 'floor'.tr,
              labelText: 'floor'.tr,
              hintText: 'floor'.tr,
              inputType: TextInputType.text,
              focusNode: floorNode,
              controller: floorController,
              prefixIcon: Icons.layers_outlined,
            );

            if (stackFields) {
              return Column(
                children: [
                  houseField,
                  const SizedBox(height: Dimensions.paddingSizeSmall + 2),
                  floorField,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: houseField),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: floorField),
              ],
            );
          },
        ),
      ]),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final bool isSender;
  final bool isCompactScreen;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController? guestEmailController;
  final FocusNode nameNode;
  final FocusNode phoneNode;
  final FocusNode guestEmailNode;
  final String? countryDialCode;
  final Function(CountryCode) onCountryChanged;

  const _ContactInfoCard({
    required this.isSender,
    required this.isCompactScreen,
    required this.nameController,
    required this.phoneController,
    required this.guestEmailController,
    required this.nameNode,
    required this.phoneNode,
    required this.guestEmailNode,
    required this.countryDialCode,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String emailLabel = '${isSender ? 'sender_email'.tr : 'receiver_email'.tr} (${'optional'.tr})';
    final double cardPadding = isCompactScreen
        ? Dimensions.paddingSizeSmall + 2
        : Dimensions.paddingSizeDefault;

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
      padding: EdgeInsets.all(cardPadding),
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
          Expanded(
            child: Text(
              isSender ? 'sender_information'.tr : 'receiver_information'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
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
