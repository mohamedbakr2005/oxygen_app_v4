import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:Oxygen_Mart/helper/auth_event_logger_firebase.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/domain/models/signup_body_model.dart';
import 'package:Oxygen_Mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:Oxygen_Mart/features/auth/domain/services/auth_service_interface.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/profile/domain/models/update_user_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/verification/screens/verification_screen.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart'; 

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _notification = authServiceInterface.isSharedPrefNotificationActive();
  }

  bool _notification = true;
  bool get notification => _notification;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _guestLoading = false;
  bool get guestLoading => _guestLoading;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  bool _isNumberLogin = true;
  bool get isNumberLogin => _isNumberLogin;

  var countryDialCode = "+20";

/*  Future<ResponseModel> registration(SignUpBodyModel signUpBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.registration(signUpBody, Get.find<SplashController>().configModel!.customerVerification!);
    if (responseModel.isSuccess && !Get.find<SplashController>().configModel!.customerVerification!) {
      Get.find<ProfileController>().getUserInfo();
    }
    _isLoading = false;
    update();
    return responseModel;
  }*/

  Future<ResponseModel> registration(SignUpBodyModel signUpBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel =
        await authServiceInterface.registration(signUpBody);
    _isLoading = false;
    update();
    if (responseModel.isSuccess) {
      AuthEventLogger.signup(
        email: signUpBody.email,
        phone: signUpBody.phone,
      );
      Get.find<MetaAnalyticsService>().completeRegistration(registrationMethod: 'email_or_phone');
    }

    return responseModel;
  }

  Future<ResponseModel> login(
      {required String emailOrPhone,
      required String password,
      required String loginType,
      required String fieldType,
      bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(
        emailOrPhone: emailOrPhone,
        password: password,
        loginType: loginType,
        fieldType: fieldType,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    if (responseModel.isSuccess) {
      AuthEventLogger.login(
        method: loginType,
        fieldType: fieldType,
        value: emailOrPhone,
      );
      Get.find<MetaAnalyticsService>().login(loginMethod: loginType);
    }

    return responseModel;
  }

  Future<ResponseModel> otpLogin(
      {required String phone,
      required String loginType,
      required String otp,
      required String verified,
      bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.otpLogin(
        phone: phone,
        otp: otp,
        loginType: loginType,
        verified: verified,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    if (responseModel.isSuccess) {
      AuthEventLogger.otpVerification(
        phone: phone,
        verified: verified,
      );
      Get.find<MetaAnalyticsService>().login(loginMethod: loginType);
    }
    return responseModel;
  }

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.guestLogin();
    _guestLoading = false;
    update();
    return responseModel;
  }

  /*Future<void> loginWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    bool canNavigateToLocation = await authServiceInterface.loginWithSocialMedia(socialLogInBody, 60, Get.find<SplashController>().configModel!.customerVerification!);
    if(canNavigateToLocation) {
      Get.find<LocationController>().navigateToLocationScreen('sign-in');
    }
    _isLoading = false;
    update();
  }*/

  Future<ResponseModel> loginWithSocialMedia(
      SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();

    ResponseModel responseModel =
        await authServiceInterface.loginWithSocialMedia(
      socialLogInBody,
      isCustomerVerificationOn:
          Get.find<SplashController>().configModel!.customerVerification!,
    );

    final res = responseModel.authResponseModel;

    _isLoading = false;
    update();

    // ✅ لو اليوزر موجود قبل كده → ادخله مباشرة
    if (res != null && res.isExistUser != null) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getCartDataOnline();
      Get.find<LocationController>()
          .navigateToLocationScreen('sign-in', offNamed: true);
      Get.find<MetaAnalyticsService>().login(loginMethod: socialLogInBody.loginType ?? 'social');
      return responseModel;
    }

    // ❗ لو جديد و ناقص بيانات → روح للـ NewUserSetup
    // if (res != null && !res.isPersonalInfo!) {
    //   Get.toNamed(RouteHelper.getNewUserSetupScreen(
    //     name: socialLogInBody.name ?? '',
    //     loginType: socialLogInBody.loginType ?? '',
    //     phone: socialLogInBody.phone ?? '',
    //     email: socialLogInBody.email ?? '',
    //   ));
    //   return responseModel;
    // }

    // ✅ باقي الحالات → كمل طبيعي
    _getUserAndCartData(responseModel);
    return responseModel;
  }

  void toggleIsNumberLogin({bool? value, bool willUpdate = true}) {
    if (value == null) {
      _isNumberLogin = !_isNumberLogin;
    } else {
      _isNumberLogin = value;
    }
    initCountryCode();
    if (willUpdate) {
      update();
    }
  }

  Future<ResponseModel> updatePersonalInfo(
      {required String name,
      required String? phone,
      required String loginType,
      required String? email,
      required String? referCode,
      bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.updatePersonalInfo(
        name: name,
        phone: phone,
        email: email,
        loginType: loginType,
        referCode: referCode,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void _getUserAndCartData(ResponseModel responseModel) {
    final res = responseModel.authResponseModel;

    // لو مفيش auth response → مفيش لوجيك
    if (res == null) return;

    // ✅ لو اليوزر موجود بالفعل → ادخله مباشرة (حتى لو is_personal_info = 0)
    if (res.isExistUser != null) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getCartDataOnline();
      Get.find<LocationController>()
          .navigateToLocationScreen('sign-in', offNamed: true);
      return;
    }

    // ❗ لو يوزر جديد لكنه ناقص بيانات → هنا نبعت للـ NewUserSetup
    // if (!res.isPersonalInfo!) {
    //   Get.toNamed(RouteHelper.getNewUserSetupScreen(
    //     name: res.email ?? '',
    //     loginType: res.loginType ?? '',
    //     phone: "",
    //     email: res.email ?? "",
    //   ));
    //   return;
    // }

    // ✅ لو مكتمل كل حاجة → ادخله عادي
    if (res.isPhoneVerified! && res.isEmailVerified! && res.isPersonalInfo!) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getCartDataOnline();
      Get.find<LocationController>()
          .navigateToLocationScreen('sign-in', offNamed: true);
    }
  }

  void initCountryCode({String? countryCode}) {
    countryDialCode = countryCode ??
        CountryCode.fromCountryCode(
                Get.find<SplashController>().configModel!.country ?? "BD")
            .dialCode ??
        "+880";
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  bool isGuestLoggedIn() {
    return authServiceInterface.isGuestLoggedIn() &&
        !authServiceInterface.isLoggedIn();
  }

  String getGuestId() {
    return authServiceInterface.getSharedPrefGuestId();
  }

  Future<bool> clearSharedData({bool removeToken = true}) async {
    if (!ResponsiveHelper.isDesktop(Get.context)) {
      Get.find<SplashController>().setModule(null);
    }
    return await authServiceInterface.clearSharedData(removeToken: removeToken);
  }

  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    AuthEventLogger.logout();
    await FacebookAuth.instance.logOut();
  }

  Future<bool> clearSharedAddress() async {
    return await authServiceInterface.clearSharedAddress();
  }

  Future<void> saveUserNumberAndPasswordSharedPref(
      String number, String password, String countryCode) async {
    await authServiceInterface.saveUserNumberAndPassword(
        number, password, countryCode);
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  void saveUserNumberAndPassword(
      String number, String password, String countryCode) {
    authServiceInterface.saveUserNumberAndPassword(
        number, password, countryCode);
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<void> updateZone() async {
    await authServiceInterface.updateZone();
  }

  Future<void> saveGuestNumber(String number) async {
    await authServiceInterface.saveGuestContactNumber(number);
  }

  String getGuestNumber() {
    return authServiceInterface.getGuestContactNumber();
  }

  Future<void> saveDmTipIndex(String i) async {
    await authServiceInterface.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return authServiceInterface.getDmTipIndex();
  }

  void saveEarningPoint(String point) {
    authServiceInterface.saveEarningPoint(point);
  }

  String getEarningPint() {
    return authServiceInterface.getEarningPint();
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    await authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  Future<String?> saveDeviceToken() async {
    return await authServiceInterface.saveDeviceToken();
  }

  Future<void> firebaseVerifyPhoneNumber(
      String phoneNumber, String? token, String loginType,
      {bool fromSignUp = true,
      bool canRoute = true,
      UpdateUserModel? updateUserModel}) async {
    _isLoading = true;
    update();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _isLoading = false;
        update();

        if (Get.isDialogOpen!) {
          Get.back();
        }

        if (e.code == 'invalid-phone-number') {
          showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
        } else {
          showCustomSnackBar(e.message?.replaceAll('_', ' '));
        }
      },
      codeSent: (String vId, int? resendToken) {
        if (Get.isDialogOpen!) {
          Get.back();
        }

        _isLoading = false;
        update();
        if (updateUserModel != null) {
          updateUserModel.sessionInfo = vId;
        }

        if (canRoute) {
          if (ResponsiveHelper.isDesktop(Get.context)) {
            Get.back();
            Get.dialog(VerificationScreen(
              number: phoneNumber,
              email: null,
              token: token,
              fromSignUp: fromSignUp,
              fromForgetPassword: !fromSignUp,
              loginType: loginType,
              password: '',
              firebaseSession: vId,
              userModel: updateUserModel,
            ));
          } else {
            Get.toNamed(RouteHelper.getVerificationRoute(
              phoneNumber,
              '',
              token,
              fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword,
              '',
              loginType,
              session: vId,
              updateUserModel: updateUserModel,
            ));
          }
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (Get.isDialogOpen!) {
          Get.back();
        }
        showCustomSnackBar('timed_out_please_try_again_after_few_minutes'.tr);
      },
    );
  }
}
