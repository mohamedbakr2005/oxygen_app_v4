import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';

class AuthHelper {
  static bool isGuestLoggedIn() {
    return !isLoggedIn();
  }

  static String getGuestId() {
    return Get.find<AuthController>().getGuestId();
  }

  static bool isLoggedIn() {
    return Get.find<AuthController>().isLoggedIn();
  }
}
