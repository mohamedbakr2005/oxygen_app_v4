import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/api/response_parser.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/checkout_summary_body_model.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/coverage_list_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_cancellation_reasons_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_tier_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/place_details_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/video_content_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/why_choose_model.dart';
import 'package:Oxygen_Mart/features/parcel/domain/services/parcel_service_interface.dart';
import 'package:Oxygen_Mart/features/payment/domain/models/offline_method_model.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/pro/domain/models/pro_active_offer_model.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

import '../domain/models/parcel_instruction_model.dart';

class ParcelController extends GetxController implements GetxService {
  final ParcelServiceInterface parcelServiceInterface;
  ParcelController({required this.parcelServiceInterface});

  List<AddressModel> _parcelRecentAddresses = [];
  List<AddressModel> get parcelRecentAddresses => _parcelRecentAddresses;

  List<ParcelCategoryModel>? _parcelCategoryList;
  List<ParcelCategoryModel>? get parcelCategoryList => _parcelCategoryList;

  AddressModel? _pickupAddress;
  AddressModel? get pickupAddress => _pickupAddress;

  AddressModel? _destinationAddress;
  AddressModel? get destinationAddress => _destinationAddress;

  bool? _isPickedUp = true;
  bool? get isPickedUp => _isPickedUp;

  bool _isSender = true;
  bool get isSender => _isSender;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double? _distance = -1;
  double? get distance => _distance;

  final List<String> _payerTypes = ['sender', 'receiver'];
  List<String> get payerTypes => _payerTypes;

  int _payerIndex = 0;
  int get payerIndex => _payerIndex;

  int _paymentIndex = -1;
  int get paymentIndex => _paymentIndex;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  double? _extraCharge;
  double? get extraCharge => _extraCharge;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  WhyChooseModel? _whyChooseDetails;
  WhyChooseModel? get whyChooseDetails => _whyChooseDetails;

  VideoContentModel? _videoContentDetails;
  VideoContentModel? get videoContentDetails => _videoContentDetails;

  int _selectedOfflineBankIndex = 0;
  int get selectedOfflineBankIndex => _selectedOfflineBankIndex;

  List<Reason>? _parcelCancellationReasons;
  List<Reason>? get parcelCancellationReasons => _parcelCancellationReasons;

  ParcelTierListModel<ParcelWeightModel>? _weightTier;
  ParcelTierListModel<ParcelWeightModel>? get weightTier => _weightTier;

  ParcelTierListModel<ParcelDimensionModel>? _dimensionTier;
  ParcelTierListModel<ParcelDimensionModel>? get dimensionTier => _dimensionTier;

  int? _selectedWeightId;
  int? get selectedWeightId => _selectedWeightId;

  int? _selectedDimensionId;
  int? get selectedDimensionId => _selectedDimensionId;

  bool get needsWeightSelection => _weightTier?.requiresSelection ?? false;
  bool get needsDimensionSelection => _dimensionTier?.requiresSelection ?? false;

  bool get isTierSelectionMissing =>
      (needsWeightSelection && _selectedWeightId == null)
      || (needsDimensionSelection && _selectedDimensionId == null);

  ParcelWeightModel? get selectedWeight => _findById(_weightTier?.data, _selectedWeightId, (ParcelWeightModel w) => w.id);
  ParcelDimensionModel? get selectedDimension => _findById(_dimensionTier?.data, _selectedDimensionId, (ParcelDimensionModel d) => d.id);

  CoverageListModel? _coverage;
  CoverageListModel? get coverage => _coverage;

  int? _selectedAreaId;
  int? get selectedAreaId => _selectedAreaId;

  int? _selectedZipCodeId;
  int? get selectedZipCodeId => _selectedZipCodeId;

  bool get needsCoverageSelection => _coverage?.requiresSelection ?? false;

  List<Data>? _parcelInstructionList;
  List<Data>? get parcelInstructionList => _parcelInstructionList;

  int _instructionselectedIndex = -1;
  int get instructionselectedIndex => _instructionselectedIndex;

  final TextEditingController _customNoteController = TextEditingController();
  TextEditingController get customNoteController => _customNoteController;

