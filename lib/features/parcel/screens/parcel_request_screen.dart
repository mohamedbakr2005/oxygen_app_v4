import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/not_logged_in_screen.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/condition_check_box.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/guest_create_account.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/tips_widget.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/delivery_instruction_bottom_sheet_widget.dart';
import 'package:Oxygen_Mart/features/payment/widgets/offline_payment_button.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ParcelRequestScreen extends StatefulWidget {
  final ParcelCategoryModel parcelCategory;
  final AddressModel pickedUpAddress;
  final AddressModel destinationAddress;
  const ParcelRequestScreen({
    super.key,
    required this.parcelCategory,
    required this.pickedUpAddress,
    required this.destinationAddress,
  });

  @override
  State<ParcelRequestScreen> createState() => _ParcelRequestScreenState();
}

class _ParcelRequestScreenState extends State<ParcelRequestScreen> {
  final TextEditingController _tipController = TextEditingController();
  final TextEditingController _guestPasswordController = TextEditingController();
  final TextEditingController _guestConfirmPasswordController = TextEditingController();
  final FocusNode _guestPasswordNode = FocusNode();
  final FocusNode _guestConfirmPasswordNode = FocusNode();
  bool _isLoggedIn = AuthHelper.isLoggedIn();
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  final JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    final parcelController = Get.find<ParcelController>();
    parcelController.getOfflineMethodList();
    parcelController.getDmTipMostTapped();
    parcelController.getDistance(widget.pickedUpAddress, widget.destinationAddress, category: widget.parcelCategory);
    parcelController.setPayerIndex(0, false);
    parcelController.setPaymentIndex(0, false); // Default to Cash on Delivery
    parcelController.startLoader(false, canUpdate: false);

    for (ZoneData zData in widget.pickedUpAddress.zoneData!) {
      if (zData.id == AddressHelper.getUserAddressFromSharedPref()!.zoneId) {
        _isCashOnDeliveryActive = zData.cashOnDelivery! &&
            Get.find<SplashController>().configModel!.cashOnDelivery!;
        _isDigitalPaymentActive = zData.digitalPayment! &&
            Get.find<SplashController>().configModel!.digitalPayment!;
        _isOfflinePaymentActive = zData.offlinePayment! &&
            Get.find<SplashController>().configModel!.offlinePaymentStatus!;
        break;
      }
    }
    if (Get.find<ProfileController>().userInfoModel == null && _isLoggedIn) {
      Get.find<ProfileController>().getUserInfo();
    }
    if (_isLoggedIn) {
      Get.find<ProController>().getProActiveOffer(
        moduleType: Get.find<SplashController>().module?.moduleType,
      );
    }
    parcelController.updateTips(
      Get.find<AuthController>().getDmTipIndex().isNotEmpty
          ? int.parse(Get.find<AuthController>().getDmTipIndex())
          : 0,
      notify: false,
    );

    if (Get.find<CheckoutController>().isCreateAccount) {
      Get.find<CheckoutController>().toggleCreateAccount(willUpdate: false);
    }

