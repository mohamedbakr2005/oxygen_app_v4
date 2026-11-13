import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:Oxygen_Mart/common/widgets/address_widget.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/coupon/controllers/coupon_controller.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
// import 'package:Oxygen_Mart/features/pro/widgets/pro_cart_banner_widget.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/helper/bundle_amount_helper.dart';
import 'package:Oxygen_Mart/common/models/config_model.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/helper/shallow_route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_dropdown.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/not_logged_in_screen.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/checkout_screen_shimmer_view.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/bottom_section.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/top_section.dart';
import 'package:Oxygen_Mart/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:Oxygen_Mart/features/happy_hour/widgets/happy_hour_milestone_banner_widget.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;
  const CheckoutScreen({super.key, required this.fromCart, required this.cartList, required this.storeId});

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {

  final ScrollController _scrollController = ScrollController();
  final JustTheController tooltipController1 = JustTheController();
  final JustTheController tooltipController2 = JustTheController();
  final JustTheController tooltipController3 = JustTheController();

  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  bool _isOfflinePaymentActive = false;
  List<CartModel?>? _cartList;
  bool _isWalletActive = false;
  String _deliveryChargeForView = '';

  List<AddressModel> address = [];
  bool canCheckSmall = false;
  bool _isCashBackSnackBarShown = false;
  double badWeatherChargeForToolTip = 0;
  double extraChargeForToolTip = 0;
  bool isPassedVariationPrice = false;

  final TextEditingController guestContactPersonNameController = TextEditingController();
  final TextEditingController guestContactPersonNumberController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestPasswordController = TextEditingController();
  final TextEditingController guestConfirmPasswordController = TextEditingController();
  final FocusNode guestNumberNode = FocusNode();
  final FocusNode guestEmailNode = FocusNode();
  final FocusNode guestPasswordNode = FocusNode();
  final FocusNode guestConfirmPasswordNode = FocusNode();

  double? _lastCouponDiscount;
  bool _firstTimeCheckPayment = false;
  bool isCampaign = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    initCall();
    print('=======guest id: ${AuthHelper.getGuestId()}');
  }

  Future<void> initCall() async {


    bool isLoggedIn = AuthHelper.isLoggedIn();
    Get.find<CheckoutController>().resetOrderTax();
    Get.find<CheckoutController>().initAdditionData();
    Get.find<CheckoutController>().couponController.text = '';

    Get.find<CheckoutController>().clearPrevData();
    Get.find<CheckoutController>().getDmTipMostTapped();
    Get.find<CheckoutController>().setPreferenceTimeForView('', isUpdate: false);
    Get.find<CheckoutController>().setExchangeAmount(0);

    Get.find<CheckoutController>().getOfflineMethodList();

    if(Get.find<CheckoutController>().isCreateAccount) {
      Get.find<CheckoutController>().toggleCreateAccount(willUpdate: false);
    }

    if(Get.find<CheckoutController>().isPartialPay){
      Get.find<CheckoutController>().changePartialPayment(isUpdate: false);
    }

    if(isLoggedIn) {
      // if(!GetPlatform.isWeb) {
        Get.find<CheckoutController>().insertAddresses(AddressHelper.getUserAddressFromSharedPref()!, notify: false);
      // }
      // Clear house and floor fields to start empty on each checkout
      Get.find<CheckoutController>().houseController.clear();
      Get.find<CheckoutController>().floorController.clear();
      if(Get.find<ProfileController>().userInfoModel == null) {
        Get.find<ProfileController>().getUserInfo().then((v) {
          if(Get.find<ProfileController>().userInfoModel != null && GetPlatform.isWeb) {
            Get.find<CheckoutController>().insertAddresses(AddressHelper.getUserAddressFromSharedPref()!, notify: false);
          }
        });
      }
      if(Get.find<ProfileController>().proStatus){
        Get.find<ProController>().getProActiveOffer(moduleType: Get.find<SplashController>().module?.moduleType);
      }

      if(Get.find<AddressController>().addressList == null) {
        Get.find<AddressController>().getAddressList();
      }
    } else {
      Get.find<CheckoutController>().setGuestAddress(AddressHelper.getUserAddressFromSharedPref(), isUpdate: false);
    }

    if(widget.storeId == null){
      _cartList = [];
      if(GetPlatform.isWeb) {
       await Get.find<CartController>().getAllCarts();
      }
      widget.fromCart ? _cartList!.addAll(Get.find<CartController>().cartList) : _cartList!.addAll(widget.cartList!);
      if(_cartList != null && _cartList!.isNotEmpty) {
        Get.find<CheckoutController>().initCheckoutData(_storeIdFromCart());
      }
    }

    if(isLoggedIn) {
      Get.find<CouponController>().getCouponList(
        customerId: Get.find<ProfileController>().userInfoModel?.id,
        storeId: widget.storeId ?? _storeIdFromCart(),
      );
    }

    if(widget.storeId != null){
      Get.find<CheckoutController>().initCheckoutData(widget.storeId);
      Get.find<CouponController>().removeCouponData(false);
    }
    Get.find<CheckoutController>().pickPrescriptionImage(isRemove: true, isCamera: false);
    _isWalletActive = Get.find<SplashController>().configModel!.customerWalletStatus == 1;
    Get.find<CheckoutController>().updateTips(
      Get.find<CheckoutController>().getSharedPrefDmTipIndex().isNotEmpty ? int.parse(Get.find<CheckoutController>().getSharedPrefDmTipIndex()) : PriceConverter.noTipIndex,
      notify: false,
    );
    Get.find<CheckoutController>().tipController.text = Get.find<CheckoutController>().selectedTips != -1 ? AppConstants.tips[Get.find<CheckoutController>().selectedTips] : '';
  }

  void _setSinglePaymentActive() {
    if((!_firstTimeCheckPayment && !_isCashOnDeliveryActive! && _isDigitalPaymentActive! && Get.find<SplashController>().configModel!.activePaymentMethodList!.length == 1) && ((!_isWalletActive && AuthHelper.isLoggedIn()) || !AuthHelper.isLoggedIn()) ) {
      Future.delayed(const Duration(milliseconds: 600), (){
        if (!mounted) return;
        Get.find<CheckoutController>().setPaymentMethod(2, isUpdate: false);
        Get.find<CheckoutController>().changeDigitalPaymentName(Get.find<SplashController>().configModel!.activePaymentMethodList![0].getWay!, willUpdate: false);
        _firstTimeCheckPayment = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    guestContactPersonNameController.dispose();
    guestContactPersonNumberController.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Module? module = Get.find<SplashController>().configModel!.moduleConfig!.module;
    bool guestCheckoutPermission = AuthHelper.isGuestLoggedIn() && Get.find<SplashController>().configModel!.guestCheckoutStatus!;
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isGuestLogIn = AuthHelper.isGuestLoggedIn();

    Future.delayed(const Duration(milliseconds: 100), () {
      if(AddressHelper.getUserAddressFromSharedPref() == null && GetPlatform.isWeb) {
        Get.find<SplashController>().setModule(null);
        ShallowRouterHelper.updateParameter('module', '');
        Future.delayed(const Duration(milliseconds: 10), () {
          Get.offAllNamed(RouteHelper.getInitialRoute(moduleId: 'null'));
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'checkout'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: guestCheckoutPermission || AuthHelper.isLoggedIn() ? GetBuilder<CheckoutController>(builder: (checkoutController) {

        List<DropdownItem<int>> addressList = _getDropdownAddressList(context: context, addressList: Get.find<AddressController>().addressList, store: checkoutController.store);
        address = _getAddressList(addressList: Get.find<AddressController>().addressList, store: checkoutController.store);

        bool todayClosed = false;
        bool tomorrowClosed = false;
        Pivot? moduleData = _getModuleData(store: checkoutController.store);
        _isCashOnDeliveryActive = _checkCODActive(store: checkoutController.store);
        _isDigitalPaymentActive = _checkDigitalPaymentActive(store: checkoutController.store);
        _isOfflinePaymentActive = (Get.find<SplashController>().configModel?.offlinePaymentStatus ?? false) && _checkZoneOfflinePaymentOnOff(addressModel: AddressHelper.getUserAddressFromSharedPref(), checkoutController: checkoutController);
        print('====> COD : $_isCashOnDeliveryActive, Digital : $_isDigitalPaymentActive, Offline : $_isOfflinePaymentActive');

        if(checkoutController.isFirstTimeCodActive && (_isCashOnDeliveryActive ?? false)){
          Future.delayed(Duration.zero, () => checkoutController.setPaymentMethod(0));
        }

        if(checkoutController.store != null) {
          todayClosed = checkoutController.isStoreClosed(true, checkoutController.store!.active ?? false, checkoutController.store!.schedules);
          tomorrowClosed = checkoutController.isStoreClosed(false, checkoutController.store!.active ?? false, checkoutController.store!.schedules);
          _taxPercent = checkoutController.store!.tax;
        }
        return GetBuilder<CouponController>(builder: (couponController) {
          return GetBuilder<HappyHourController>(builder: (happyHourController) {
          double? maxCodOrderAmount;

          if(moduleData != null) {
            maxCodOrderAmount = moduleData.maximumCodOrderAmount;
          }
          double price = _calculatePrice(store: checkoutController.store, cartList: _cartList);
          double addOns = _calculateAddonsPrice(store: checkoutController.store, cartList: _cartList);
          double variations = _calculateVariationPrice(store: checkoutController.store, cartList: _cartList, calculateWithoutDiscount: true);
          double? itemDiscountPrice = _calculateDiscountPrice(store: checkoutController.store, cartList: _cartList, price: price, addOns: addOns, calStoreDiscount: false);
          double? storeDiscountPrice = _calculateDiscountPrice(store: checkoutController.store, cartList: _cartList, price: price, addOns: addOns, calStoreDiscount: true);

          double subTotal = _calculateSubTotal(price: price, addOns: addOns, variations: variations, cartList: _cartList);

          double? discount = happyHourController.discountAmountFor(
            storeId: checkoutController.store?.id,
            fallback: _getDiscountPrice(storeDiscountPrice, itemDiscountPrice),
          );
          double couponDiscount = PriceConverter.toFixed(couponController.discount ?? 0);

          print('========coupon discount: $couponDiscount');

          double referralDiscount = _calculateReferralDiscount(
            subTotal - BundleAmountHelper.netAmount(_cartList), discount, couponDiscount,
          );

          double orderAmount = _calculateOrderAmount(
            price: price, variations: variations, discount: discount, addOns: addOns,
            couponDiscount: couponDiscount, cartList: _cartList, referralDiscount: referralDiscount,
          );

          if((checkoutController.isFirstTime || _lastCouponDiscount != couponController.discount)
              && ((widget.storeId == null && checkoutController.store != null) || widget.storeId != null)) {
            _lastCouponDiscount = couponController.discount;

            Future.delayed(const Duration(milliseconds: 50), () {
              List<OnlineCart> carts = [];

              if(widget.storeId == null && _cartList != null) {
                for (int index = 0; index < _cartList!.length; index++) {
                  CartModel cart = _cartList![index]!;
                  if(cart.isCampaign ?? false) {
                    isCampaign = true;
                  }
                  if(cart.isAtomicBundle || cart.item == null) {
                    continue;
                  }
                  List<int?> addOnIdList = [];
                  List<int?> addOnQtyList = [];
                  for (var addOn in cart.addOnIds ?? <AddOn>[]) {
                    addOnIdList.add(addOn.id);
                    addOnQtyList.add(addOn.quantity);
                  }

                  List<OrderVariation> variations = [];
                  if(Get.find<SplashController>().getModuleConfig(cart.item?.moduleType).newVariation!) {
                    for(int i=0; i<(cart.item?.foodVariations?.length ?? 0); i++) {
                      if(cart.foodVariations![i].contains(true)) {
                        variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                        for(int j=0; j<(cart.item?.foodVariations![i].variationValues?.length ?? 0); j++) {
                          if(cart.foodVariations![i][j]!) {
                            variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                          }
                        }
                      }
                    }
                  }
                  carts.add(OnlineCart(
                    cart.id, cart.item?.id, cart.isCampaign! ? cart.item!.id : null,
                    cart.discountedPrice.toString(), '',
                    Get.find<SplashController>().getModuleConfig(cart.item?.moduleType).newVariation! ? null : cart.variation,
                    Get.find<SplashController>().getModuleConfig(cart.item?.moduleType).newVariation! ? variations : null,
                    cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Item', itemType: !widget.fromCart ? "AppModelsItemCampaign" : null,
                  ));
                }
              }

                PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                  cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: checkoutController.distance,
                  orderAmount: widget.storeId == null ? subTotal : 0, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
                  paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                      : checkoutController.paymentMethodIndex == 1 ? 'wallet'
                      : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
                  couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                      && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                  storeId: (widget.storeId == null) ? _storeIdFromCart() : widget.storeId,
                  discountAmount: discount, receiverDetails: null, parcelCategoryId: null,
                  chargePayer: null, dmTips: (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now') ? '' : checkoutController.tipController.text.trim(),
                  cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                  unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                  deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
                  partialPayment: checkoutController.isPartialPay ? 1 : 0, guestId: isGuestLogIn ? int.parse(AuthHelper.getGuestId()) : 0,
                  isBuyNow: widget.fromCart ? 0 : 1,
                  extraPackagingAmount: Get.find<CartController>().needExtraPackage ? checkoutController.store!.extraPackagingAmount : 0,
                  createNewUser: checkoutController.isCreateAccount ? 1 : 0, password: null,
                  isPrescriptionOrder: widget.storeId == null ? false : true,
                  monthlySubscribe: checkoutController.monthlySubscribe,
                  saverDeliveryType: checkoutController.saverDeliveryType,
                );
                print('[DEBUG] PlaceOrderBody (parcel) monthlySubscribe: ${placeOrderBody.monthlySubscribe}');

              if((widget.storeId == null && _cartList != null && _cartList!.isNotEmpty && placeOrderBody.storeId != null) || (widget.storeId != null)) {
                print("=======store id: ${placeOrderBody.storeId}");
                checkoutController.getOrderTax(placeOrderBody);
              }
            });
          }

          AddressModel addressForDelivery = AddressHelper.getUserAddressFromSharedPref() ?? AddressModel();
          double additionalCharge = (Get.find<SplashController>().configModel?.additionalChargeStatus ?? false) ? (Get.find<SplashController>().configModel?.additionCharge ?? 0) : 0;
          double originalCharge = _calculateOriginalDeliveryCharge(
            store: checkoutController.store, address: addressForDelivery,
            distance: checkoutController.distance, extraCharge: checkoutController.extraCharge,
            surgePrice: checkoutController.surgePrice?.price, surgePriceType: checkoutController.surgePrice?.priceType,
          );
          double deliveryCharge = _calculateDeliveryCharge(
            store: checkoutController.store, address: addressForDelivery, distance: checkoutController.distance,
            extraCharge: checkoutController.extraCharge, orderType: checkoutController.orderType ?? 'delivery', orderAmount: orderAmount,
            surgePrice: checkoutController.surgePrice?.price, surgePriceType: checkoutController.surgePrice?.priceType,
          );

          if(checkoutController.orderType != 'take_away' && checkoutController.store != null) {
            _deliveryChargeForView = (checkoutController.orderType == 'delivery' ? checkoutController.store!.freeDelivery! : true) ? 'free'.tr
                : deliveryCharge != -1 ? PriceConverter.convertPrice(deliveryCharge) : 'calculating'.tr;
          }

          double extraPackagingCharge = widget.storeId != null ? 0 : _calculateExtraPackagingCharge(checkoutController);

          final double saverDeliveryAdjustment = (checkoutController.orderType == 'delivery' && checkoutController.isInstantDelivery
                  && checkoutController.store?.selfDeliverySystem != 1)
              ? checkoutController.getEffectiveSaverDeliveryAdjustment(deliveryCharge: deliveryCharge, deliveryOption: checkoutController.selectedSaverDeliveryOption)
              : 0;

          double total = _calculateTotal(
            subTotal: subTotal, deliveryCharge: deliveryCharge, discount: discount,
            couponDiscount: couponDiscount, taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0.0, orderType: checkoutController.orderType ?? 'delivery',
            tips: checkoutController.tips, additionalCharge: additionalCharge, extraPackagingCharge: extraPackagingCharge,
          );

          bool isPrescriptionRequired = _checkPrescriptionRequired();

          total = total - referralDiscount + saverDeliveryAdjustment;

          if(widget.storeId != null){
            Future.delayed(Duration.zero, () => checkoutController.setPaymentMethod(0, isUpdate: false));
          }
          checkoutController.setTotalAmount(total - (checkoutController.isPartialPay ? Get.find<ProfileController>().userInfoModel!.walletBalance! : 0));

          if(!_isCashBackSnackBarShown && checkoutController.distance != null && checkoutController.distance != -1.0 && isLoggedIn && checkoutController.viewTotalPrice! > 0) {
            _isCashBackSnackBarShown = true;
            Future.delayed(const Duration(milliseconds: 800), () {
              showCashBackSnackBar(checkoutController.viewTotalPrice!);
            });
          }


          _setSinglePaymentActive();

          return (checkoutController.distance != null && checkoutController.store != null) ? Column(
            children: [
              ResponsiveHelper.isDesktop(context) ? Container(
                height: 64,
                margin: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                    child: Text('checkout'.tr,
                        style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer))),
              ) : const SizedBox(),

              Expanded(child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: FooterView(child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: ResponsiveHelper.isDesktop(context) ? Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Expanded(flex: 6, child: TopSection(
                        checkoutController: checkoutController, charge: originalCharge, deliveryCharge: deliveryCharge,
                        addressList: addressList,
                        tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module: module, price: price,
                        discount: discount, addOns: addOns, address: address, cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false,
                        isDigitalPaymentActive: _isDigitalPaymentActive ?? false, isWalletActive: _isWalletActive, storeId: widget.storeId,
                        total: total, isOfflinePaymentActive: _isOfflinePaymentActive, isPrescriptionRequired: isPrescriptionRequired, guestNameTextEditingController: guestContactPersonNameController,
                        guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                        guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                        tooltipController1: tooltipController1, tooltipController2: tooltipController2, dmTipsTooltipController: tooltipController3,
                        guestPasswordController: guestPasswordController, guestConfirmPasswordController: guestConfirmPasswordController,
                        guestPasswordNode: guestPasswordNode, guestConfirmPasswordNode: guestConfirmPasswordNode, variationPrice: isPassedVariationPrice ? variations : 0,
                        deliveryChargeForView: _deliveryChargeForView, badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeLarge),

                      Expanded(flex: 4, child: BottomSection(
                        checkoutController: checkoutController, total: total, module: module ?? Module(), subTotal: subTotal,
                        discount: discount, couponController: couponController, taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0.0,
                        deliveryCharge: deliveryCharge,
                        todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount,
                        maxCodOrderAmount: maxCodOrderAmount, storeId: widget.storeId, taxPercent: _taxPercent, price: price, addOns: addOns,
                        isPrescriptionRequired: isPrescriptionRequired, checkoutButton: _orderPlaceButton(
                          checkoutController, todayClosed, tomorrowClosed, orderAmount,
                          deliveryCharge, checkoutController.orderTax ?? 0.0, discount, total, maxCodOrderAmount, isPrescriptionRequired,
                        ),
                        referralDiscount: referralDiscount, variationPrice: isPassedVariationPrice ? variations : 0,
                      )),
                    ]),
                  ) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    TopSection(
                      checkoutController: checkoutController, charge: originalCharge, deliveryCharge: deliveryCharge,
                      addressList: addressList,
                      tomorrowClosed: tomorrowClosed, todayClosed: todayClosed, module: module, price: price,
                      discount: discount, addOns: addOns, address: address, cartList: _cartList, isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false,
                      isDigitalPaymentActive: _isDigitalPaymentActive ?? false, isWalletActive: _isWalletActive, storeId: widget.storeId,
                      total: total, isOfflinePaymentActive: _isOfflinePaymentActive, isPrescriptionRequired: isPrescriptionRequired, guestNameTextEditingController: guestContactPersonNameController,
                      guestNumberTextEditingController: guestContactPersonNumberController, guestNumberNode: guestNumberNode,
                      guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
                      tooltipController1: tooltipController1, tooltipController2: tooltipController2, dmTipsTooltipController: tooltipController3,
                      guestPasswordController: guestPasswordController, guestConfirmPasswordController: guestConfirmPasswordController,
                      guestPasswordNode: guestPasswordNode, guestConfirmPasswordNode: guestConfirmPasswordNode, variationPrice: isPassedVariationPrice ? variations : 0,
                      deliveryChargeForView: _deliveryChargeForView, badWeatherCharge: badWeatherChargeForToolTip, extraChargeForToolTip: extraChargeForToolTip,
                    ),

                    BottomSection(
                      checkoutController: checkoutController, total: total, module: module ?? Module(), subTotal: subTotal,
                      discount: discount, couponController: couponController, taxIncluded: (checkoutController.taxIncluded == 1), tax: checkoutController.orderTax ?? 0.0,
                      deliveryCharge: deliveryCharge,
                      todayClosed: todayClosed, tomorrowClosed: tomorrowClosed, orderAmount: orderAmount,
                      maxCodOrderAmount: maxCodOrderAmount, storeId: widget.storeId, taxPercent: _taxPercent, price: price, addOns: addOns,
                      isPrescriptionRequired: isPrescriptionRequired, checkoutButton: _orderPlaceButton(
                        checkoutController, todayClosed, tomorrowClosed, orderAmount, deliveryCharge,
                      checkoutController.orderTax ?? 0.0, discount, total, maxCodOrderAmount, isPrescriptionRequired,
                      ),
                      referralDiscount: referralDiscount, variationPrice: isPassedVariationPrice ? variations : 0,
                    )
                  ]),
                )),
              )),

              ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HappyHourMilestoneBannerWidget(
                      subtotal: subTotal,
                      isHappyHourRunning: checkoutController.store?.isHappyHourRunning,
                      storeId: checkoutController.store?.id,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeLarge,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeLarge,
                        4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                checkoutController.isPartialPay ? 'due_payment'.tr : 'total_amount'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              PriceConverter.convertAnimationPrice(
                                checkoutController.viewTotalPrice,
                                textStyle: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge + 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    _orderPlaceButton(
                      checkoutController,
                      todayClosed,
                      tomorrowClosed,
                      orderAmount,
                      deliveryCharge,
                      checkoutController.orderTax ?? 0.0,
                      discount,
                      total,
                      maxCodOrderAmount,
                      isPrescriptionRequired,
                    ),
                  ],
                ),
              ),

            ],
          ) : const CheckoutScreenShimmerView();
          });
        });
      }) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }


  Widget _orderPlaceButton(CheckoutController checkoutController, bool todayClosed, bool tomorrowClosed,
      double orderAmount, double? deliveryCharge, double tax, double? discount, double total, double? maxCodOrderAmount, bool isPrescriptionRequired) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(
          bottom: Dimensions.paddingSizeLarge,
          left: Dimensions.paddingSizeLarge,
          right: Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButton(
          radius: 16,
          isLoading: checkoutController.isLoading || _isSubmitting,
          buttonText: 'place_order'.tr,
          onPressed: (checkoutController.acceptTerms && !checkoutController.isLoading && !_isSubmitting) ? () async {
          if (_isSubmitting || checkoutController.isLoading) return;
          bool isAvailable = true;
          DateTime scheduleStartDate = DateTime.now();
          DateTime scheduleEndDate = DateTime.now();
          bool isGuestLogIn = AuthHelper.isGuestLoggedIn();
          bool isDesktop = ResponsiveHelper.isDesktop(context);
          if(checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
            isAvailable = false;
          }else {
            DateTime date = checkoutController.selectedDateSlot == 0 ? DateTime.now() : DateTime.now().add(const Duration(days: 1));
            DateTime startTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot].startTime!;
            DateTime endTime = checkoutController.timeSlots![checkoutController.selectedTimeSlot].endTime!;
            scheduleStartDate = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute+1);
            scheduleEndDate = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute+1);
            if(_cartList != null){
              for (CartModel? cart in _cartList!) {
                if (cart == null || cart.isAtomicBundle || cart.item == null) {
                  continue;
                }
                if (!DateConverter.isAvailable(
                  cart.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                  time: (checkoutController.store?.scheduleOrder ?? false) ? scheduleStartDate : null,
                ) && !DateConverter.isAvailable(
                  cart.item!.availableTimeStarts, cart.item!.availableTimeEnds,
                  time: (checkoutController.store?.scheduleOrder ?? false) ? scheduleEndDate : null,
                )) {
                  isAvailable = false;
                  break;
                }
              }
            }
          }

          String guestContactName = guestContactPersonNameController.text.trim();
          if (guestContactName.isEmpty && checkoutController.guestAddress?.contactPersonName != null) {
            guestContactName = checkoutController.guestAddress!.contactPersonName!.trim();
          }

          String guestContactPhone = guestContactPersonNumberController.text.trim();
          if (guestContactPhone.isEmpty && checkoutController.guestAddress?.contactPersonNumber != null) {
            guestContactPhone = checkoutController.guestAddress!.contactPersonNumber!.trim();
          }

          String guestContactEmail = guestEmailController.text.trim();
          if (guestContactEmail.isEmpty && checkoutController.guestAddress?.email != null) {
            guestContactEmail = checkoutController.guestAddress!.email!.trim();
          }

          bool isGuestValidNumber = false;
          String guestNormalizedNumber = '';
          if(isGuestLogIn && guestContactPhone.isNotEmpty) {
            String numberWithCountryCode = guestContactPhone.startsWith('+')
                ? guestContactPhone
                : (checkoutController.countryDialCode ?? '') + guestContactPhone;
            PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
            isGuestValidNumber = phoneValid.isValid;
            guestNormalizedNumber = phoneValid.isValid ? phoneValid.phone : numberWithCountryCode;
          }
          bool isPhoneValid = false;
          if(AuthHelper.isLoggedIn()) {
            String numberWithCountryCode = checkoutController.countryDialCode! + checkoutController.contactPersonNumberController.text;
            PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
            isPhoneValid = phoneValid.isValid;
          }

          if(isGuestLogIn && guestContactName.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_name'.tr);
          } else if(isGuestLogIn && guestContactPhone.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_number'.tr);
          } else if(isGuestLogIn && !isGuestValidNumber) {
            showCustomSnackBar('please_enter_valid_phone_number'.tr);
          } else if(isGuestLogIn && checkoutController.contactPersonAddressController.text.isEmpty && checkoutController.orderType != 'take_away') {
            showCustomSnackBar('please_setup_your_delivery_address'.tr);
          }else if(isPrescriptionRequired && checkoutController.pickedPrescriptions.isEmpty) {
            showCustomSnackBar('you_must_upload_prescription_for_this_order'.tr);
          }else if(AuthHelper.isLoggedIn() && !isDesktop && checkoutController.contactPersonNameController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_name'.tr);
          }else if(AuthHelper.isLoggedIn() && !isDesktop && checkoutController.contactPersonNumberController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_number'.tr);
          }else if(AuthHelper.isLoggedIn() && !isDesktop && checkoutController.contactPersonNumberController.text.isNotEmpty && !isPhoneValid) {
            showCustomSnackBar('please_enter_valid_phone_number'.tr);
          }else if(AuthHelper.isLoggedIn() && !isDesktop && checkoutController.contactPersonAddressController.text.isEmpty) {
            showCustomSnackBar('please_enter_contact_person_address'.tr);
          } else if(!_isCashOnDeliveryActive! && !_isDigitalPaymentActive! && !_isWalletActive && !_isOfflinePaymentActive) {
            showCustomSnackBar('no_payment_method_is_enabled'.tr);
          }else if(checkoutController.paymentMethodIndex == -1) {
            showCustomSnackBar('payment_method_required_error'.tr);
          } else if(orderAmount < checkoutController.store!.minimumOrder! && widget.storeId == null) {
            showCustomSnackBar('${'minimum_order_amount_is'.tr} ${checkoutController.store!.minimumOrder}');
          }else if(checkoutController.tipController.text.isNotEmpty && checkoutController.tipController.text != 'not_now' && double.parse(checkoutController.tipController.text.trim()) < 0) {
            showCustomSnackBar('tips_can_not_be_negative'.tr);
          }else if((checkoutController.selectedDateSlot == 0 && todayClosed) || (checkoutController.selectedDateSlot == 1 && tomorrowClosed)) {
            showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
          }else if(checkoutController.paymentMethodIndex == 0 && _isCashOnDeliveryActive! && maxCodOrderAmount != null && maxCodOrderAmount != 0 && (total > maxCodOrderAmount) && widget.storeId == null){
            showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
          }else if(checkoutController.paymentMethodIndex != 0 && widget.storeId != null){
            showCustomSnackBar('payment_method_is_not_available'.tr);
          }else if (checkoutController.timeSlots == null || checkoutController.timeSlots!.isEmpty) {
            if(checkoutController.store!.scheduleOrder!) {
              showCustomSnackBar('select_a_time'.tr);
            }else {
              showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                  ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr);
            }
          }else if (!isAvailable) {
            showCustomSnackBar('one_or_more_products_are_not_available_for_this_selected_time'.tr);
          }else if (checkoutController.orderType != 'take_away' && checkoutController.distance == -1 && deliveryCharge == -1) {
            showCustomSnackBar('delivery_fee_not_set_yet'.tr);
          }else if (widget.storeId != null && checkoutController.pickedPrescriptions.isEmpty) {
            showCustomSnackBar('please_upload_your_prescription_images'.tr);
          }else if (!checkoutController.acceptTerms) {
            showCustomSnackBar('please_accept_privacy_policy_trams_conditions_refund_policy_first'.tr);
          }
          else {

            AddressModel? finalAddress = isGuestLogIn ? checkoutController.guestAddress : checkoutController.address;

            if(isGuestLogIn && checkoutController.orderType == 'take_away') {
              String number = guestNormalizedNumber.isNotEmpty ? guestNormalizedNumber : guestContactPhone;
              finalAddress = AddressModel(
                contactPersonName: guestContactName,
                contactPersonNumber: number,
                address: AddressHelper.getUserAddressFromSharedPref()!.address!,
                latitude: AddressHelper.getUserAddressFromSharedPref()!.latitude,
                longitude: AddressHelper.getUserAddressFromSharedPref()!.longitude,
                zoneId: AddressHelper.getUserAddressFromSharedPref()!.zoneId,
                email: guestContactEmail,
              );
            } else if(isGuestLogIn && checkoutController.orderType != 'take_away') {
              String number = guestNormalizedNumber.isNotEmpty ? guestNormalizedNumber : guestContactPhone;
              finalAddress = AddressModel(
                contactPersonName: guestContactName,
                contactPersonNumber: number,
                address: checkoutController.contactPersonAddressController.text.isNotEmpty
                    ? checkoutController.contactPersonAddressController.text
                    : (checkoutController.guestAddress?.address ?? ''),
                latitude: checkoutController.guestAddress?.latitude,
                longitude: checkoutController.guestAddress?.longitude,
                zoneId: checkoutController.guestAddress?.zoneId,
                email: guestContactEmail,
                streetNumber: checkoutController.guestAddress?.streetNumber,
                house: checkoutController.guestAddress?.house,
                floor: checkoutController.guestAddress?.floor,
                addressType: checkoutController.guestAddress?.addressType,
              );
            }

            print('=====> checkout controller Address: ${checkoutController.address?.toJson()}');
            print('=====> Final Address: ${finalAddress?.toJson()}');
            if(!isGuestLogIn && finalAddress!.contactPersonNumber == 'null'){
              finalAddress.contactPersonNumber = Get.find<ProfileController>().userInfoModel!.phone;
            }

            if(AuthHelper.isLoggedIn()) {
              finalAddress?.contactPersonName = checkoutController.contactPersonNameController.text;
              finalAddress?.contactPersonNumber = checkoutController.countryDialCode! + checkoutController.contactPersonNumberController.text;
              finalAddress?.streetNumber = checkoutController.streetNumberController.text;
              finalAddress?.house = checkoutController.houseController.text;
              finalAddress?.floor = checkoutController.floorController.text;
            }

            if(widget.storeId == null){

              List<OnlineCart> carts = [];
              for (int index = 0; index < _cartList!.length; index++) {
                CartModel cart = _cartList![index]!;
                if(cart.isAtomicBundle || cart.item == null) {
                  continue;
                }
                List<int?> addOnIdList = [];
                List<int?> addOnQtyList = [];
                for (var addOn in cart.addOnIds ?? <AddOn>[]) {
                  addOnIdList.add(addOn.id);
                  addOnQtyList.add(addOn.quantity);
                }

                List<OrderVariation> variations = [];
                if(Get.find<SplashController>().getModuleConfig(cart.item?.moduleType).newVariation!) {
                  for(int i=0; i<(cart.item?.foodVariations?.length ?? 0); i++) {
                    if(cart.foodVariations![i].contains(true)) {
                      variations.add(OrderVariation(name: cart.item!.foodVariations![i].name, values: OrderVariationValue(label: [])));
                      for(int j=0; j<(cart.item?.foodVariations![i].variationValues?.length ?? 0); j++) {
                        if(cart.foodVariations![i][j]!) {
                          variations[variations.length-1].values!.label!.add(cart.item!.foodVariations![i].variationValues![j].level);
                        }
                      }
                    }
                  }
                }
                carts.add(OnlineCart(
                  cart.id, cart.item?.id, cart.isCampaign! ? cart.item?.id : null,
                  cart.discountedPrice.toString(), '',
                  Get.find<SplashController>().getModuleConfig(cart.item?.moduleType).newVariation! ? null : cart.variation,
                  Get.find<SplashController>().getModuleConfig(cart.item?.moduleType).newVariation! ? variations : null,
                  cart.quantity, addOnIdList, cart.addOns, addOnQtyList, 'Item', itemType: !widget.fromCart ? "AppModelsItemCampaign" : null,
                ));
              }

              PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                cart: carts, couponDiscountAmount: Get.find<CouponController>().discount, distance: checkoutController.distance,
                scheduleAt: !(checkoutController.store?.scheduleOrder ?? false) ? null : (checkoutController.selectedDateSlot == 0
                    && checkoutController.selectedTimeSlot == 0) ? null : DateConverter.dateToDateAndTime(scheduleEndDate),
                orderAmount: total, orderNote: checkoutController.noteController.text, orderType: checkoutController.orderType,
                paymentMethod: checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'
                    : checkoutController.paymentMethodIndex == 1 ? 'wallet'
                    : checkoutController.paymentMethodIndex == 2 ? 'digital_payment' : 'offline_payment',
                couponCode: (Get.find<CouponController>().discount! > 0 || (Get.find<CouponController>().coupon != null
                    && Get.find<CouponController>().freeDelivery)) ? Get.find<CouponController>().coupon!.code : null,
                storeId: _storeIdFromCart(),
                address: finalAddress!.address, latitude: finalAddress.latitude, longitude: finalAddress.longitude,
                senderZoneId: null, addressType: finalAddress.addressType,
                contactPersonName: finalAddress.contactPersonName ?? '${Get.find<ProfileController>().userInfoModel!.fName} '
                    '${Get.find<ProfileController>().userInfoModel!.lName}',
                contactPersonNumber: finalAddress.contactPersonNumber ?? Get.find<ProfileController>().userInfoModel!.phone,
                streetNumber: isGuestLogIn ? finalAddress.streetNumber??'' : checkoutController.streetNumberController.text.trim(),
                house: isGuestLogIn ? finalAddress.house ?? '' : checkoutController.houseController.text.trim(),
                floor: isGuestLogIn ? finalAddress.floor ?? '' : checkoutController.floorController.text.trim(),
                discountAmount: discount, taxAmount: tax, receiverDetails: null, parcelCategoryId: null,
                chargePayer: null, dmTips: (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now') ? '' : checkoutController.tipController.text.trim(),
                cutlery: Get.find<CartController>().addCutlery ? 1 : 0,
                unavailableItemNote: Get.find<CartController>().notAvailableIndex != -1 ? Get.find<CartController>().notAvailableList[Get.find<CartController>().notAvailableIndex] : '',
                deliveryInstruction: checkoutController.selectedInstruction != -1 ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
                partialPayment: checkoutController.isPartialPay ? 1 : 0,
                isGuest: isGuestLogIn ? 1 : 0,
                guestId: isGuestLogIn ? int.parse(AuthHelper.getGuestId()) : 0,
                isBuyNow: widget.fromCart ? 0 : 1,
                guestEmail: isGuestLogIn
                    ? (finalAddress.email != null && finalAddress.email!.isNotEmpty
                        ? finalAddress.email
                        : null)
                    : null,
                extraPackagingAmount: Get.find<CartController>().needExtraPackage ? checkoutController.store!.extraPackagingAmount : 0,
                createNewUser: checkoutController.isCreateAccount ? 1 : 0, password: null,
                bringChangeAmount: checkoutController.paymentMethodIndex == 0 && checkoutController.exchangeAmount > 0 ? checkoutController.exchangeAmount : null,
                monthlySubscribe: checkoutController.monthlySubscribe,
                saverDeliveryType: checkoutController.saverDeliveryType,
              );
              print('[DEBUG] PlaceOrderBody (regular) monthlySubscribe: ${placeOrderBody.monthlySubscribe}');

              setState(() => _isSubmitting = true);
              try {
                await checkoutController.placeOrder(
                  placeOrderBody, checkoutController.store?.zoneId, total, maxCodOrderAmount, widget.fromCart,
                  _isCashOnDeliveryActive ?? false, checkoutController.pickedPrescriptions, isOfflinePay: checkoutController.paymentMethodIndex == 3,
                );
              } catch (e) {
                debugPrint('placeOrder exception: $e');
              } finally {
                if (mounted) {
                  setState(() => _isSubmitting = false);
                }
              }
            }else{
              setState(() => _isSubmitting = true);
              try {
                await checkoutController.placePrescriptionOrder(storeId: widget.storeId,
                  zoneID: checkoutController.store?.zoneId, distance: checkoutController.distance,
                  address: finalAddress?.address ?? '', longitude: finalAddress?.longitude ?? '',
                  latitude: finalAddress?.latitude ?? '', note: checkoutController.noteController.text,
                  orderAttachment: checkoutController.pickedPrescriptions,
                  savedImages: checkoutController.pickedPrescriptionSavedImageNames.whereType<String>().toList(),
                  dmTips: (checkoutController.orderType == 'take_away' || checkoutController.tipController.text == 'not_now')
                      ? '' : checkoutController.tipController.text.trim(),
                  deliveryInstruction: checkoutController.selectedInstruction != -1
                      ? AppConstants.deliveryInstructionList[checkoutController.selectedInstruction] : '',
                  orderAmount: 0, maxCodAmount: 0, fromCart: widget.fromCart, isCashOnDeliveryActive: _isCashOnDeliveryActive ?? false,
                );
              } catch (e) {
                debugPrint('placePrescriptionOrder exception: $e');
              } finally {
                if (mounted) {
                  setState(() => _isSubmitting = false);
                }
              }
            }
          }
        } : null),
      ),
    );
  }

  List<DropdownItem<int>> _getDropdownAddressList({required BuildContext context, required List<AddressModel>? addressList, required Store? store}) {
    List<DropdownItem<int>> dropDownAddressList = [];

    dropDownAddressList.add(DropdownItem<int>(value: 0, child: SizedBox(
      width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth - 50 : context.width - 50,
      child: AddressWidget(
        address: AddressHelper.getUserAddressFromSharedPref(),
        fromAddress: false, fromCheckout: true,
      ),
    )));

    if(addressList != null && store != null) {
      for(int index=0; index<addressList.length; index++) {
        if(addressList[index].zoneIds!.contains(store.zoneId)) {

          dropDownAddressList.add(DropdownItem<int>(value: index + 1, child: SizedBox(
            width: context.width > Dimensions.webMaxWidth ? Dimensions.webMaxWidth-50 : context.width-50,
            child: AddressWidget(
              address: addressList[index],
              fromAddress: false, fromCheckout: true,
            ),
          )));
        }
      }
    }
    return dropDownAddressList;
  }

  List<AddressModel> _getAddressList({required List<AddressModel>? addressList, required Store? store}) {
    List<AddressModel> address = [];

    if(AddressHelper.getUserAddressFromSharedPref() != null) {
      address.add(AddressHelper.getUserAddressFromSharedPref()!);
    }

    if(addressList != null && store != null) {
      for(int index=0; index<addressList.length; index++) {
        if(addressList[index].zoneIds!.contains(store.zoneId)) {
          address.add(addressList[index]);
        }
      }
    }
    return address;
  }

  Pivot? _getModuleData({required Store? store}) {
    Pivot? moduleData;
    if(store != null) {
      for(ZoneData zData in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
        for(Modules m in zData.modules!) {
          if(m.id == Get.find<SplashController>().module?.id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }
      }
    }
    return moduleData;
  }

  bool _checkCODActive({required Store? store}) {
    bool isCashOnDeliveryActive = false;
    final AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if(store != null && address?.zoneData != null){
      for(ZoneData zData in address!.zoneData!) {
        if(zData.id ==  store.zoneId) {
          isCashOnDeliveryActive = (zData.cashOnDelivery ?? false) && (Get.find<SplashController>().configModel?.cashOnDelivery ?? false);
        }
      }
    }
    return isCashOnDeliveryActive;
  }

  bool _checkDigitalPaymentActive({required Store? store}) {
    bool isDigitalPaymentActive = false;
    final AddressModel? address = AddressHelper.getUserAddressFromSharedPref();
    if(store != null && address?.zoneData != null){
      for(ZoneData zData in address!.zoneData!) {
        if(zData.id ==  store.zoneId) {
          isDigitalPaymentActive = (zData.digitalPayment ?? false) && (Get.find<SplashController>().configModel?.digitalPayment ?? false);
        }
      }
    }
    return isDigitalPaymentActive;
  }

  /// The first cart row that actually carries an item — a BOGO bundle row has none,
  /// so it can never stand in for the cart's store or module.
  CartModel? _firstItemCart(List<CartModel?>? cartList) {
    for(final CartModel? cart in cartList ?? const <CartModel?>[]) {
      if(cart != null && !cart.isBogoBundle && cart.item != null) {
        return cart;
      }
    }
    return null;
  }

  int? _storeIdFromCart() {
    final CartModel? cart = _firstItemCart(_cartList);
    if(cart != null) {
      return cart.item!.storeId;
    }
    for(final CartModel? bundle in _cartList ?? const <CartModel?>[]) {
      if(bundle != null && bundle.isAtomicBundle && bundle.storeId != null) {
        return bundle.storeId;
      }
    }
    return null;
  }

  /// The earliest moment any bundle in the cart stops being valid.
  static DateTime? bundleOfferEndsAt(List<CartModel?>? cartList) {
    DateTime? endsAt;
    for(final CartModel? cart in cartList ?? const <CartModel?>[]) {
      final String? offerEnd = cart?.bogoDetails?.offerEndDate;
      if(offerEnd == null || offerEnd.isEmpty) {
        continue;
      }
      final DateTime? parsed = DateTime.tryParse(offerEnd);
      if(parsed == null) {
        continue;
      }
      if(endsAt == null || parsed.isBefore(endsAt)) {
        endsAt = parsed;
      }
    }
    return endsAt;
  }

  double _calculatePrice({required Store? store, required List<CartModel?>? cartList}) {
    double price = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        if(cartModel == null) continue;
        if(cartModel.isBogoBundle) {
          price = price + (cartModel.bogoDetails?.totalPrice ?? 0);
          continue;
        }
        if(cartModel.isBundle) {
          price = price + (cartModel.bundleDetails?.totalFinalPrice ?? 0);
          continue;
        }
        if(cartModel.item == null) continue;
        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!){
          price = price + (cartModel.item!.price! * (cartModel.quantity ?? 1));
        } else {
          price = _calculateVariationPrice(store: store, cartList: cartList);
        }
      }
    }
    return PriceConverter.toFixed(price);
  }

  double _calculateAddonsPrice({required Store? store, required List<CartModel?>? cartList}) {
    double addOns = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        if(cartModel == null || cartModel.isAtomicBundle || cartModel.item == null) {
          continue;
        }
        List<AddOns> addOnList = [];
        for (var addOnId in cartModel.addOnIds ?? <AddOn>[]) {
          for (AddOns addOns in cartModel.item?.addOns ?? <AddOns>[]) {
            if (addOns.id == addOnId.id) {
              addOnList.add(addOns);
              break;
            }
          }
        }
        for (int index = 0; index < addOnList.length; index++) {
          addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
        }
      }
    }
    return PriceConverter.toFixed(addOns);
  }

  double _calculateVariationPrice({required Store? store, required List<CartModel?>? cartList, bool calculateDiscount = false, bool calculateWithoutDiscount = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        if(cartModel == null || cartModel.isAtomicBundle || cartModel.item == null) {
          continue;
        }
        double? discount = cartModel.item!.discount;
        String? discountType = cartModel.item!.discountType;

        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!) {
          isPassedVariationPrice = true;
          for(int index = 0; index< cartModel.item!.foodVariations!.length; index++) {
            for(int i=0; i<cartModel.item!.foodVariations![index].variationValues!.length; i++) {
              if(cartModel.foodVariations![index][i]!) {
                variationPrice += (PriceConverter.convertWithDiscount(cartModel.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType, isFoodVariation: true)! * cartModel.quantity!);
                variationDiscount += (cartModel.item!.foodVariations![index].variationValues![i].optionPrice! * cartModel.quantity!);
              }
            }
          }
        } else {

          String variationType = '';
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }

          if(cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
          } else {
            variationDiscount += (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!);
            variationPrice += (cartModel.item!.price! * cartModel.quantity!);
          }

        }
      }
    }
    if(calculateDiscount) {
      return (variationDiscount - variationPrice);
    } else if(calculateWithoutDiscount) {
      return variationDiscount;
    } else {
      return variationPrice;
    }
  }

  double _calculateDiscountPrice({required Store? store, required List<CartModel?>? cartList, required double price, required double addOns, required bool calStoreDiscount}) {
    double discount = 0;
    if (store != null && cartList != null && cartList.isNotEmpty) {
      for (var cartModel in cartList) {
        if(cartModel == null) continue;
        if(cartModel.isAtomicBundle) {
          if(cartModel.isBogoBundle){
            if(cartModel.bogoDetails?.isHappyHour == true) {
              discount = discount + cartModel.bogoDetails!.totalDiscountAmount;
            }
          }
          continue;
        }
        if(cartModel.item == null) continue;

        double? dis = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && calStoreDiscount ? store.discount!.discount : cartModel.item!.discount;

        String? disType = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && calStoreDiscount ? 'percent' : cartModel.item!.discountType;

        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!) {
          double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
          discount = discount + d;
          if(disType == 'percent' && discount != 0) {
            discount = discount + _calculateFoodVariationDiscount(cartModel: cartModel);
          }
        } else {
          String variationType = '';
          double variationPrice = 0;
          double variationWithoutDiscountPrice = 0;
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }
          if(cartModel.item!.variations!.isNotEmpty){
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (PriceConverter.convertWithDiscount(variation.price!, dis, disType)! * cartModel.quantity!);
                variationWithoutDiscountPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
            discount = discount + (variationWithoutDiscountPrice - variationPrice);

          } else {
            double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
            discount = discount + d;
          }
        }

      }
    }

    if(calStoreDiscount){
      if (store != null && store.discount != null) {
        final double? maxDiscount = store.discount!.maxDiscount;
        final double? minPurchase = store.discount!.minPurchase;
        if (maxDiscount != null && maxDiscount != 0 && maxDiscount < discount) {
          discount = maxDiscount;
        }
        if (minPurchase != null && minPurchase != 0 && minPurchase > (price + addOns)) {
          discount = 0;
        }
      }
    }
    return PriceConverter.toFixed(discount);
  }

  double _getDiscountPrice(double storeDiscountPrice, double itemDiscountPrice) {
    double discountPrice = 0;
    if(storeDiscountPrice > itemDiscountPrice) {
      discountPrice = storeDiscountPrice;
    } else if(itemDiscountPrice > storeDiscountPrice) {
      discountPrice = itemDiscountPrice;
    } else {
      discountPrice = itemDiscountPrice;
    }
    return discountPrice;
  }

  double _calculateFoodVariationDiscount({required CartModel? cartModel}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(cartModel != null && !cartModel.isAtomicBundle && cartModel.item != null) {
      double? discount = cartModel.item!.discount;
      String? discountType = cartModel.item!.discountType;
      for (int index = 0; index < cartModel.item!.foodVariations!.length; index++) {
        for (int i = 0; i < cartModel.item!.foodVariations![index].variationValues!.length; i++) {
          if (cartModel.foodVariations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(
                cartModel.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType,
                isFoodVariation: true)! * cartModel.quantity!);
            variationDiscount += (cartModel.item!.foodVariations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    }
    return (variationDiscount - variationPrice);
  }

  double _calculateOrderAmount({required double price, required double variations, required double discount, required double addOns, required double couponDiscount, required List<CartModel?>? cartList, required double referralDiscount}) {
    double orderAmount = 0;
    double variationPrice = 0;
    final CartModel? sample = _firstItemCart(cartList);
    final String? sampleModuleType = sample?.item?.moduleType ?? Get.find<CartController>().cartModuleType;
    if(sampleModuleType != null && Get.find<SplashController>().getModuleConfig(sampleModuleType).newVariation!){
      variationPrice = variations;
    }
    orderAmount = (price + variationPrice - discount) + addOns - couponDiscount - referralDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  double _calculateSubTotal({required double price, required double addOns, required double variations, required List<CartModel?>? cartList}) {
    double subTotal = 0;
    bool isFoodVariation = false;

    if(cartList != null && cartList.isNotEmpty) {
      final CartModel? sample = _firstItemCart(cartList);
      final String? sampleModuleType = sample?.item?.moduleType ?? Get.find<CartController>().cartModuleType;
      isFoodVariation = sampleModuleType == null ? false
          : Get.find<SplashController>().getModuleConfig(sampleModuleType).newVariation!;
    }
    if(isFoodVariation){
      subTotal = price + addOns + variations;
    } else {
      subTotal = price;
    }

    return subTotal;
  }

  double _calculateOriginalDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge, double? surgePrice, String? surgePriceType}) {
    double deliveryCharge = -1;

    Pivot? moduleData;
    if(store != null) {
      for(ZoneData zData in address.zoneData!) {
        for(Modules m in zData.modules!) {
          if(m.id == Get.find<SplashController>().module!.id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }
      }
    }

    double perKmCharge = 0;
    double minimumCharge = 0;
    double? maximumCharge = 0;
    if(store != null && distance != null && distance != -1 && store.selfDeliverySystem == 1) {
      perKmCharge = store.perKmShippingCharge ?? 0;
      minimumCharge = store.minimumShippingCharge ?? 0;
      maximumCharge = store.maximumShippingCharge;
    }else if(store != null && distance != null && distance != -1 && moduleData != null && moduleData.deliveryChargeType == 'distance') {
      perKmCharge = moduleData.perKmShippingCharge ?? 0;
      minimumCharge = moduleData.minimumShippingCharge ?? 0;
      maximumCharge = moduleData.maximumShippingCharge;
    } else if(store != null && moduleData != null && moduleData.deliveryChargeType == 'fixed') {
      perKmCharge = moduleData.fixedShippingCharge ?? 0;
      minimumCharge = moduleData.fixedShippingCharge ?? 0;
      maximumCharge = moduleData.fixedShippingCharge ?? 0;
      print('Fixed shipping charge perKmCharge, minimumCharge, maximumCharge :: $perKmCharge, $minimumCharge, $maximumCharge');
    }

    if(store != null && distance != null) {
      print('=======distance: $distance, perKmCharge: $perKmCharge');
      deliveryCharge = distance * perKmCharge;
      print('distance * perKmCharge = $deliveryCharge');

      if(deliveryCharge < minimumCharge) {
        print('minimumCharge $minimumCharge');
        deliveryCharge = minimumCharge;
        print('minimumCharge 2 $deliveryCharge');
      }else if(maximumCharge != null && deliveryCharge > maximumCharge) {
        print('maximumCharge $deliveryCharge');
        deliveryCharge = maximumCharge;
        print('maximumCharge 2 $maximumCharge');
      }
    }

    if(store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
      extraChargeForToolTip = extraCharge;
      deliveryCharge = deliveryCharge + extraCharge;
      print('extraCharge $deliveryCharge');
    }

    if(store != null && store.selfDeliverySystem == 0 && surgePrice != null && surgePrice > 0) {
      if(surgePriceType == 'percent') {
        badWeatherChargeForToolTip = (deliveryCharge * (surgePrice/100));
        print('badWeatherChargeForToolTip $badWeatherChargeForToolTip');
        deliveryCharge = deliveryCharge + (deliveryCharge * (surgePrice/100));
        print('(deliveryCharge * (surgePrice/100)) $deliveryCharge');
      } else {
        badWeatherChargeForToolTip = surgePrice;
        print('badWeatherChargeForToolTip $badWeatherChargeForToolTip 2');
        deliveryCharge = deliveryCharge + surgePrice;
        print('deliveryCharge + surgePrice $deliveryCharge');
      }
    }

    print('==== finaldeliveryCharge $deliveryCharge');
    return deliveryCharge;
  }

  double _calculateDeliveryCharge({
    required Store? store, required AddressModel address, required double? distance,
    required double? extraCharge, required double orderAmount,
    required String orderType, double? surgePrice, String? surgePriceType
  }) {
    double deliveryCharge = _calculateOriginalDeliveryCharge(store: store, address: address,
        distance: distance, extraCharge: extraCharge, surgePrice: surgePrice, surgePriceType: surgePriceType);

    ConfigModel? configModel = Get.find<SplashController>().configModel;

    if (orderType == 'take_away' || (store != null && store.freeDelivery!)
        || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null && configModel?.adminFreeDelivery?.type == 'free_delivery_to_all_store'))
        || (configModel?.adminFreeDelivery?.status == true && (configModel?.adminFreeDelivery?.type != null &&  configModel?.adminFreeDelivery?.type == 'free_delivery_by_order_amount') && (configModel!.adminFreeDelivery?.freeDeliveryOver != null && orderAmount >= configModel.adminFreeDelivery!.freeDeliveryOver!))
        || Get.find<CouponController>().freeDelivery || (AuthHelper.isGuestLoggedIn() && (Get.find<CheckoutController>().guestAddress == null && Get.find<CheckoutController>().orderType != 'take_away'))) {
      deliveryCharge = 0;
    }

    return PriceConverter.toFixed(deliveryCharge);
  }

  double _calculateTotal({
    required double subTotal, required double deliveryCharge, required double discount,
    required double couponDiscount, required bool taxIncluded, required double tax,
    required String orderType, required double tips, required double additionalCharge, required double extraPackagingCharge,
  }) {

    return PriceConverter.toFixed(
        subTotal + deliveryCharge - discount- couponDiscount + (taxIncluded ? 0 : tax)
            + ((orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? tips : 0)
            + additionalCharge + extraPackagingCharge
    );
  }

  bool _checkZoneOfflinePaymentOnOff({required AddressModel? addressModel, required CheckoutController checkoutController}) {
    bool? status = false;
    ZoneData? zoneData;
    if(addressModel?.zoneData != null) {
      for (var data in addressModel!.zoneData!) {
        if(data.id == checkoutController.store?.zoneId) {
          zoneData = data;
          break;
        }
      }
    }
    status = zoneData?.offlinePayment ?? false;
    return status;
  }

  bool _checkPrescriptionRequired() {
    if(widget.storeId == null && (Get.find<SplashController>().configModel?.moduleConfig?.module?.orderAttachment ?? false)) {
      for (var cart in _cartList ?? const <CartModel?>[]) {
        if(cart == null || cart.isAtomicBundle || cart.item == null) {
          continue;
        }
        if(cart.item!.isPrescriptionRequired ?? false) {
          return true;
        }
      }
    }
    return false;
  }

  double _calculateExtraPackagingCharge(CheckoutController checkoutController) {
    if((checkoutController.store?.extraPackagingStatus ?? true) && (Get.find<CartController>().needExtraPackage)) {
      return checkoutController.store?.extraPackagingAmount ?? 0;
    }
    return 0;
  }

  double _calculateReferralDiscount(double subTotal, double discount, double couponDiscount) {
    double referralDiscount = 0;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      if (Get.find<ProfileController>().userInfoModel!.discountAmountType! == "percentage") {
        referralDiscount = (Get.find<ProfileController>().userInfoModel!.discountAmount! / 100) * (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = Get.find<ProfileController>().userInfoModel!.discountAmount!;
      }
    }
    return PriceConverter.toFixed(referralDiscount);
  }

  Future<void> showCashBackSnackBar(double amount) async {
    try {
      await Get.find<HomeController>().getCashBackData(amount);
      double? cashBackAmount = Get.find<HomeController>().cashBackData?.cashbackAmount ?? 0;
      String? cashBackType = Get.find<HomeController>().cashBackData?.cashbackType ?? '';
      String text = '${'you_will_get'.tr} ${cashBackType == 'amount' ? PriceConverter.convertPrice(cashBackAmount) : '${cashBackAmount.toStringAsFixed(0)}%'} ${'cash_back_after_completing_order'.tr}';
      if(cashBackAmount > 0) {
        showCustomSnackBar(text, isError: false);
      }
    } catch (_) {}
  }

}