  String _customNote = '';
  String? get customNote => _customNote;

  int _selectedIndexNote = -1;
  int? get selectedIndexNote => _selectedIndexNote;

  int? _senderAddressIndex = 0;
  int? get senderAddressIndex => _senderAddressIndex;

  int? _receiverAddressIndex = 0;
  int? get receiverAddressIndex => _receiverAddressIndex;

  String? _senderCountryCode;
  String? get senderCountryCode => _senderCountryCode;

  String? _receiverCountryCode;
  String? get receiverCountryCode => _receiverCountryCode;

  List<OfflineMethodModel>? _offlineMethodList;
  List<OfflineMethodModel>? get offlineMethodList => _offlineMethodList;

  int? _mostDmTipAmount;
  int? get mostDmTipAmount => _mostDmTipAmount;

  double _tips = 0.0;
  double get tips => _tips;

  int _selectedTips = 0;
  int get selectedTips => _selectedTips;

  bool _canShowTipsField = false;
  bool get canShowTipsField => _canShowTipsField;

  bool _isDmTipSave = false;
  bool get isDmTipSave => _isDmTipSave;

  void showTipsField() {
    _canShowTipsField = !_canShowTipsField;
    update();
  }

  Future<void> addTips(double tips) async {
    _tips = tips;
    update();
  }

  void toggleDmTipSave() {
    _isDmTipSave = !_isDmTipSave;
    update();
  }

  void setCountryCode(String code, bool isSender) {
    if (isSender) {
      _senderCountryCode = code;
    } else {
      _receiverCountryCode = code;
    }
  }

  void setSenderAddressIndex(int? index, {bool canUpdate = true}) {
    _senderAddressIndex = index;
    if (canUpdate) {
      update();
    }
  }

  void setReceiverAddressIndex(int? index, {bool canUpdate = true}) {
    _receiverAddressIndex = index;
    if (canUpdate) {
      update();
    }
  }

  void selectOfflineBank(int index) {
    _selectedOfflineBankIndex = index;
    update();
  }

  void changeDigitalPaymentName(String name) {
    _digitalPaymentName = name;
    update();
  }

  Future<void> getParcelCancellationReasons({required bool isBeforePickup}) async {
    final ParcelCancellationReasonsModel? result = await parcelServiceInterface.getParcelCancellationReasons(isBeforePickup: isBeforePickup);
    if (result != null) {
      _parcelCancellationReasons = result.data;
      update();
    }
  }

  void selectWeight(int? id) {
    _selectedWeightId = id;
    update();
  }

  void selectDimension(int? id) {
    _selectedDimensionId = id;
    update();
  }

  void clearTierSelections({bool notify = true}) {
    _selectedWeightId = null;
    _selectedDimensionId = null;
    if (notify) update();
  }

  void selectArea(int? id) {
    _selectedAreaId = id;
    update();
  }

  void selectZipCode(int? id) {
    _selectedZipCodeId = id;
    update();
  }

  Future<void> loadParcelTiers({required int zoneId, int? moduleId}) async {
    final int? previousWeightId = _selectedWeightId;
    final int? previousDimensionId = _selectedDimensionId;

    final List<dynamic> tiers = await Future.wait(<Future<dynamic>>[
      parcelServiceInterface.getParcelWeightList(zoneId: zoneId, moduleId: moduleId),
      parcelServiceInterface.getParcelDimensionList(zoneId: zoneId, moduleId: moduleId),
    ]);
    final ParcelTierListModel<ParcelWeightModel>? weight = tiers[0] as ParcelTierListModel<ParcelWeightModel>?;
    final ParcelTierListModel<ParcelDimensionModel>? dimension = tiers[1] as ParcelTierListModel<ParcelDimensionModel>?;

    if (weight != null) _weightTier = weight;
    if (dimension != null) _dimensionTier = dimension;

    _selectedWeightId = _survivingPick(_weightTier, previousWeightId, (ParcelWeightModel w) => w.id);
    _selectedDimensionId = _survivingPick(_dimensionTier, previousDimensionId, (ParcelDimensionModel d) => d.id);

    update();
  }

