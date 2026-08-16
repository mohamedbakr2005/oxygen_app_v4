import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_model.dart';
import 'package:Oxygen_Mart/features/notification/domain/service/notification_service_interface.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  List<NotificationModel>? _notificationList;
  List<NotificationModel>? get notificationList => _notificationList;

  bool _hasNotification = false;
  bool get hasNotification => _hasNotification;

  // Guards
  bool _isLoading = false;
  bool _loadedOnce = false;

  // MAIN FUNCTION (Hardened)
  Future<int> getNotificationList(bool reload) async {
    final splash = Get.find<SplashController>();

    // ⛔ ممنوع تعمل Calls أثناء Refresh
    if (splash.isRefreshing) return _notificationList?.length ?? 0;

    // ⛔ لو في Request شغال = skip
    if (_isLoading) return _notificationList?.length ?? 0;

    // ⛔ لو Already Loaded ومفيش Reload
    if (_loadedOnce && !reload) {
      return _notificationList?.length ?? 0;
    }

    _isLoading = true;

    try {
      final fetchedList =
          await notificationServiceInterface.getNotificationList();

      if (fetchedList != null) {
        // نسخة جديدة
        _notificationList = [...fetchedList];

        // sort time descending
        _notificationList!.sort((a, b) {
          return DateConverter.isoStringToLocalDate(a.updatedAt!)
              .compareTo(DateConverter.isoStringToLocalDate(b.updatedAt!));
        });

        // latest first
        _notificationList = _notificationList!.reversed.toList();

        // seen state
        _hasNotification =
            _notificationList!.length != getSeenNotificationCount();

        _loadedOnce = true;
      }

      update();
    } finally {
      _isLoading = false;
    }

    return _notificationList?.length ?? 0;
  }

  // Save seen count
  void saveSeenNotificationCount(int count) {
    notificationServiceInterface.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationServiceInterface.getSeenNotificationCount();
  }

  void clearNotification() {
    _notificationList = null;
    _loadedOnce = false;
    update();
  }

  List<int>? getSeenNotificationIdList() {
    return notificationServiceInterface.getNotificationIdList();
  }

  void addSeenNotificationId(int id) {
    List<int> idList = [];
    idList.addAll(notificationServiceInterface.getNotificationIdList());
    idList.add(id);
    notificationServiceInterface.addSeenNotificationIdList(idList);
    update();
  }

  Future<void> trackNotification(int notificationId, String status) async {
    print("TRACKING -> id:$notificationId status:$status");
    print("TRACKING -> id:$notificationId status:$status");
    print("TRACKING -> id:$notificationId status:$status");
    print("TRACKING -> id:$notificationId status:$status");
    print("TRACKING -> id:$notificationId status:$status");
    print("TRACKING -> id:$notificationId status:$status");
    print("TRACKING -> id:$notificationId status:$status");
    await notificationServiceInterface.trackNotification(
        notificationId, status);
  }
}
