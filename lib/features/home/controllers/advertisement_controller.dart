import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/features/home/domain/models/advertisement_model.dart';
import 'package:Oxygen_Mart/features/home/domain/services/advertisement_service_interface.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';

class AdvertisementController extends GetxController implements GetxService {
  final AdvertisementServiceInterface advertisementServiceInterface;
  AdvertisementController({required this.advertisementServiceInterface});

  List<AdvertisementModel>? _advertisementList;
  List<AdvertisementModel>? get advertisementList => _advertisementList;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Duration autoPlayDuration = const Duration(seconds: 7);
  bool autoPlay = true;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _loadedOnce = false;

  void clearAdvertisementList() {
    _advertisementList = null;
    _currentIndex = 0;
    _loadedOnce = false;
  }

  Future<void> getAdvertisementList({
    DataSourceEnum dataSource = DataSourceEnum.local,
    bool reload = false,
  }) async {
    final splash = Get.find<SplashController>();

    if (splash.isRefreshing) return;
    if (_isLoading) return;
    if (_loadedOnce && !reload && dataSource == DataSourceEnum.client) return;

    _isLoading = true;

    try {
      if (dataSource == DataSourceEnum.local) {
        final localData = await advertisementServiceInterface
            .getAdvertisementList(DataSourceEnum.local);

        if (localData != null) {
          _advertisementList = localData;
          _currentIndex = 0;
          autoPlay = true;
          update();
        }

        final clientData = await advertisementServiceInterface
            .getAdvertisementList(DataSourceEnum.client);

        if (clientData != null) {
          _advertisementList = clientData;
          _loadedOnce = true;
        } else if (_advertisementList == null) {
          _advertisementList = [];
        }

        _currentIndex = 0;
        autoPlay = true;
        update();
      } else {
        if (_loadedOnce && !reload) return;

        final clientData = await advertisementServiceInterface
            .getAdvertisementList(DataSourceEnum.client);

        if (clientData != null) {
          _advertisementList = clientData;
          _loadedOnce = true;
        } else if (_advertisementList == null) {
          _advertisementList = [];
        }

        update();
      }
    } finally {
      _isLoading = false;
    }
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) update();
  }

  void updateAutoPlayStatus({bool shouldUpdate = false, bool status = false}) {
    autoPlay = status;
    if (shouldUpdate) update();
  }
}