  static int? _survivingPick<T>(ParcelTierListModel<T>? tier, int? id, int? Function(T) idOf) {
    if (id == null) return null;
    if (tier == null || !tier.requiresSelection) return id;
    return tier.data.any((T row) => idOf(row) == id) ? id : null;
  }

  static T? _findById<T>(List<T>? list, int? id, int? Function(T) idOf) {
    if (list == null || id == null) return null;
    for (final T element in list) {
      if (idOf(element) == id) return element;
    }
    return null;
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  Future<void> getParcelCategoryList() async {
    List<ParcelCategoryModel>? categoryModelList =
        await parcelServiceInterface.getParcelCategory();
    if (categoryModelList != null) {
      _parcelCategoryList = [];
      _parcelCategoryList!.addAll(categoryModelList);
    }
    update();
  }

  void setPickupAddress(AddressModel? addressModel, bool notify) {
    _pickupAddress = addressModel;
    if (notify) {
      update();
    }
  }

  void loadParcelRecentAddresses() {
    try {
      final SharedPreferences prefs = Get.find<SharedPreferences>();
      final String? raw = prefs.getString(AppConstants.parcelRecentAddresses);
      if (raw == null || raw.isEmpty) {
        _parcelRecentAddresses = [];
        return;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _parcelRecentAddresses = decoded
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Parcel recent addresses load error: $e');
      }
      _parcelRecentAddresses = [];
    }
  }

  Future<void> addParcelRecentAddress(AddressModel address) async {
    if (address.latitude == null || address.longitude == null) {
      return;
    }
    if (_parcelRecentAddresses.isEmpty) {
      loadParcelRecentAddresses();
    }
    _parcelRecentAddresses.removeWhere((a) =>
        a.latitude == address.latitude
        && a.longitude == address.longitude
        && a.address == address.address);
    _parcelRecentAddresses.insert(0, address);
    if (_parcelRecentAddresses.length > AppConstants.parcelRecentAddressesMax) {
      _parcelRecentAddresses = _parcelRecentAddresses.sublist(0, AppConstants.parcelRecentAddressesMax);
    }
    try {
      final SharedPreferences prefs = Get.find<SharedPreferences>();
      final String encoded = jsonEncode(_parcelRecentAddresses.map((a) => a.toJson()).toList());
      await prefs.setString(AppConstants.parcelRecentAddresses, encoded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Parcel recent addresses save error: $e');
      }
    }
    update();
  }

  void setDestinationAddress(AddressModel? addressModel, {bool notify = true}) {
    _destinationAddress = addressModel;
    if (notify) {
      update();
    }
  }

  void setLocationFromPlace(
      String? placeID, String? address, bool? isPickedUp) async {
    Response response = await parcelServiceInterface.getPlaceDetails(placeID);
    if (response.statusCode == 200) {
      PlaceDetailsModel placeDetails =
          PlaceDetailsModel.fromJson(response.body);
      await _processAddressAndAction(placeDetails, address);
    }
  }

  Future<void> _processAddressAndAction(
      PlaceDetailsModel placeDetails, String? address) async {
    if (placeDetails.status == 'OK') {
      AddressModel address0 = AddressModel(
        address: address,
        addressType: 'others',
        latitude: placeDetails.result!.geometry!.location!.lat.toString(),
        longitude: placeDetails.result!.geometry!.location!.lng.toString(),
        contactPersonName:
            AddressHelper.getUserAddressFromSharedPref()!.contactPersonName,
        contactPersonNumber:
            AddressHelper.getUserAddressFromSharedPref()!.contactPersonNumber,
      );
      ZoneResponseModel response0 = await Get.find<LocationController>()
          .getZone(address0.latitude, address0.longitude, false);
      if (response0.isSuccess) {
        bool inZone = false;
        for (int zoneId
            in AddressHelper.getUserAddressFromSharedPref()!.zoneIds!) {
          if (response0.zoneIds.contains(zoneId)) {
            inZone = true;
            break;
          }
        }
        if (inZone) {
          address0.zoneId = response0.zoneIds[0];
          address0.zoneIds = [];
          address0.zoneIds!.addAll(response0.zoneIds);
          address0.zoneData = [];
          address0.zoneData!.addAll(response0.zoneData);
          if (isPickedUp!) {
            setPickupAddress(address0, true);
          } else {
            setDestinationAddress(address0);
          }
        } else {
          showCustomSnackBar(
              'your_selected_location_is_from_different_zone_store'.tr);
        }
      } else {
        showCustomSnackBar(response0.message);
      }
    }
  }

  Future<void> getWhyChooseDetails(
      {DataSourceEnum source = DataSourceEnum.local}) async {
    if (source == DataSourceEnum.local) {
      _whyChooseDetails =
          await parcelServiceInterface.getWhyChooseDetails(source: source);
      update();
      getWhyChooseDetails(source: DataSourceEnum.client);
    } else {
      _whyChooseDetails =
          await parcelServiceInterface.getWhyChooseDetails(source: source);
      update();
    }
  }

  Future<void> getVideoContentDetails(
      {DataSourceEnum source = DataSourceEnum.local}) async {
    if (source == DataSourceEnum.local) {
      _videoContentDetails =
          await parcelServiceInterface.getVideoContentDetails(source: source);
      update();
      getVideoContentDetails(source: DataSourceEnum.client);
    } else {
      _videoContentDetails =
          await parcelServiceInterface.getVideoContentDetails(source: source);
      update();
    }
  }

  void setIsPickedUp(bool? isPickedUp, bool notify) {
    _isPickedUp = isPickedUp;
    if (notify) {
      update();
    }
  }

  void setIsSender(bool sender, bool notify) {
    _isSender = sender;
    if (notify) {
      update();
    }
  }

  void getDistance(
      AddressModel pickedUpAddress, AddressModel destinationAddress,
      {ParcelCategoryModel? category}) async {
    _distance = -1;
    Get.find<CheckoutController>().resetCheckoutSummary();
    _distance = await Get.find<CheckoutController>().getDistanceInKM(
      LatLng(double.parse(pickedUpAddress.latitude!),
          double.parse(pickedUpAddress.longitude!)),
      LatLng(double.parse(destinationAddress.latitude!),
          double.parse(destinationAddress.longitude!)),
    );

    _extraCharge = Get.find<CheckoutController>().extraCharge;

    if (category != null && _distance != -1) {
      await getParcelDeliverySummary(pickedUpAddress, destinationAddress, category);
    }

    update();
  }

  Future<void> getParcelDeliverySummary(
      AddressModel pickedUpAddress, AddressModel destinationAddress, ParcelCategoryModel category) async {
    try {
      final body = CheckoutSummaryBodyModel(
        orderType: 'parcel',
        orderAmount: 0,
        distance: (_distance != null && _distance! > 0) ? _distance! : 0,
        latitude: pickedUpAddress.latitude,
        longitude: pickedUpAddress.longitude,
        parcelCategoryId: category.id,
        weightId: _selectedWeightId,
        dimensionId: _selectedDimensionId,
        receiverDetails: destinationAddress,
        guestId: AuthHelper.isGuestLoggedIn() ? AuthHelper.getGuestId() : null,
      );
      await Get.find<CheckoutController>().getCheckoutSummary(body, notify: true, force: true);
    } catch (e) {
      debugPrint('Error getting parcel checkout summary: $e');
    }
  }

  double calculateDeliveryCharge(ParcelCategoryModel category, {double? surgePrice, String? surgePriceType}) {
    final summary = Get.find<CheckoutController>().checkoutSummary;
    if (summary?.delivery?.deliveryCharge != null) {
      return PriceConverter.toFixed(summary!.delivery!.deliveryCharge!);
    }
    double charge = 0;
    if (_distance != -1 && _extraCharge != null) {
      final config = Get.find<SplashController>().configModel!;
      final double perKmCharge = (category.parcelPerKmShippingCharge ?? 0) > 0
          ? category.parcelPerKmShippingCharge! : (config.parcelPerKmShippingCharge ?? 0);
      final double minimumCharge = (category.parcelMinimumShippingCharge ?? 0) > 0
          ? category.parcelMinimumShippingCharge! : (config.parcelMinimumShippingCharge ?? 0);
      charge = _distance! * perKmCharge;
      if (charge < minimumCharge) {
        charge = minimumCharge;
      }
      if (category.charge != null && category.charge! > 0) {
        charge += category.charge!;
      }
      charge = charge + _extraCharge!;
      if (surgePrice != null && surgePrice > 0) {
        charge = surgePriceType == 'percent' ? charge + (charge * (surgePrice / 100)) : charge + surgePrice;
      }
    } else if (category.charge != null && category.charge! > 0) {
      charge = category.charge!;
    }
    return PriceConverter.toFixed(charge);
  }

  double calculateProDiscount(double charge, ProActiveBenefit? benefit) {
    if (benefit == null || benefit.type != ProBenefitType.discount || charge <= 0) return 0;
    final bool meetsMinOrder = benefit.minOrderStatus != true || charge >= (benefit.minOrderAmount ?? 0);
    if (!meetsMinOrder) return 0;
    double proDiscount = charge * ((benefit.percentage ?? 0) / 100);
    if (benefit.maxAmount != null && benefit.maxAmount! > 0 && proDiscount > benefit.maxAmount!) {
      proDiscount = benefit.maxAmount!;
    }
    if (proDiscount > charge) proDiscount = charge;
    return PriceConverter.toFixed(proDiscount);
  }

  double calculateProDeliveryDiscount(double charge, ProActiveBenefit? benefit) {
    if (benefit == null || benefit.type != ProBenefitType.deliveryFee || charge <= 0) return 0;
    final bool meetsMinOrder = benefit.minOrderStatus != true || charge >= (benefit.minOrderAmount ?? 0);
    if (!meetsMinOrder) return 0;
    if (benefit.offerType == ProOfferType.fullFree) return PriceConverter.toFixed(charge);
    return PriceConverter.toFixed(charge * ((benefit.chargeDiscountPercentage ?? 0) / 100));
  }

  ParcelBill calculateBill(ParcelCategoryModel category, {double? surgePrice, String? surgePriceType}) {
    final config = Get.find<SplashController>().configModel!;
    final double additionalCharge = (config.additionalChargeStatus ?? false) ? (config.additionCharge ?? 0) : 0;
    final double tax = 0;

    double charge = 0;
    double proDiscount = 0;
    double proDeliveryDiscount = 0;
    double total = 0;

    final summary = Get.find<CheckoutController>().checkoutSummary;
    if (summary?.delivery?.deliveryCharge != null) {
      charge = summary!.delivery!.deliveryCharge!;
      if (summary.pro?.discount != null) {
        proDiscount = summary.pro!.discount!;
      }
      if (summary.pro?.deliverySavings != null) {
        proDeliveryDiscount = summary.pro!.deliverySavings!;
      }
      total = charge + _tips + additionalCharge + tax - proDiscount - proDeliveryDiscount;
      if (total < 0) total = 0;
      return ParcelBill(
        charge: charge, dmTips: _tips, additionalCharge: additionalCharge, tax: tax,
        proDiscount: proDiscount, proDeliveryDiscount: proDeliveryDiscount, total: total,
      );
    }

    if (_distance != -1 && _extraCharge != null) {
      charge = calculateDeliveryCharge(category, surgePrice: surgePrice, surgePriceType: surgePriceType);
      total = charge + _tips + additionalCharge + tax;

      final bool isPro = AuthHelper.isLoggedIn() && (Get.find<ProfileController>().userInfoModel?.proStatus ?? false);
      if (isPro) {
        final ProActiveBenefit? benefit = Get.find<ProController>().activeOfferModel?.benefit;
        proDiscount = calculateProDiscount(charge, benefit);
        proDeliveryDiscount = calculateProDeliveryDiscount(charge, benefit);
        total = total - proDiscount - proDeliveryDiscount;
      }
    }

    return ParcelBill(
      charge: charge, dmTips: _tips, additionalCharge: additionalCharge, tax: tax,
      proDiscount: proDiscount, proDeliveryDiscount: proDeliveryDiscount, total: total,
    );
  }

  void setPayerIndex(int index, bool notify) {
    _payerIndex = index;
    if (_payerIndex == 1) {
      _paymentIndex = 0;
    }
    if (notify) {
      update();
    }
  }

  void setPaymentIndex(int index, bool notify) {
    _paymentIndex = index;
    if (notify) {
      update();
    }
  }

  void startLoader(bool isEnable, {bool canUpdate = true}) {
    _isLoading = isEnable;
    if (canUpdate) {
      update();
    }
  }

  Future<void> getParcelInstruction() async {
    _parcelInstructionList = null;
    _parcelInstructionList =
        await parcelServiceInterface.getParcelInstruction(1);
    update();
  }

  void setInstructionselectedIndex(int index, {bool notify = true}) {
    _instructionselectedIndex = index;
    if (notify) {
      update();
    }
  }

  void setCustomNoteController(String customNote, {bool notify = true}) {
    _customNoteController.text = customNote;
    if (notify) {
      update();
    }
  }

  void setCustomNote(String? customNoteText) {
    if (customNoteText != null && customNoteText.isNotEmpty) {
      _customNote = customNoteText;
      update();
    } else {
      _customNote = _customNoteController.text;
    }
    if (customNoteText == null) {
      update();
    }
  }

  void setSelectedIndex(int? index) {
    if (index != null) {
      _selectedIndexNote = index;
    } else {
      _selectedIndexNote = _instructionselectedIndex;
    }
    if (index == null) {
      update();
    }
  }

  Future<void> getOfflineMethodList() async {
    _offlineMethodList = null;
    _offlineMethodList = await parcelServiceInterface.getOfflineMethodList();
    update();
  }

  Future<void> getDmTipMostTapped() async {
    _mostDmTipAmount = await parcelServiceInterface.getDmTipMostTapped();
    update();
  }

  void updateTips(int index, {bool notify = true}) {
    _selectedTips = index;
    if (_selectedTips == 0 || _selectedTips == 5) {
      _tips = 0;
    } else {
      _tips = double.parse(AppConstants.tips[index]);
    }
    if (notify) {
      update();
    }
  }

  dynamic _bodyValue(Response response, String key) {
    final dynamic unwrapped = ResponseParser.payloadOf(response.body);
    if (unwrapped is Map && unwrapped.containsKey(key)) {
      return unwrapped[key];
    }
    final dynamic body = response.body;
    return body is Map ? body[key] : null;
  }

  String _orderIdOf(Response response) {
    final dynamic id = _bodyValue(response, 'order_id') ?? _bodyValue(response, 'id');
    return id != null ? id.toString() : '';
  }

  String? _messageOf(Response response) {
    final dynamic body = response.body;
    if (body is Map) {
      if (body['message'] != null && body['message'].toString().isNotEmpty) {
        return body['message'].toString();
      }
      if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
        final dynamic firstErr = (body['errors'] as List).first;
        if (firstErr is Map && firstErr['message'] != null) {
          return firstErr['message'].toString();
        }
      }
    }
    final dynamic unwrapped = ResponseParser.payloadOf(response.body);
    if (unwrapped is Map && unwrapped['message'] != null) {
      return unwrapped['message'].toString();
    }
    return response.statusText;
  }

