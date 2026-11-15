import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/location/screens/pick_map_screen.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/parcel_view_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ParcelLocationScreen extends StatefulWidget {
  final ParcelCategoryModel category;
  const ParcelLocationScreen({super.key, required this.category});

  @override
  State<ParcelLocationScreen> createState() => _ParcelLocationScreenState();
}

class _ParcelLocationScreenState extends State<ParcelLocationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();
  final TextEditingController _senderStreetNumberController = TextEditingController();
  final TextEditingController _senderHouseController = TextEditingController();
  final TextEditingController _senderFloorController = TextEditingController();
  final TextEditingController _receiverStreetNumberController = TextEditingController();
  final TextEditingController _receiverHouseController = TextEditingController();
  final TextEditingController _receiverFloorController = TextEditingController();
  final TextEditingController _guestSenderEmailController = TextEditingController();
  final TextEditingController _guestReceiverEmailController = TextEditingController();
  final TextEditingController _senderManualAddressController = TextEditingController();
  final TextEditingController _receiverManualAddressController = TextEditingController();

  TabController? _tabController;
  String? _countryDialCode;
  bool _isSenderManualAddress = false;
  bool _isReceiverManualAddress = false;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  Future<void> initCall() async {
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty
        ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

    final parcelController = Get.find<ParcelController>();
    final savedUserAddress = AddressHelper.getUserAddressFromSharedPref();

    parcelController.setPickupAddress(savedUserAddress, false);
    _senderManualAddressController.text = savedUserAddress?.address ?? '';

    // Initialize destination address to null so receiver has to explicitly choose/write location
    parcelController.setDestinationAddress(null, notify: false);

    parcelController.setIsPickedUp(true, false);
    parcelController.setIsSender(true, false);
    parcelController.setSenderAddressIndex(0, canUpdate: false);
    parcelController.setReceiverAddressIndex(0, canUpdate: false);
    parcelController.setCountryCode(_countryDialCode!, true);
    parcelController.setCountryCode(_countryDialCode!, false);

    if (AuthHelper.isLoggedIn() && Get.find<AddressController>().addressList == null) {
      Get.find<AddressController>().getAddressList();
    }

    if (AuthHelper.isLoggedIn()) {
      if (Get.find<ProfileController>().proStatus) {
        Get.find<ProController>().getProActiveOffer(
          moduleType: Get.find<SplashController>().module?.moduleType,
        );
      }
      if (Get.find<ProfileController>().userInfoModel == null) {
        await Get.find<ProfileController>().getUserInfo();
      }

      final userInfo = Get.find<ProfileController>().userInfoModel;
      if (userInfo != null) {
        _senderNameController.text = '${userInfo.fName ?? ''} ${userInfo.lName ?? ''}'.trim();
        if (userInfo.phone != null && userInfo.phone!.isNotEmpty) {
          _countryDialCode = await splitPhoneNumber(userInfo.phone!, true);
          _senderPhoneController.text = await splitPhoneNumber(userInfo.phone!, false);
        }
        if (userInfo.email != null && userInfo.email!.isNotEmpty) {
          _guestSenderEmailController.text = userInfo.email!;
        }
      }
      parcelController.setCountryCode(_countryDialCode!, true);
      parcelController.setCountryCode(_countryDialCode!, false);
      if (mounted) setState(() {});
    }

    _tabController?.addListener(() {
      if (!(_tabController?.indexIsChanging ?? false)) {
        final isSender = _tabController!.index == 0;
        parcelController.setIsPickedUp(isSender, false);
        parcelController.setIsSender(isSender, true);
        if (mounted) setState(() {});
      }
    });
  }

  Future<String> splitPhoneNumber(String number, bool returnCountyCode) async {
    String code = '';
    String pNumber = '';
    try {
      PhoneNumber phoneNumber = PhoneNumber.parse(number);
      code = '+${phoneNumber.countryCode}';
      pNumber = phoneNumber.international.substring(_countryDialCode!.length);
    } catch (e) {
      debugPrint('number can\'t parse : $e');
    }
    return returnCountyCode ? code : pNumber;
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _senderStreetNumberController.dispose();
    _senderHouseController.dispose();
    _senderFloorController.dispose();
    _receiverStreetNumberController.dispose();
    _receiverHouseController.dispose();
    _receiverFloorController.dispose();
    _guestSenderEmailController.dispose();
    _guestReceiverEmailController.dispose();
    _senderManualAddressController.dispose();
    _receiverManualAddressController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'parcel_location'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<ParcelController>(builder: (parcelController) {
          final int currentIndex = _tabController?.index ?? 0;

          return Column(children: [
            // Custom modern Stepper Header
            _ParcelStepperHeader(
              currentIndex: currentIndex,
              onStepTapped: (index) {
                if (index == 1) {
                  _validateSender(parcelController);
                } else {
                  _tabController?.animateTo(0);
                  parcelController.setIsPickedUp(true, false);
                  parcelController.setIsSender(true, true);
                  setState(() {});
                }
              },
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ParcelViewWidget(
                    isSender: true,
                    nameController: _senderNameController,
                    phoneController: _senderPhoneController,
                    streetController: _senderStreetNumberController,
                    houseController: _senderHouseController,
                    floorController: _senderFloorController,
                    manualAddressController: _senderManualAddressController,
                    countryCode: parcelController.senderCountryCode,
                    isManualAddress: _isSenderManualAddress,
                    onAddressModeChanged: (isManual) {
                      setState(() => _isSenderManualAddress = isManual);
                    },
                    onPickMap: () => _openMapPicker(isSender: true),
                    guestEmailController: _guestSenderEmailController,
                  ),
                  ParcelViewWidget(
                    isSender: false,
                    nameController: _receiverNameController,
                    phoneController: _receiverPhoneController,
                    streetController: _receiverStreetNumberController,
                    houseController: _receiverHouseController,
                    floorController: _receiverFloorController,
                    manualAddressController: _receiverManualAddressController,
                    countryCode: parcelController.receiverCountryCode,
                    isManualAddress: _isReceiverManualAddress,
                    onAddressModeChanged: (isManual) {
                      setState(() => _isReceiverManualAddress = isManual);
                    },
                    onPickMap: () => _openMapPicker(isSender: false),
                    guestEmailController: _guestReceiverEmailController,
                  ),
                ],
              ),
            ),

            // Bottom Action Button
            _BottomButton(
              isSender: currentIndex == 0,
              onPressed: () {
                if (currentIndex == 0) {
                  _validateSender(parcelController);
                } else {
                  _validateReceiver(parcelController);
                }
              },
            ),
          ]);
        }),
      ),
    );
  }

  void _openMapPicker({required bool isSender}) {
    final parcelController = Get.find<ParcelController>();
    parcelController.setIsPickedUp(isSender, false);

    Get.toNamed(
      RouteHelper.getPickMapRoute('parcel', false),
      arguments: PickMapScreen(
        fromSignUp: false,
        fromAddAddress: false,
        canRoute: false,
        route: '',
        onPicked: (AddressModel address) async {
          ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(
            address.latitude.toString(),
            address.longitude.toString(),
            false,
          );

          AddressModel resolved = AddressModel(
            id: address.id,
            addressType: address.addressType,
            contactPersonNumber: address.contactPersonNumber,
            contactPersonName: address.contactPersonName,
            address: address.address,
            latitude: address.latitude,
            longitude: address.longitude,
            zoneId: responseModel.isSuccess ? responseModel.zoneIds[0] : 0,
            zoneIds: responseModel.zoneIds,
            method: address.method,
            streetNumber: address.streetNumber,
            house: address.house,
            floor: address.floor,
            zoneData: responseModel.zoneData,
          );

          if (isSender) {
            parcelController.setPickupAddress(resolved, true);
            parcelController.setSenderAddressIndex(0);
            _senderManualAddressController.text = address.address ?? '';
            if (address.streetNumber != null && address.streetNumber!.isNotEmpty) {
              _senderStreetNumberController.text = address.streetNumber!;
            }
            if (address.house != null && address.house!.isNotEmpty) {
              _senderHouseController.text = address.house!;
            }
            if (address.floor != null && address.floor!.isNotEmpty) {
              _senderFloorController.text = address.floor!;
            }
          } else {
            parcelController.setDestinationAddress(resolved);
            parcelController.setReceiverAddressIndex(0);
            _receiverManualAddressController.text = address.address ?? '';
            if (address.streetNumber != null && address.streetNumber!.isNotEmpty) {
              _receiverStreetNumberController.text = address.streetNumber!;
            }
            if (address.house != null && address.house!.isNotEmpty) {
              _receiverHouseController.text = address.house!;
            }
            if (address.floor != null && address.floor!.isNotEmpty) {
              _receiverFloorController.text = address.floor!;
            }
          }
          setState(() {});
        },
      ),
    );
  }

  Future<void> _validateSender(ParcelController parcelController) async {
    // 1. Validate Address
    if (_isSenderManualAddress) {
      if (_senderManualAddressController.text.trim().isEmpty) {
        showCustomSnackBar('please_enter_sender_address'.tr);
        _tabController?.animateTo(0);
        return;
      }
    } else {
      if (parcelController.pickupAddress == null) {
        showCustomSnackBar('select_pickup_address'.tr);
        _tabController?.animateTo(0);
        return;
      }
    }

    // 2. Validate Name
    if (_senderNameController.text.trim().isEmpty) {
      showCustomSnackBar('enter_sender_name'.tr);
      _tabController?.animateTo(0);
      return;
    }

    // 3. Validate Phone
    if (_senderPhoneController.text.trim().isEmpty) {
      showCustomSnackBar('enter_sender_phone_number'.tr);
      _tabController?.animateTo(0);
      return;
    }

    String numberWithCountryCode =
        '${parcelController.senderCountryCode ?? ''}${_senderPhoneController.text.trim()}';
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
      _tabController?.animateTo(0);
      return;
    }
    numberWithCountryCode = phoneValid.phone;

    // 4. Validate Email: ALWAYS OPTIONAL!
    final String email = _guestSenderEmailController.text.trim();
    if (email.isNotEmpty && !CustomValidator.isEmailValid(email)) {
      showCustomSnackBar('enter_valid_email_address'.tr);
      _tabController?.animateTo(0);
      return;
    }

    // Construct Sender AddressModel
    final baseAddress = parcelController.pickupAddress ?? AddressHelper.getUserAddressFromSharedPref();
    final String resolvedAddress = _isSenderManualAddress
        ? _senderManualAddressController.text.trim()
        : (parcelController.pickupAddress?.address ?? _senderManualAddressController.text.trim());

    AddressModel pickup = AddressModel(
      id: baseAddress?.id,
      addressType: baseAddress?.addressType ?? 'other',
      address: resolvedAddress,
      contactPersonName: _senderNameController.text.trim(),
      contactPersonNumber: numberWithCountryCode,
      latitude: baseAddress?.latitude ?? '0.0',
      longitude: baseAddress?.longitude ?? '0.0',
      method: baseAddress?.method,
      zoneId: baseAddress?.zoneId ?? 0,
      zoneIds: baseAddress?.zoneIds ?? [],
      zoneData: baseAddress?.zoneData ?? [],
      streetNumber: _senderStreetNumberController.text.trim(),
      house: _senderHouseController.text.trim(),
      floor: _senderFloorController.text.trim(),
      email: email.isNotEmpty ? email : null,
    );

    parcelController.setPickupAddress(pickup, true);
    _tabController?.animateTo(1);
    parcelController.setIsPickedUp(false, false);
    parcelController.setIsSender(false, true);
    setState(() {});
  }

  Future<void> _validateReceiver(ParcelController parcelController) async {
    // 1. Validate Address
    if (_isReceiverManualAddress) {
      if (_receiverManualAddressController.text.trim().isEmpty) {
        showCustomSnackBar('please_enter_receiver_address'.tr);
        return;
      }
    } else {
      if (parcelController.destinationAddress == null) {
        showCustomSnackBar('select_destination_address'.tr);
        return;
      }
    }

    // 2. Validate Name
    if (_receiverNameController.text.trim().isEmpty) {
      showCustomSnackBar('enter_receiver_name'.tr);
      return;
    }

    // 3. Validate Phone
    if (_receiverPhoneController.text.trim().isEmpty) {
      showCustomSnackBar('enter_receiver_phone_number'.tr);
      return;
    }

    String numberWithCountryCode =
        '${parcelController.receiverCountryCode ?? ''}${_receiverPhoneController.text.trim()}';
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
      return;
    }
    numberWithCountryCode = phoneValid.phone;

    // 4. Validate Email: ALWAYS OPTIONAL!
    final String email = _guestReceiverEmailController.text.trim();
    if (email.isNotEmpty && !CustomValidator.isEmailValid(email)) {
      showCustomSnackBar('enter_valid_email_address'.tr);
      return;
    }

    // Construct Receiver AddressModel
    final baseAddress = parcelController.destinationAddress ??
        parcelController.pickupAddress ??
        AddressHelper.getUserAddressFromSharedPref();

    final String resolvedAddress = _isReceiverManualAddress
        ? _receiverManualAddressController.text.trim()
        : (parcelController.destinationAddress?.address ?? _receiverManualAddressController.text.trim());

    AddressModel destination = AddressModel(
      id: baseAddress?.id,
      addressType: baseAddress?.addressType ?? 'other',
      address: resolvedAddress,
      contactPersonName: _receiverNameController.text.trim(),
      contactPersonNumber: numberWithCountryCode,
      latitude: baseAddress?.latitude ?? '0.0',
      longitude: baseAddress?.longitude ?? '0.0',
      method: baseAddress?.method,
      zoneId: baseAddress?.zoneId ?? 0,
      zoneIds: baseAddress?.zoneIds ?? [],
      zoneData: baseAddress?.zoneData ?? [],
      streetNumber: _receiverStreetNumberController.text.trim(),
      house: _receiverHouseController.text.trim(),
      floor: _receiverFloorController.text.trim(),
      email: email.isNotEmpty ? email : null,
    );

    parcelController.setDestinationAddress(destination);

    Get.toNamed(RouteHelper.getParcelRequestRoute(
      widget.category,
      parcelController.pickupAddress!,
      parcelController.destinationAddress!,
    ));
  }
}

