import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/code_picker_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/location/screens/pick_map_screen.dart';
import 'package:Oxygen_Mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class AddAddressScreen extends StatefulWidget {
  final bool fromCheckout;
  final bool fromRide;
  final AddressModel? address;
  final int? zoneId;
  final bool forGuest;
  final bool fromNavBar;

  const AddAddressScreen({
    super.key,
    required this.fromCheckout,
    required this.fromRide,
    this.address,
    this.zoneId,
    this.forGuest = false,
    this.fromNavBar = false,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _contactPersonNumberController =
      TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _addressNode = FocusNode();
  final FocusNode _levelNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  bool _otherSelect = false;
  String? _countryDialCode =
      Get.find<AuthController>().getUserCountryCode().isNotEmpty
          ? Get.find<AuthController>().getUserCountryCode()
          : (Get.find<SplashController>().configModel?.country != null
              ? CountryCode.fromCountryCode(
                      Get.find<SplashController>().configModel!.country!)
                  .dialCode
              : '+20');

  @override
  void initState() {
    super.initState();
    initCall();

    if (widget.address != null) {
      if (widget.address!.contactPersonNumber != null &&
          widget.address!.contactPersonNumber!.isNotEmpty) {
        splitPhoneNumber(widget.address!.contactPersonNumber!);
      } else if (Get.find<ProfileController>().userInfoModel?.phone != null &&
          Get.find<ProfileController>().userInfoModel!.phone!.isNotEmpty) {
        splitPhoneNumber(Get.find<ProfileController>().userInfoModel!.phone!);
      }

      _contactPersonNameController.text = (widget.address!.contactPersonName != null &&
              widget.address!.contactPersonName!.isNotEmpty)
          ? widget.address!.contactPersonName!
          : (Get.find<ProfileController>().userInfoModel != null
              ? '${Get.find<ProfileController>().userInfoModel!.fName ?? ''} ${Get.find<ProfileController>().userInfoModel!.lName ?? ''}'.trim()
              : '');
      _emailController.text = widget.address!.email ??
          (Get.find<ProfileController>().userInfoModel?.email ?? '');
      _streetNumberController.text = widget.address!.streetNumber ?? '';
      _houseController.text = widget.address!.house ?? '';
      _floorController.text = widget.address!.floor ?? '';
    } else if (Get.find<ProfileController>().userInfoModel != null &&
        _contactPersonNameController.text.isEmpty) {
      _contactPersonNameController.text =
          '${Get.find<ProfileController>().userInfoModel!.fName ?? ''} ${Get.find<ProfileController>().userInfoModel!.lName ?? ''}'.trim();
      if (Get.find<ProfileController>().userInfoModel!.phone != null &&
          Get.find<ProfileController>().userInfoModel!.phone!.isNotEmpty) {
        splitPhoneNumber(Get.find<ProfileController>().userInfoModel!.phone!);
      }
    }
  }

  void initCall() {
    Get.find<LocationController>().setAddressTypeIndex(0, isUpdate: false);
    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    if (widget.address == null) {
      _initialPosition = LatLng(
        double.parse(
            Get.find<SplashController>().configModel!.defaultLocation!.lat ??
                '0'),
        double.parse(
            Get.find<SplashController>().configModel!.defaultLocation!.lng ??
                '0'),
      );
    } else {
      Get.find<LocationController>().setUpdateAddress(widget.address!);
      _initialPosition = LatLng(
        double.tryParse(widget.address!.latitude ?? '0') ?? 0.0,
        double.tryParse(widget.address!.longitude ?? '0') ?? 0.0,
      );

      if (widget.address!.addressType == 'home') {
        Get.find<LocationController>().setAddressTypeIndex(0, isUpdate: false);
      } else if (widget.address!.addressType == 'office') {
        Get.find<LocationController>().setAddressTypeIndex(1, isUpdate: false);
      } else if (widget.address!.addressType != null &&
          widget.address!.addressType!.isNotEmpty &&
          widget.address!.addressType != 'others') {
        Get.find<LocationController>().setAddressTypeIndex(2, isUpdate: false);
        _levelController.text = widget.address!.addressType ?? '';
        _otherSelect = true;
      } else if (widget.address!.addressType == 'others') {
        Get.find<LocationController>().setAddressTypeIndex(2, isUpdate: false);
        _otherSelect = true;
      } else {
        Get.find<LocationController>().setAddressTypeIndex(0, isUpdate: false);
      }
    }
  }

  void splitPhoneNumber(String number) async {
    if (number.trim().isEmpty) return;
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      _countryDialCode = '+${phoneNumber.countryCode}';
      _contactPersonNumberController.text = phoneNumber.nsn.isNotEmpty
          ? phoneNumber.nsn
          : (phoneNumber.international.length > _countryDialCode!.length
              ? phoneNumber.international.substring(_countryDialCode!.length)
              : number);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
      _contactPersonNumberController.text = number;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        title: widget.forGuest
            ? 'set_address'.tr
            : widget.address == null
                ? 'add_new_address'.tr
                : 'update_address'.tr,
      ),
      body: SafeArea(
        child: GetBuilder<ProfileController>(builder: (profileController) {
          return GetBuilder<LocationController>(builder: (locationController) {
            _addressController.text = locationController.address ?? '';

            return ResponsiveHelper.isDesktop(context)
                ? _buildDesktopView(context, locationController)
                : _buildMobileView(context, locationController);
          });
        }),
      ),
    );
  }

  // -------------------------------------------------------------
  // 📱 Mobile View: 2026 High-End Address Screen Layout
  // -------------------------------------------------------------
  Widget _buildMobileView(
      BuildContext context, LocationController locationController) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title: "تفاصيل التوصيل"
                    Text(
                      'delivery_address'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // 🗺️ 1. Modern Map Card with Floating Address Capsule
                    _buildMapCard(context, locationController),

                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    // 📝 2. Form Fields with Red Asterisks & Rounded Styling
                    _buildAddressTextField(
                      context,
                      label: 'delivery_address'.tr,
                      hint: 'write_delivery_address'.tr,
                      controller: _addressController,
                      focusNode: _addressNode,
                      nextFocus: _nameNode,
                      isRequired: true,
                      prefixIcon: Icons.location_on_outlined,
                      onChanged: (text) => locationController.setPlaceMark(text),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Contact Person Name
                    _buildAddressTextField(
                      context,
                      label: 'contact_person_name'.tr,
                      hint: 'write_name'.tr,
                      controller: _contactPersonNameController,
                      focusNode: _nameNode,
                      nextFocus: _numberNode,
                      isRequired: true,
                      prefixIcon: Icons.person_outline_rounded,
                      capitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // Contact Person Phone Number
                    _buildPhoneField(context),

                    // Guest Email (If Guest)
                    if (widget.forGuest) ...[
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      _buildAddressTextField(
                        context,
                        label: '${'email'.tr} (${'optional'.tr})',
                        hint: 'enter_email'.tr,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _streetNode,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                    ],

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    // 🏢 3-Column Row: Building / Floor / Street (العمارة / الدور / رقم الشارع)
                    Row(
                      children: [
                        // Building / House
                        Expanded(
                          child: _buildAddressTextField(
                            context,
                            label: 'house'.tr,
                            hint: 'example_building'.tr,
                            controller: _houseController,
                            focusNode: _houseNode,
                            nextFocus: _floorNode,
                            isRequired: false,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // Floor
                        Expanded(
                          child: _buildAddressTextField(
                            context,
                            label: 'floor'.tr,
                            hint: 'example_floor'.tr,
                            controller: _floorController,
                            focusNode: _floorNode,
                            nextFocus: _streetNode,
                            isRequired: false,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        // Street / Apartment
                        Expanded(
                          child: _buildAddressTextField(
                            context,
                            label: 'street_number'.tr,
                            hint: 'example_apartment'.tr,
                            controller: _streetNumberController,
                            focusNode: _streetNode,
                            isRequired: false,
                            inputAction: TextInputAction.done,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    // 🏷️ 3. Address Type ("اسم العنوان" / "احفظه باسم")
                    Text(
                      'label_as'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    _buildAddressTypeSelector(context, locationController),

                    // Custom Label TextField if "Other" is selected
                    if (_otherSelect) ...[
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      _buildAddressTextField(
                        context,
                        label: 'others'.tr,
                        hint: 'write_custom_address_name'.tr,
                        controller: _levelController,
                        focusNode: _levelNode,
                        prefixIcon: Icons.label_outline_rounded,
                      ),
                    ],

                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔘 4. Sticky Bottom Save Button
        _buildBottomButton(context, locationController),
      ],
    );
  }

  // -------------------------------------------------------------
  // 🗺️ Modern Map Card with Floating Capsule
  // -------------------------------------------------------------
  Widget _buildMapCard(
      BuildContext context, LocationController locationController) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 185,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialPosition, zoom: 16),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              onTap: (latLng) {
                Get.toNamed(
                  RouteHelper.getPickMapRoute('add-address', false),
                  arguments: PickMapScreen(
                    fromAddAddress: true,
                    fromSignUp: false,
                    googleMapController: locationController.mapController,
                    route: null,
                    canRoute: false,
                  ),
                );
              },
              zoomControlsEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: true,
              mapToolbarEnabled: false,
              onCameraIdle: () {
                locationController.updatePosition(_cameraPosition, true);
              },
              onCameraMove: ((position) => _cameraPosition = position),
              onMapCreated: (GoogleMapController controller) {
                locationController.setMapController(controller);
                if (widget.address == null) {
                  locationController.getCurrentLocation(true,
                      mapController: controller);
                }
              },
              style: isDark
                  ? Get.find<ThemeController>().darkMap
                  : Get.find<ThemeController>().lightMap,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer()),
                Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                Factory<ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer()),
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer()),
              },
            ),

            // Center Pin Marker
            Center(
              child: locationController.loading
                  ? const CircularProgressIndicator()
                  : Image.asset(Images.pickMarker, height: 44, width: 44),
            ),

            // Top-right Fullscreen Button
            Positioned(
              top: 10,
              left: 10,
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getPickMapRoute('add-address', false),
                    arguments: PickMapScreen(
                      fromAddAddress: true,
                      fromSignUp: false,
                      googleMapController: locationController.mapController,
                      route: null,
                      canRoute: false,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.fullscreen_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 🚀 Floating Address Capsule (Pill) at bottom of the map
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    RouteHelper.getPickMapRoute('add-address', false),
                    arguments: PickMapScreen(
                      fromAddAddress: true,
                      fromSignUp: false,
                      googleMapController: locationController.mapController,
                      route: null,
                      canRoute: false,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Edit Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Truncated Address Text
                      Expanded(
                        child: Text(
                          _addressController.text.isNotEmpty
                              ? _addressController.text
                              : 'pick_address'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Locate / Refresh Button
                      InkWell(
                        onTap: () => _checkPermission(() {
                          locationController.getCurrentLocation(
                            true,
                            mapController: locationController.mapController,
                          );
                        }),
                        child: Icon(
                          Icons.my_location_rounded,
                          size: 20,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🏷️ Address Type Selector (المنزل / العمل / آخر)
  // -------------------------------------------------------------
  Widget _buildAddressTypeSelector(
      BuildContext context, LocationController locationController) {
    return Row(
      children: List.generate(
        locationController.addressTypeList.length,
        (index) {
          final bool isSelected =
              locationController.addressTypeIndex == index;
          final String title = index == 0
              ? 'home'.tr
              : index == 1
                  ? 'office'.tr
                  : 'others'.tr;

          final IconData iconData = index == 0
              ? Icons.home_outlined
              : index == 1
                  ? Icons.business_center_outlined
                  : Icons.location_on_outlined;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == locationController.addressTypeList.length - 1
                    ? 0
                    : Dimensions.paddingSizeSmall,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _otherSelect = index == 2;
                  });
                  locationController.setAddressTypeIndex(index);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.08)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        iconData,
                        size: 22,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // 📝 Custom Card Input Field with Label & Red Asterisk
  // -------------------------------------------------------------
  Widget _buildAddressTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    bool isRequired = false,
    IconData? prefixIcon,
    TextInputType inputType = TextInputType.text,
    TextInputAction inputAction = TextInputAction.next,
    TextCapitalization capitalization = TextCapitalization.none,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with Red Asterisk
        RichText(
          text: TextSpan(
            text: label,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: robotoBold.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),

        // Input Container
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: inputType,
            textInputAction: nextFocus != null ? inputAction : TextInputAction.done,
            textCapitalization: capitalization,
            onChanged: onChanged,
            onSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
            },
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor.withOpacity(0.6),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 📞 Phone Field with Integrated Country Code Picker
  // -------------------------------------------------------------
  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'contact_person_number'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: robotoBold.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 6),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).disabledColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CodePickerWidget(
                onChanged: (CountryCode countryCode) {
                  _countryDialCode = countryCode.dialCode;
                },
                initialSelection: _countryDialCode ??
                    Get.find<LocalizationController>().locale.countryCode,
                favorite: [_countryDialCode ?? 'EG'],
                showDropDownButton: true,
                padding: EdgeInsets.zero,
                showFlagMain: true,
                dialogBackgroundColor: Theme.of(context).cardColor,
                textStyle: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: Theme.of(context).disabledColor.withOpacity(0.2),
              ),
              Expanded(
                child: TextField(
                  controller: _contactPersonNumberController,
                  focusNode: _numberNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.forGuest
                      ? TextInputAction.next
                      : TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(
                        widget.forGuest ? _emailFocus : _streetNode);
                  },
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'write_number'.tr,
                    hintStyle: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).disabledColor.withOpacity(0.6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // 🔘 Sticky Bottom Action Button
  // -------------------------------------------------------------
  Widget _buildBottomButton(
      BuildContext context, LocationController locationController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: locationController.isLoading
              ? null
              : () => _onSaveOrUpdateButtonPressed(locationController),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: locationController.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.forGuest
                        ? 'done'.tr
                        : widget.address == null
                            ? 'save_location'.tr
                            : 'update_address'.tr,
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault + 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🖥️ Desktop View (Preserved and styled)
  // -------------------------------------------------------------
  Widget _buildDesktopView(
      BuildContext context, LocationController locationController) {
    return SingleChildScrollView(
      child: FooterView(
        child: Column(
          children: [
            Container(
              height: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.10),
              child: Center(
                  child: Text('address'.tr,
                      style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge))),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Theme.of(context).cardColor,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 1)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMapCard(context, locationController),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Text('label_as'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeSmall)),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            _buildAddressTypeSelector(
                                context, locationController),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            _buildAddressTextField(
                              context,
                              label: 'delivery_address'.tr,
                              hint: 'write_delivery_address'.tr,
                              controller: _addressController,
                              focusNode: _addressNode,
                              nextFocus: _nameNode,
                              isRequired: true,
                              onChanged: (text) =>
                                  locationController.setPlaceMark(text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: Theme.of(context).cardColor,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 1)
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildAddressTextField(
                              context,
                              label: 'contact_person_name'.tr,
                              hint: 'write_name'.tr,
                              controller: _contactPersonNameController,
                              focusNode: _nameNode,
                              nextFocus: _numberNode,
                              isRequired: true,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            _buildPhoneField(context),
                            if (widget.forGuest) ...[
                              const SizedBox(
                                  height: Dimensions.paddingSizeLarge),
                              _buildAddressTextField(
                                context,
                                label: '${'email'.tr} (${'optional'.tr})',
                                hint: 'enter_email'.tr,
                                controller: _emailController,
                                focusNode: _emailFocus,
                                nextFocus: _streetNode,
                                inputType: TextInputType.emailAddress,
                              ),
                            ],
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAddressTextField(
                                    context,
                                    label: 'house'.tr,
                                    hint: 'example_building'.tr,
                                    controller: _houseController,
                                    focusNode: _houseNode,
                                    nextFocus: _floorNode,
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: _buildAddressTextField(
                                    context,
                                    label: 'floor'.tr,
                                    hint: 'example_floor'.tr,
                                    controller: _floorController,
                                    focusNode: _floorNode,
                                    nextFocus: _streetNode,
                                  ),
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: _buildAddressTextField(
                                    context,
                                    label: 'street_number'.tr,
                                    hint: 'example_apartment'.tr,
                                    controller: _streetNumberController,
                                    focusNode: _streetNode,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            _buildBottomButton(context, locationController),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ⚙️ Logic & Permission Handlers (100% Preserved)
  // -------------------------------------------------------------
  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    } else {
      onTap();
    }
  }

  void _onSaveOrUpdateButtonPressed(
      LocationController locationController) async {
    String numberWithCountryCode =
        (_countryDialCode ?? '+20') + _contactPersonNumberController.text.trim();
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    AddressModel? addressModel = _prepareAddressModel(
        locationController, phoneValid.isValid, numberWithCountryCode);
    if (addressModel == null) {
      return;
    }

    if (widget.forGuest) {
      addressModel.email = _emailController.text;
      Get.back(result: addressModel);
    } else {
      if (widget.address == null || widget.address?.id == null) {
        if (widget.fromCheckout) {
          Get.back(result: addressModel);
        } else {
          _addAddress(addressModel);
        }
      } else {
        _updateAddress(addressModel);
      }
    }
  }

  AddressModel? _prepareAddressModel(LocationController locationController,
      bool isValid, String numberWithCountryCode) {
    String? addressType =
        locationController.addressTypeList[locationController.addressTypeIndex];
    if (locationController.addressTypeIndex == 2) {
      addressType = _levelController.text.isNotEmpty
          ? _levelController.text.trim()
          : locationController
              .addressTypeList[locationController.addressTypeIndex];
    }
    if (_addressController.text.isEmpty) {
      showCustomSnackBar('please_enter_the_delivery_address'.tr);
    } else if (_contactPersonNameController.text.isEmpty) {
      showCustomSnackBar('please_enter_the_contact_person_name'.tr);
    } else if (_contactPersonNumberController.text.isEmpty) {
      showCustomSnackBar('please_enter_the_phone_number'.tr);
    } else if (!isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (widget.forGuest &&
        _emailController.text.isNotEmpty &&
        !GetUtils.isEmail(_emailController.text)) {
      showCustomSnackBar('invalid_email_address'.tr);
    } else {
      AddressModel addressModel = AddressModel(
        id: widget.address?.id,
        addressType: addressType,
        contactPersonName: _contactPersonNameController.text,
        contactPersonNumber:
            (_countryDialCode ?? '+20') + _contactPersonNumberController.text.trim(),
        address: _addressController.text,
        latitude: locationController.position.latitude.toString(),
        longitude: locationController.position.longitude.toString(),
        zoneId: locationController.zoneID != 0
            ? locationController.zoneID
            : widget.address?.zoneId,
        zoneIds: widget.address?.zoneIds,
        zoneData: widget.address?.zoneData,
        streetNumber: _streetNumberController.text,
        house: _houseController.text,
        floor: _floorController.text,
      );
      return addressModel;
    }
    return null;
  }

  void _addAddress(AddressModel addressModel) {
    Get.find<AddressController>()
        .addAddress(addressModel, widget.fromCheckout, widget.zoneId)
        .then((response) {
      if (response.isSuccess && !widget.fromCheckout) {
        widget.fromNavBar
            ? Get.back()
            : Get.offNamed(RouteHelper.getAddressRoute());
        showCustomSnackBar('new_address_added_successfully'.tr, isError: false);
      } else if (response.isSuccess && widget.fromCheckout) {
        AddressModel? addressModel;
        try {
          addressModel = Get.find<AddressController>().addressList![0];
        } catch (_) {}
        Get.back(result: addressModel);
        showCustomSnackBar(response.message, isError: false);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _updateAddress(AddressModel addressModel) {
    if (widget.address?.id == null) {
      _addAddress(addressModel);
      return;
    }
    Get.find<AddressController>()
        .updateAddress(addressModel, widget.address!.id)
        .then((response) {
      if (response.isSuccess) {
        Get.back();
        showCustomSnackBar(response.message, isError: false);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }
}
