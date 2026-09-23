import 'package:Oxygen_Mart/features/home/domain/models/top_offer_model.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/home/domain/models/cashback_model.dart';
import 'package:Oxygen_Mart/features/home/domain/services/home_service_interface.dart';

class HomeController extends GetxController implements GetxService {
  final HomeServiceInterface homeServiceInterface;
  HomeController({required this.homeServiceInterface});

  List<CashBackModel>? _cashBackOfferList;
  List<CashBackModel>? get cashBackOfferList => _cashBackOfferList;

  TopOfferModel? _topOffer;
  TopOfferModel? get topOffer => _topOffer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CashBackModel? _cashBackData;
  CashBackModel? get cashBackData => _cashBackData;

  bool _showFavButton = true;
  bool get showFavButton => _showFavButton;

  double? _orderAmount;
  double? get orderAmount => _orderAmount;

  // bool _canShoeReferrerBottomSheet = false;
  // bool get canShoeReferrerBottomSheet => _canShoeReferrerBottomSheet;

  // void toggleReferrerBottomSheet({bool? status}) {
  //   if(Get.find<ProfileController>().userInfoModel!.isValidForDiscount! && status == null) {
  //     _canShoeReferrerBottomSheet = true;
  //   } else {
  //     _canShoeReferrerBottomSheet = status ?? false;
  //   }
  // }

  void setOrderAmount(double amount) {
    _orderAmount = amount;
    update();
  }

  Future<void> getCashBackOfferList() async {
    _cashBackOfferList = null;
    _cashBackOfferList = await homeServiceInterface.getCashBackOfferList();
    update();
  }

  void forcefullyNullCashBackOffers() {
    _cashBackOfferList = null;
    update();
  }

  Future<void> getTopOffer({bool notify = true}) async {
    _topOffer = null;
    if (notify) update();
    _topOffer = await homeServiceInterface.getTopOffer();
    update();
  }

/*  Future<double> getCashBackAmount(double amount) async {
    _cashBackAmount = await homeServiceInterface.getCashBackAmount(amount);
    return _cashBackAmount;
  }*/

  Future<void> getCashBackData(double amount) async {
    CashBackModel? cashBackModel =
        await homeServiceInterface.getCashBackData(amount);
    if (cashBackModel != null) {
      _cashBackData = cashBackModel;
    }
    update();
  }

  void changeFavVisibility() {
    _showFavButton = !_showFavButton;
    update();
  }

  Future<bool> saveRegistrationSuccessfulSharedPref(bool status) async {
    return await homeServiceInterface.saveRegistrationSuccessful(status);
  }

  Future<bool> saveIsStoreRegistrationSharedPref(bool status) async {
    return await homeServiceInterface.saveIsRestaurantRegistration(status);
  }

  bool getRegistrationSuccessfulSharedPref() {
    return homeServiceInterface.getRegistrationSuccessful();
  }

  bool getIsStoreRegistrationSharedPref() {
    return homeServiceInterface.getIsRestaurantRegistration();
  }

  void clearModuleData() {
    Get.find<StoreController>().clearStoreData();
    Get.find<ItemController>().clearItemLists();
    update();
  }
}
