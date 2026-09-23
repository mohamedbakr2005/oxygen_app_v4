import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/chat/domain/models/conversation_model.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/profile/domain/models/update_user_model.dart';
import 'package:Oxygen_Mart/features/profile/domain/models/userinfo_model.dart';
import 'package:Oxygen_Mart/features/profile/domain/services/profile_service_interface.dart';
import 'package:Oxygen_Mart/features/verification/screens/verification_screen.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';

class ProfileController extends GetxController implements GetxService {
  final ProfileServiceInterface profileServiceInterface;
  ProfileController({required this.profileServiceInterface});

  UserInfoModel? _userInfoModel;
  UserInfoModel? get userInfoModel => _userInfoModel;

  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;

  bool get proStatus => _userInfoModel?.proStatus ?? false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getUserInfo() async {
    _pickedFile = null;
    UserInfoModel? userInfoModel = await profileServiceInterface.getUserInfo();
    if (userInfoModel != null) {
      _userInfoModel = userInfoModel;
    }
    update();
  }

  // ==========================
  // Update User Info
  // ==========================
  Future<ResponseModel> updateUserInfo(
      UpdateUserModel updateUserModel, String token,
      {bool fromVerification = false, bool fromButton = false}) async {
    if (fromButton) {
      _isLoading = true;
      update();
    }

    ResponseModel responseModel = await profileServiceInterface.updateProfile(
        updateUserModel, _pickedFile, token);

    if (!fromVerification) {
      await _handleUpdateResponse(responseModel, updateUserModel, token);
    }

    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> _handleUpdateResponse(ResponseModel responseModel,
      UpdateUserModel updateUserModel, String token) async {
    updateUserModel.verificationOn =
        responseModel.updateProfileResponseModel?.verificationOn;
    updateUserModel.verificationMedium =
        responseModel.updateProfileResponseModel?.verificationMedium;

    // ------------------------------
    // PHONE VERIFICATION
    // ------------------------------
    if (responseModel.isSuccess &&
        responseModel.updateProfileResponseModel?.verificationOn == 'phone') {
      if (responseModel.updateProfileResponseModel?.verificationMedium ==
          'firebase') {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(
            updateUserModel.phone!, token, '',
            fromSignUp: false, updateUserModel: updateUserModel);
      } else {
        if (Get.isDialogOpen!) Get.back();

        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.dialog(VerificationScreen(
            number: updateUserModel.phone!,
            email: null,
            token: '',
            fromSignUp: false,
            fromForgetPassword: false,
            loginType: '',
            password: '',
            userModel: updateUserModel,
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
              updateUserModel.phone!, null, '', '', null, '',
              updateUserModel: updateUserModel));
        }
      }
      return;
    }

    // ------------------------------
    // EMAIL VERIFICATION
    // ------------------------------
    if (responseModel.isSuccess &&
        responseModel.updateProfileResponseModel?.verificationOn == 'email') {
      if (Get.isDialogOpen!) Get.back();

      if (ResponsiveHelper.isDesktop(Get.context)) {
        Get.dialog(VerificationScreen(
          number: null,
          email: updateUserModel.email!,
          token: '',
          fromSignUp: false,
          fromForgetPassword: false,
          loginType: '',
          password: '',
          userModel: updateUserModel,
        ));
      } else {
        Get.toNamed(RouteHelper.getVerificationRoute(
            null, updateUserModel.email!, '', '', null, '',
            updateUserModel: updateUserModel));
      }
      return;
    }

    // ------------------------------
    // SUCCESS WITHOUT VERIFICATION
    // ------------------------------
    if (responseModel.isSuccess &&
        responseModel.updateProfileResponseModel == null) {
      if (Get.isDialogOpen!) Get.back();

      await getUserInfo();

      if (!ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.back();
      }

      _pickedFile = null;
      showCustomSnackBar(responseModel.message, isError: false);
      return;
    }

    // ------------------------------
    // FAIL CASES
    // ------------------------------
    if (!responseModel.isSuccess) {
      if (Get.isDialogOpen!) Get.back();

      String? msg = responseModel.updateProfileResponseModel?.message ??
          responseModel.message;

      showCustomSnackBar(msg);
    }
  }

  // ==========================
  // Password Change
  // ==========================
  Future<ResponseModel> changePassword(UserInfoModel updatedUserModel) async {
    _isLoading = true;
    update();

    ResponseModel response =
        await profileServiceInterface.changePassword(updatedUserModel);

    _isLoading = false;
    update();
    return response;
  }

  // ==========================
  // Image Picker
  // ==========================
  void pickImage() async {
    _pickedFile = await profileServiceInterface.pickImageFromGallery();
    update();
  }

  void initData({bool isUpdate = false}) {
    _pickedFile = null;
    if (isUpdate) update();
  }

  // ==========================
  // Delete User
  // ==========================

  void updateUserWithNewData(User? user) {
    if (_userInfoModel != null) {
      _userInfoModel!.userInfo = user;
      update();
    }
  }

  void setForceFullyUserEmpty() {
    _userInfoModel = null;
    update();
  }

  Future<void> deleteUser() async {
    _isLoading = true;
    update();

    Response response = await profileServiceInterface.deleteUser();

    _isLoading = false;

    if (response.statusCode == 200) {
      await Get.find<AuthController>().clearSharedData(removeToken: false);
      await Get.find<AuthController>().clearUserNumberAndPassword();
      await Get.find<CartController>().clearCartList();
      if (Get.find<AuthController>().isActiveRememberMe) {
        Get.find<AuthController>().toggleRememberMe();
      }

      Get.find<FavouriteController>().removeFavourite();
      setForceFullyUserEmpty();

      showCustomSnackBar('your_account_remove_successfully'.tr, isError: false);

      Get.find<LocationController>()
          .navigateToLocationScreen('splash', offNamed: true);
    } else {
      Get.back();
    }

    update();
  }

  void clearUserInfo() {
    _userInfoModel = null;
    update();
  }
}