class _ParcelStepperHeader extends StatelessWidget {
  final int currentIndex;
  final Function(int) onStepTapped;

  const _ParcelStepperHeader({required this.currentIndex, required this.onStepTapped});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall + 2,
      ),
      child: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Row(children: [
            Expanded(
              child: _StepTabItem(
                stepNumber: 1,
                title: 'sender_step'.tr,
                isActive: currentIndex == 0,
                isCompleted: currentIndex > 0,
                onTap: () => onStepTapped(0),
              ),
            ),
            Container(
              width: 32,
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              color: currentIndex >= 1
                  ? Theme.of(context).primaryColor
                  : (isDark ? Colors.grey[700] : Colors.grey[300]),
            ),
            Expanded(
              child: _StepTabItem(
                stepNumber: 2,
                title: 'receiver_step'.tr,
                isActive: currentIndex == 1,
                isCompleted: false,
                onTap: () => onStepTapped(1),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StepTabItem extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  const _StepTabItem({
    required this.stepNumber, required this.title, required this.isActive, required this.isCompleted, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isActive ? primaryColor.withValues(alpha: 0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 24,
            width: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isCompleted ? primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isActive || isCompleted ? Colors.white : Theme.of(context).disabledColor,
                    ),
                  ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isActive
                  ? robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: primaryColor)
                  : robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
            ),
          ),
        ]),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final bool isSender;
  final VoidCallback onPressed;

  const _BottomButton({required this.isSender, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: CustomButton(
            buttonText: isSender ? 'continue'.tr : 'save_and_continue'.tr,
            icon: Icons.arrow_forward_rounded,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