    parcelController.setInstructionselectedIndex(-1, notify: false);
    parcelController.setCustomNoteController('', notify: false);
    parcelController.setSelectedIndex(-1);
    parcelController.setCustomNote('');
  }

  @override
  void dispose() {
    _tipController.dispose();
    _guestPasswordController.dispose();
    _guestConfirmPasswordController.dispose();
    _guestPasswordNode.dispose();
    _guestConfirmPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = AuthHelper.isLoggedIn();
    final bool isGuestLoggedIn = AuthHelper.isGuestLoggedIn();
    final bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() &&
        Get.find<SplashController>().configModel!.guestCheckoutStatus!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'parcel_request'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: guestCheckoutPermission || _isLoggedIn
            ? GetBuilder<ParcelController>(builder: (parcelController) {
                return GetBuilder<CheckoutController>(builder: (checkoutController) {
                  double charge = -1;
                  double total = 0;
                  double dmTips = 0;
                  double proDiscount = 0;
                  double proDeliveryDiscount = 0;
                  double additionalCharge = Get.find<SplashController>()
                          .configModel!
                          .additionalChargeStatus!
                      ? Get.find<SplashController>().configModel!.additionCharge!
                      : 0;

                  final ProActiveBenefit? proBenefit =
                      Get.find<ProController>().activeOfferModel?.benefit;
                  final bool isPro = _isLoggedIn &&
                      (Get.find<ProfileController>().userInfoModel?.proStatus ?? false);

                  if (parcelController.distance != -1) {
                    final ParcelBill bill =
                        parcelController.calculateBill(widget.parcelCategory);
                    charge = bill.charge;
                    dmTips = bill.dmTips;
                    additionalCharge = bill.additionalCharge;
                    proDiscount = bill.proDiscount;
                    proDeliveryDiscount = bill.proDeliveryDiscount;
                    total = bill.total;
                  }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: ResponsiveHelper.isDesktop(context)
                            ? null
                            : const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                        child: FooterView(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),

                                // 1. Modern Category Header Card
                                _buildCategoryCard(context),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // 2. Connected Route & Location Details Card
                                _buildRouteCard(context),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // 3. Dual Metrics: Distance & Delivery Fee
                                _buildMetricsBar(context, parcelController, charge),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // 4. Driver Instruction Card
                                _buildInstructionCard(context, parcelController),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // Guest create account if applicable
                                if (isGuestLoggedIn) ...[
                                  GuestCreateAccount(
                                    guestPasswordController: _guestPasswordController,
                                    guestConfirmPasswordController:
                                        _guestConfirmPasswordController,
                                    guestPasswordNode: _guestPasswordNode,
                                    guestConfirmPasswordNode: _guestConfirmPasswordNode,
                                    fromParcel: true,
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                ],

                                // Driver Tips Widget (if enabled)
                                if (Get.find<SplashController>()
                                        .configModel!
                                        .dmTipsStatus ==
                                    1) ...[
                                  _buildTipsWidget(context, parcelController),
                                  const SizedBox(height: Dimensions.paddingSizeDefault),
                                ],

                                // 5. Who Will Pay Selector ("مين هيدفع؟")
                                _buildPayerSelector(context, parcelController),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // 6. Modern Payment Methods Cards (Zero overlap)
                                _buildPaymentSection(
                                  context,
                                  parcelController,
                                  isGuestLoggedIn,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                // 7. Order Summary Breakdown
                                _buildOrderSummary(
                                  context,
                                  parcelController,
                                  charge,
                                  dmTips,
                                  additionalCharge,
                                  proDiscount,
                                  proDeliveryDiscount,
                                  total,
                                  isPro,
                                  proBenefit,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                // Terms Condition Checkbox
                                const CheckoutCondition(isParcel: true),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                                if (ResponsiveHelper.isDesktop(context))
                                  _buildBottomButton(
                                    parcelController,
                                    total,
                                    isGuestLoggedIn: isGuestLoggedIn,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!ResponsiveHelper.isDesktop(context))
                      _buildBottomButton(
                        parcelController,
                        total,
                        isGuestLoggedIn: isGuestLoggedIn,
                      ),
                  ],
                );
              });
            })
            : NotLoggedInScreen(callBack: (value) {
                initCall();
                setState(() {});
              }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Category Header Card
  // ---------------------------------------------------------------------------
  Widget _buildCategoryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.25),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CustomImage(
                image: '${widget.parcelCategory.imageFullUrl}',
                height: 52,
                width: 52,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.parcelCategory.name ?? '',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'parcel'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.parcelCategory.description != null &&
                    widget.parcelCategory.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.parcelCategory.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Connected Route & Location Details Card
  // ---------------------------------------------------------------------------
  Widget _buildRouteCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          // Pickup Address (Sender)
          _buildAddressPoint(
            context,
            isPickup: true,
            title: 'sender_details'.tr,
            address: widget.pickedUpAddress,
          ),

          // Route Connector Line
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 18),
            child: Row(
              children: [
                Column(
                  children: List.generate(
                    4,
                    (index) => Container(
                      width: 2.5,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.07),
                    thickness: 1,
                  ),
                ),
              ],
            ),
          ),

          // Destination Address (Receiver)
          _buildAddressPoint(
            context,
            isPickup: false,
            title: 'receiver_details'.tr,
            address: widget.destinationAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPoint(
    BuildContext context, {
    required bool isPickup,
    required String title,
    required AddressModel address,
  }) {
    final Color markerColor = isPickup ? const Color(0xFF10B981) : const Color(0xFFF97316);
    final IconData markerIcon =
        isPickup ? Icons.radio_button_checked_rounded : Icons.location_on_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marker Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: markerColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(markerIcon, color: markerColor, size: 20),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          // Address details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and contact person name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: markerColor,
                      ),
                    ),
                    if (address.contactPersonName != null &&
                        address.contactPersonName!.isNotEmpty)
                      Flexible(
                        child: Text(
                          address.contactPersonName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),

                // Street / Address
                Text(
                  address.address ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Details chips: street number, house, floor & phone
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (address.streetNumber != null &&
                        address.streetNumber!.isNotEmpty)
                      _buildInfoChip(
                        context,
                        Icons.signpost_outlined,
                        '${'street_number'.tr}: ${address.streetNumber}',
                      ),
                    if (address.house != null &&
                        address.house != 'null' &&
                        address.house!.isNotEmpty)
                      _buildInfoChip(
                        context,
                        Icons.home_outlined,
                        '${'house'.tr}: ${address.house}',
                      ),
                    if (address.floor != null && address.floor!.isNotEmpty)
                      _buildInfoChip(
                        context,
                        Icons.layers_outlined,
                        '${'floor'.tr}: ${address.floor}',
                      ),
                    if (address.contactPersonNumber != null &&
                        address.contactPersonNumber!.isNotEmpty)
                      _buildInfoChip(
                        context,
                        Icons.phone_outlined,
                        address.contactPersonNumber!,
                        isPhone: true,
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String text,
      {bool isPhone = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPhone
            ? Theme.of(context).primaryColor.withOpacity(0.08)
            : Theme.of(context).disabledColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isPhone
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: isPhone
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Dual Metrics: Distance & Delivery Fee
  // ---------------------------------------------------------------------------
  Widget _buildMetricsBar(
      BuildContext context, ParcelController parcelController, double charge) {
    return Row(
      children: [
        // Distance Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(Images.distance, height: 24, width: 24),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'distance'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parcelController.distance == -1
                            ? 'calculating'.tr
                            : '${parcelController.distance!.toStringAsFixed(2)} ${'km'.tr}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        // Delivery Fee Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(Images.delivery, height: 24, width: 24),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'delivery_fee'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parcelController.distance == -1 || (Get.find<CheckoutController>().summaryLoading && charge <= 0)
                            ? 'calculating'.tr
                            : PriceConverter.convertPrice(charge),
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Driver Instruction Card
  // ---------------------------------------------------------------------------
  Widget _buildInstructionCard(
      BuildContext context, ParcelController parcelController) {
    final bool hasInstruction = parcelController.selectedIndexNote != -1 ||
        parcelController.customNote!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'add_more_delivery_instruction'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (!ResponsiveHelper.isDesktop(context)) {
                    Get.bottomSheet(
                      const DeliveryInstructionBottomSheetWidget(),
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => const Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(Dimensions.radiusDefault),
                          ),
                        ),
                        child: DeliveryInstructionBottomSheetWidget(),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasInstruction ? Icons.edit_rounded : CupertinoIcons.add,
                        size: 15,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasInstruction ? 'edit'.tr : 'add'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (hasInstruction) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.08),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    Images.parcelInstructionIcon,
                    height: 22,
                    width: 22,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (parcelController.selectedIndexNote != -1)
                          Text(
                            parcelController
                                    .parcelInstructionList![
                                        parcelController.selectedIndexNote!]
                                    .instruction ??
                                '',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        if (parcelController.customNote!.isNotEmpty)
                          Text(
                            parcelController.customNote!,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      parcelController.setInstructionselectedIndex(-1, notify: false);
                      parcelController.setCustomNoteController('');
                      parcelController.setSelectedIndex(-1);
                      parcelController.setCustomNote('');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Who Will Pay Selector ("مين هيدفع؟")
  // ---------------------------------------------------------------------------
  Widget _buildPayerSelector(BuildContext context, ParcelController parcelController) {
    final bool isSenderPaying = parcelController.payerIndex == 0;
    final bool isReceiverPaying = parcelController.payerIndex == 1;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'charge_pay_by'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(
            children: [
              // 1. Sender Pays Card
              Expanded(
                child: _buildPayerCard(
                  context,
                  title: parcelController.payerTypes[0].tr,
                  subtitle: 'sender_pays_sub'.tr.isNotEmpty &&
                          'sender_pays_sub'.tr != 'sender_pays_sub'
                      ? 'sender_pays_sub'.tr
                      : 'الدفع عند الاستلام',
                  icon: Icons.arrow_upward_rounded,
                  isSelected: isSenderPaying,
                  onTap: () => parcelController.setPayerIndex(0, true),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              // 2. Receiver Pays Card
              Expanded(
                child: _buildPayerCard(
                  context,
                  title: parcelController.payerTypes[1].tr,
                  subtitle: 'receiver_pays_sub'.tr.isNotEmpty &&
                          'receiver_pays_sub'.tr != 'receiver_pays_sub'
                      ? 'receiver_pays_sub'.tr
                      : 'الدفع عند التسليم',
                  icon: Icons.arrow_downward_rounded,
                  isSelected: isReceiverPaying,
                  onTap: () {
                    parcelController.setPayerIndex(1, true);
                    // Receiver can only pay COD
                    parcelController.setPaymentIndex(0, true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayerCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color activeColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : Theme.of(context).dividerColor.withOpacity(0.12),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.15)
                        : Theme.of(context).disabledColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? activeColor : Theme.of(context).hintColor,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? activeColor : Theme.of(context).disabledColor,
                      width: isSelected ? 5.5 : 1.5,
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (isSelected ? robotoBold : robotoMedium).copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: isSelected
                    ? activeColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Modern Payment Method Cards (No Overlapping in RTL!)
  // ---------------------------------------------------------------------------
  Widget _buildPaymentSection(
    BuildContext context,
    ParcelController parcelController,
    bool isGuestLoggedIn,
  ) {
    final bool isReceiverPaying = parcelController.payerIndex == 1;
    final bool showWallet = Get.find<SplashController>()
                .configModel!
                .customerWalletStatus ==
            1 &&
        !isReceiverPaying &&
        !isGuestLoggedIn;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'payment_method'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Cash on Delivery Card
          if (_isCashOnDeliveryActive!)
            _buildModernPaymentCard(
              context,
              title: 'cash_on_delivery'.tr,
              subtitle: 'pay_your_payment_after_getting_item'.tr,
              iconPath: Images.cashOnDelivery,
              accentColor: const Color(0xFF10B981),
              isSelected: parcelController.paymentIndex == 0,
              onTap: () => parcelController.setPaymentIndex(0, true),
            ),

          // Wallet Payment Card (Only for sender)
          if (showWallet) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildModernPaymentCard(
              context,
              title: 'wallet_payment'.tr,
              subtitle: '${'balance'.tr}: ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0)}',
              iconPath: Images.wallet,
              accentColor: const Color(0xFF6366F1),
              isSelected: parcelController.paymentIndex == 1,
              onTap: () => parcelController.setPaymentIndex(1, true),
            ),
          ],

          // Digital Online Payment Methods (Only for sender)
          if (_isDigitalPaymentActive! && !isReceiverPaying) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'pay_via_online'.tr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: Get.find<SplashController>()
                      .configModel!
                      .activePaymentMethodList
                      ?.length ??
                  0,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final paymentMethod = Get.find<SplashController>()
                    .configModel!
                    .activePaymentMethodList![index];
                final bool isSelected = parcelController.paymentIndex == 2 &&
                    paymentMethod.getWay! == parcelController.digitalPaymentName;

                return InkWell(
                  onTap: () {
                    parcelController.setPaymentIndex(2, true);
                    parcelController.changeDigitalPaymentName(paymentMethod.getWay!);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.06)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor.withOpacity(0.1),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomImage(
                          height: 24,
                          width: 40,
                          fit: BoxFit.contain,
                          image: paymentMethod.getWayImageFullUrl ?? '',
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            paymentMethod.getWayTitle ?? '',
                            style: (isSelected ? robotoBold : robotoMedium).copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],

          // Offline Payment (Only for sender)
          if (parcelController.offlineMethodList != null && !isReceiverPaying) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            OfflinePaymentButton(
              isSelected: parcelController.paymentIndex == 3,
              offlineMethodList: parcelController.offlineMethodList!,
              isOfflinePaymentActive: _isOfflinePaymentActive,
              onTap: () => parcelController.setPaymentIndex(3, true),
              parcelController: parcelController,
              forParcel: true,
              checkoutController: Get.find<CheckoutController>(),
              tooltipController: tooltipController,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernPaymentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconPath,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color activeColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : Theme.of(context).dividerColor.withOpacity(0.12),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            // Leading Icon container
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(iconPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            // Middle Text Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isSelected ? robotoBold : robotoMedium).copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),

            // Dedicated Trailing Checkmark / Radio Badge (Clean and completely non-overlapping)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? activeColor : Theme.of(context).disabledColor.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Order Summary Breakdown
  // ---------------------------------------------------------------------------
  Widget _buildOrderSummary(
    BuildContext context,
    ParcelController parcelController,
    double charge,
    double dmTips,
    double additionalCharge,
    double proDiscount,
    double proDeliveryDiscount,
    double total,
    bool isPro,
    ProActiveBenefit? proBenefit,
  ) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'order_summary'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Delivery fee row
          _buildSummaryRow(
            context,
            title: 'delivery_fee'.tr,
            value: parcelController.distance == -1 || (Get.find<CheckoutController>().summaryLoading && charge <= 0)
                ? 'calculating'.tr
                : PriceConverter.convertPrice(charge),
            isHighlighted: parcelController.distance == -1 || (Get.find<CheckoutController>().summaryLoading && charge <= 0),
          ),

          // Pro delivery fee discount
          if (isPro &&
              proBenefit?.type == ProBenefitType.deliveryFee &&
              proDeliveryDiscount > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildSummaryRow(
              context,
              title: 'delivery_fee_discount_pro'.tr,
              value: '(-) ${PriceConverter.convertPrice(proDeliveryDiscount)}',
              valueColor: Colors.green,
            ),
          ],

          // Pro general discount
          if (isPro &&
              proBenefit?.type == ProBenefitType.discount &&
              proDiscount > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildSummaryRow(
              context,
              title: 'discount_pro'.tr,
              value: '(-) ${PriceConverter.convertPrice(proDiscount)}',
              valueColor: Colors.green,
            ),
          ],

          // Driver tips row
          if (Get.find<SplashController>().configModel!.dmTipsStatus == 1 &&
              dmTips > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildSummaryRow(
              context,
              title: 'delivery_man_tips'.tr,
              value: '(+) ${PriceConverter.convertPrice(dmTips)}',
            ),
          ],

          // Additional charge
          if (Get.find<SplashController>().configModel!.additionalChargeStatus! &&
              additionalCharge > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _buildSummaryRow(
              context,
              title: Get.find<SplashController>().configModel!.additionalChargeName ?? '',
              value: '(+) ${PriceConverter.convertPrice(additionalCharge)}',
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.12),
              thickness: 1,
            ),
          ),

          // Total Amount Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_amount'.tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              PriceConverter.convertAnimationPrice(
                total,
                textStyle: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required String value,
    Color? valueColor,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          value,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: valueColor ??
                (isHighlighted
                    ? Colors.red
                    : Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tips Widget
  // ---------------------------------------------------------------------------
  Widget _buildTipsWidget(BuildContext context, ParcelController parcelController) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('delivery_man_tips'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          SizedBox(
            height: (parcelController.selectedTips == AppConstants.tips.length - 1) &&
                    parcelController.canShowTipsField
                ? 0
                : 48,
            child: (parcelController.selectedTips == AppConstants.tips.length - 1) &&
                    parcelController.canShowTipsField
                ? const SizedBox()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppConstants.tips.length,
                    itemBuilder: (context, index) {
                      return TipsWidget(
                        title: AppConstants.tips[index] == '0'
                            ? 'not_now'.tr
                            : (index != AppConstants.tips.length - 1)
                                ? PriceConverter.convertPrice(
                                    double.parse(AppConstants.tips[index].toString()),
                                    forDM: true,
                                  )
                                : AppConstants.tips[index].tr,
                        isSelected: parcelController.selectedTips == index,
                        isSuggested: index != 0 &&
                            AppConstants.tips[index] ==
                                parcelController.mostDmTipAmount.toString(),
                        onTap: () {
                          parcelController.updateTips(index);
                          if (parcelController.selectedTips != 0 &&
                              parcelController.selectedTips !=
                                  AppConstants.tips.length - 1) {
                            parcelController.addTips(
                              double.parse(AppConstants.tips[index]),
                            );
                          }
                          if (parcelController.selectedTips ==
                              AppConstants.tips.length - 1) {
                            parcelController.showTipsField();
                          }
                          _tipController.text = parcelController.tips.toString();
                        },
                      );
                    },
                  ),
          ),
          if (parcelController.selectedTips == AppConstants.tips.length - 1 &&
              parcelController.canShowTipsField) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    titleText: 'enter_amount'.tr,
                    controller: _tipController,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.number,
                    onSubmit: (value) {
                      if (value.isNotEmpty) {
                        final parsed = double.tryParse(value) ?? 0;
                        if (parsed >= 0) {
                          parcelController.addTips(parsed);
                        } else {
                          showCustomSnackBar('tips_can_not_be_negative'.tr);
                        }
                      } else {
                        parcelController.addTips(0.0);
                      }
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                InkWell(
                  onTap: () {
                    parcelController.updateTips(0);
                    parcelController.showTipsField();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.clear, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Bottom Action Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomButton(
    ParcelController parcelController,
    double totalAmount, {
    bool isGuestLoggedIn = false,
  }) {
    final bool isInstructionSelected = parcelController.selectedIndexNote != -1;
    final bool isCustomNote = parcelController.customNote!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: CustomButton(
          buttonText: 'confirm_parcel_request'.tr,
          isLoading: parcelController.isLoading,
          radius: 14,
          onPressed: parcelController.acceptTerms
              ? () {
                  if (parcelController.distance == -1 || Get.find<CheckoutController>().summaryLoading) {
                    showCustomSnackBar('delivery_fee_not_set_yet'.tr);
                  } else if (parcelController.tips < 0) {
                    showCustomSnackBar('tips_can_not_be_negative'.tr);
                  } else if (parcelController.paymentIndex == -1) {
                    showCustomSnackBar('please_select_payment_method_first'.tr);
                  } else {
                    final placeOrderBody = PlaceOrderBodyModel(
                      isGuest: isGuestLoggedIn ? 1 : 0,
                      cart: [],
                      couponDiscountAmount: null,
                      distance: parcelController.distance,
                      scheduleAt: null,
                      orderAmount: totalAmount > 0 ? totalAmount : 0,
                      orderNote: '',
                      orderType: 'parcel',
                      receiverDetails: widget.destinationAddress,
                      paymentMethod: parcelController.paymentIndex == 0
                          ? 'cash_on_delivery'
                          : parcelController.paymentIndex == 1
                              ? 'wallet'
                              : parcelController.paymentIndex == 2
                                  ? 'digital_payment'
                                  : 'offline_payment',
                      couponCode: null,
                      storeId: null,
                      address: widget.pickedUpAddress.address,
                      latitude: widget.pickedUpAddress.latitude,
                      longitude: widget.pickedUpAddress.longitude,
                      senderZoneId: widget.pickedUpAddress.zoneId,
                      addressType: widget.pickedUpAddress.addressType,
                      contactPersonName:
                          widget.pickedUpAddress.contactPersonName ?? '',
                      contactPersonNumber:
                          widget.pickedUpAddress.contactPersonNumber ?? '',
                      streetNumber: widget.pickedUpAddress.streetNumber ?? '',
                      house: widget.pickedUpAddress.house ?? '',
                      floor: widget.pickedUpAddress.floor ?? '',
                      discountAmount: 0,
                      taxAmount: 0,
                      parcelCategoryId: widget.parcelCategory.id.toString(),
                      chargePayer:
                          parcelController.payerTypes[parcelController.payerIndex],
                      dmTips: parcelController.tips.toString(),
                      cutlery: 0,
                      unavailableItemNote: '',
                      deliveryInstruction: (isInstructionSelected
                              ? '${parcelController.parcelInstructionList![parcelController.selectedIndexNote!].instruction}'
                              : '') +
                          (isInstructionSelected
                              ? (isCustomNote
                                  ? " (${parcelController.customNote})"
                                  : '')
                              : (isCustomNote
                                  ? parcelController.customNote ?? ''
                                  : '')),
                      partialPayment: 0,
                      guestId: AuthHelper.isGuestLoggedIn()
                          ? int.parse(AuthHelper.getGuestId())
                          : 0,
                      isBuyNow: 0,
                      guestEmail: (widget.pickedUpAddress.email != null &&
                              widget.pickedUpAddress.email!.isNotEmpty)
                          ? widget.pickedUpAddress.email
                          : null,
                      extraPackagingAmount: null,
                      createNewUser:
                          Get.find<CheckoutController>().isCreateAccount ? 1 : 0,
                      password: null,
                    );

                    parcelController.startLoader(true);
                    parcelController.placeOrder(
                      placeOrderBody,
                      widget.pickedUpAddress.zoneId,
                      totalAmount,
                      0,
                      false,
                      false,
                      forParcel: true,
                      isOfflinePay: parcelController.paymentIndex == 3,
                    );
                  }
                }
              : null,
        ),
      ),
    );
  }
}
