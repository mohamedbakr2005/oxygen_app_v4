import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    if (response.statusCode == 401) {
      Get.find<AuthController>()
          .clearSharedData(removeToken: false)
          .then((value) {
        Get.find<FavouriteController>().removeFavourite();
        Get.offAllNamed(RouteHelper.getInitialRoute());
      });
    } else {
      if (response.statusText != 'The guest id field is required.') {
        showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
      }
    }
  }
}
