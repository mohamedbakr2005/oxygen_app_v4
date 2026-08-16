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

  //-----------------------
  // Guards
  //-----------------------
  bool _isLoading = false;
  bool _loadedOnce = false;

  //-----------------------
  // Advertisement loader (Optimized + Anti-Spam)
  //-----------------------
  Future<void> getAdvertisementList(
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool reload = false,
      bool fromRecall = false}) async {
    final splash = Get.find<SplashController>();

    // ⛔ ممنوع تعمل calls أثناء refresh
    if (splash.isRefreshing) return;

    // ⛔ لو في request شغّال — skip
    if (_isLoading) return;

    // ⛔ لو البيانات already loaded ومفيش reload — skip
    if (_loadedOnce && !reload && dataSource == DataSourceEnum.client) return;

    // ⛔ لو البيانات موجودة ومش محتاج recall — skip
    if (_advertisementList != null &&
        !reload &&
        dataSource == DataSourceEnum.local &&
        !fromRecall) {
      return;
    }

    _isLoading = true;

    try {
      List<AdvertisementModel>? response;

      if (dataSource == DataSourceEnum.local) {
        // أولاً: local data
        response = await advertisementServiceInterface
            .getAdvertisementList(DataSourceEnum.local);

        if (response != null) _advertisementList = response;

        update();

        // ثانياً: أطلب client مرة واحدة فقط
        await getAdvertisementList(
          dataSource: DataSourceEnum.client,
          fromRecall: true,
        );
      } else {
        // Client call
        if (_loadedOnce && !reload) return;

        response = await advertisementServiceInterface
            .getAdvertisementList(DataSourceEnum.client);

        if (response != null) {
          _advertisementList = response;
          _loadedOnce = true;
        }

        update();
      }
    } finally {
      _isLoading = false;
    }
  }

  //-----------------------
  // Index + autoplay controls
  //-----------------------
  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) update();
  }

  void updateAutoPlayStatus({bool shouldUpdate = false, bool status = false}) {
    autoPlay = status;
    if (shouldUpdate) update();
  }
}