  Future<String> placeOrder(
      PlaceOrderBodyModel placeOrderBody,
      int? zoneID,
      double amount,
      double? maximumCodOrderAmount,
      bool fromCart,
      bool isCashOnDeliveryActive,
      {bool forParcel = false,
      bool isOfflinePay = false}) async {
    _isLoading = true;
    update();
    String orderID = '';
    try {
      Response response = await parcelServiceInterface.placeOrder(placeOrderBody);
      _isLoading = false;
      if (ApiClient.isSuccessCode(response.statusCode)) {
        String? message = _messageOf(response);
        orderID = _orderIdOf(response);
        int? createUserId = int.tryParse(_bodyValue(response, 'user_id')?.toString() ?? '');

        if (forParcel && _destinationAddress != null) {
          await addParcelRecentAddress(_destinationAddress!);
        }

        if (!isOfflinePay) {
          await parcelCallback(
              true,
              message,
              orderID,
              zoneID,
              amount,
              maximumCodOrderAmount,
              isCashOnDeliveryActive,
              placeOrderBody.contactPersonNumber,
              createUserId: createUserId,
              customerName: placeOrderBody.contactPersonName,
              customerEmail: placeOrderBody.guestEmail);
        } else {
          startLoader(false);
          Get.offNamed(RouteHelper.getOfflinePaymentScreen(
            zoneId: zoneID,
            total: amount,
            orderId: orderID,
            contactNumber: placeOrderBody.contactPersonNumber ?? '',
            maxCodOrderAmount: maximumCodOrderAmount,
            fromCart: false,
            isCodActive: isCashOnDeliveryActive,
            forParcel: true,
          ));
        }
        if (kDebugMode) {
          print('-------- Order placed successfully $orderID ----------');
        }
      } else {
        startLoader(false);
        String? errorMsg = _messageOf(response) ?? 'failed_to_place_order'.tr;
        if (!isOfflinePay) {
          await parcelCallback(
              false,
              errorMsg,
              '-1',
              zoneID,
              amount,
              maximumCodOrderAmount,
              isCashOnDeliveryActive,
              placeOrderBody.contactPersonNumber);
        } else {
          showCustomSnackBar(errorMsg);
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('-------- Error placing parcel order: $e\n$stack ----------');
      }
      _isLoading = false;
      startLoader(false);
      showCustomSnackBar('failed_to_place_order'.tr);
    }
    update();

    return orderID;
  }

  Future<void> parcelCallback(
      bool isSuccess,
      String? message,
      String orderID,
      int? zoneID,
      double orderAmount,
      double? maxCodAmount,
      bool isCashOnDeliveryActive,
      String? contactNumber,
      {int? createUserId, String? customerName, String? customerEmail}) async {
    Get.find<ParcelController>().startLoader(false);
    if (isSuccess) {
      if (isDmTipSave) {
        Get.find<AuthController>().saveDmTipIndex(selectedTips.toString());
      }
      Get.find<CheckoutController>().setGuestAddress(null);
      if (Get.find<ParcelController>().paymentIndex == 2) {
        if (GetPlatform.isWeb) {
          // Get.back();
          await Get.find<AuthController>().saveGuestNumber(contactNumber ?? '');
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl =
              '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<ProfileController>().userInfoModel?.id ?? (Get.find<CheckoutController>().isCreateAccount ? createUserId : AuthHelper.getGuestId())}'
              '&payment_method=${Get.find<ParcelController>().digitalPaymentName}&payment_platform=web&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl, "_self");
        } else {
          Get.offNamed(RouteHelper.getPaymentRoute(
            orderID,
            Get.find<ProfileController>().userInfoModel?.id ?? 0,
            'parcel',
            orderAmount,
            isCashOnDeliveryActive,
            Get.find<ParcelController>().digitalPaymentName,
            guestId: AuthHelper.getGuestId(),
            contactNumber: contactNumber,
            createAccount: Get.find<CheckoutController>().isCreateAccount,
            createUserId: createUserId,
          ));
        }
      } else {
        Get.offNamed(RouteHelper.getOrderSuccessRoute(
          orderID,
          contactNumber,
          createAccount: Get.find<CheckoutController>().isCreateAccount,
          customerName: customerName,
          customerEmail: customerEmail,
        ));
      }
      updateTips(0, notify: false);
    } else {
      showCustomSnackBar(message);
    }
  }
}

class ParcelBill {
  final double charge;
  final double dmTips;
  final double additionalCharge;
  final double tax;
  final double proDiscount;
  final double proDeliveryDiscount;
  final double total;

  const ParcelBill({
    required this.charge,
    required this.dmTips,
    required this.additionalCharge,
    required this.tax,
    required this.proDiscount,
    required this.proDeliveryDiscount,
    required this.total,
  });
}
