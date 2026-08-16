import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:Oxygen_Mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:Oxygen_Mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:Oxygen_Mart/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'dart:html' as html;
// import 'dart:js' as js;

class SocialLoginWidget extends StatelessWidget {
  final bool onlySocialLogin;
  final bool showWelcomeText;
  final Function()? onOtpViewClick;
  const SocialLoginWidget(
      {super.key,
      this.onlySocialLogin = false,
      this.showWelcomeText = true,
      this.onOtpViewClick});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn =
        GetPlatform.isWeb ? GoogleSignIn(scopes: []) : GoogleSignIn.standard();
    bool isWeb = GetPlatform.isWeb;

    bool canAppleLogin =
        Get.find<SplashController>().configModel!.appleLogin!.isNotEmpty &&
            Get.find<SplashController>().configModel!.appleLogin![0].status! &&
            !GetPlatform.isAndroid;

    bool canGoogleAndFacebookLogin = Get.find<SplashController>()
            .configModel!
            .socialLogin!
            .isNotEmpty &&
        (Get.find<SplashController>().configModel!.socialLogin![0].status! ||
            Get.find<SplashController>().configModel!.socialLogin![1].status!);

    bool googleLoginActive =
        Get.find<SplashController>().configModel!.socialLogin![0].status! &&
            Get.find<SplashController>()
                .configModel!
                .centralizeLoginSetup!
                .socialLoginStatus! &&
            Get.find<SplashController>()
                .configModel!
                .centralizeLoginSetup!
                .googleLoginStatus!;

    bool facebookLoginActive =
        /*  Get.find<SplashController>().configModel!.socialLogin![1].status! &&
            Get.find<SplashController>()
                .configModel!
                .centralizeLoginSetup!
                .socialLoginStatus! && */
        Get.find<SplashController>()
            .configModel!
            .centralizeLoginSetup!
            .facebookLoginStatus!;

    bool appleLoginActive = canAppleLogin &&
        Get.find<SplashController>()
            .configModel!
            .centralizeLoginSetup!
            .socialLoginStatus! &&
        Get.find<SplashController>()
            .configModel!
            .centralizeLoginSetup!
            .appleLoginStatus!;

    if (onlySocialLogin) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          canGoogleAndFacebookLogin
              ? Column(children: [
                  showWelcomeText
                      ? Text('${'welcome_to'.tr} ${AppConstants.appName}',
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge))
                      : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  (!isWeb && googleLoginActive)
                      ? Container(
                          height: 50,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2))
                            ],
                          ),
                          child: CustomInkWell(
                            onTap: () {
                              _googleLogin(googleSignIn);
                            },
                            radius: Dimensions.radiusDefault,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(Images.google,
                                        height: 20, width: 20),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text('continue_with_google'.tr,
                                        style: robotoMedium.copyWith()),
                                  ]),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                      height: (!isWeb && googleLoginActive)
                          ? Dimensions.paddingSizeLarge
                          : 0),
                  (!isWeb && facebookLoginActive)
                      ? Container(
                          height: 50,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2))
                            ],
                          ),
                          child: CustomInkWell(
                            onTap: () {
                              if (GetPlatform.isWeb) {
                                // facebookLoginWeb();
                              } else {
                                _facebookLogin(); // الموبايل
                              }
                            },
                            radius: Dimensions.radiusDefault,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(Images.socialFacebook,
                                        height: 20, width: 20),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text('continue_with_facebook'.tr,
                                        style: robotoMedium.copyWith()),
                                  ]),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                      height: (!isWeb && facebookLoginActive)
                          ? Dimensions.paddingSizeLarge
                          : 0),
                  (!isWeb && appleLoginActive)
                      ? Container(
                          height: 50,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2))
                            ],
                          ),
                          child: CustomInkWell(
                            onTap: () => _appleLogin(),
                            radius: Dimensions.radiusDefault,
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(Images.appleLogo,
                                        height: 20, width: 20),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text('continue_with_apple'.tr,
                                        style: robotoMedium.copyWith()),
                                  ]),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                      height: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeLarge
                          : onOtpViewClick != null
                              ? 0
                              : Dimensions.paddingSizeLarge),
                ])
              : const SizedBox(),
          onOtpViewClick != null
              ? Container(
                  height: 50,
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(Dimensions.radiusDefault)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(2, 2))
                    ],
                  ),
                  margin: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeExtremeLarge),
                  child: CustomInkWell(
                    onTap: onOtpViewClick!,
                    radius: Dimensions.radiusDefault,
                    child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Images.otp, height: 20, width: 20),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Text('otp_sign_in'.tr,
                                style: robotoMedium.copyWith()),
                          ]),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      );
    }

    return (!isWeb && canGoogleAndFacebookLogin) || canAppleLogin
        ? Column(children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                Expanded(
                    child: Container(
                        height: 1, color: Theme.of(context).disabledColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall),
                  child: Text('or_continue_with'.tr,
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).disabledColor)),
                ),
                Expanded(
                    child: Container(
                        height: 1, color: Theme.of(context).disabledColor)),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if ((!isWeb && googleLoginActive) && !isWeb)
                InkWell(
                  onTap: () {
                    _googleLogin(googleSignIn);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.all(
                          Radius.circular(Dimensions.radiusDefault)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(2, 2))
                      ],
                    ),
                    child: CustomInkWell(
                      radius: Dimensions.radiusDefault,
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      onTap: () => _googleLogin(googleSignIn),
                      child: Image.asset(Images.google),
                    ),
                  ),
                )
              else
                const SizedBox(),
              (!isWeb && facebookLoginActive)
                  ? Padding(
                      padding: EdgeInsets.only(
                          left: Get.find<LocalizationController>().isLtr
                              ? Dimensions.paddingSizeLarge
                              : 0,
                          right: Get.find<LocalizationController>().isLtr
                              ? 0
                              : Dimensions.paddingSizeLarge),
                      child: InkWell(
                        onTap: () => _facebookLogin(),
                        child: Container(
                          height: 40,
                          width: 40,
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2))
                            ],
                          ),
                          child: Image.asset(Images.socialFacebook),
                        ),
                      ),
                    )
                  : const SizedBox(),
              (!isWeb && appleLoginActive)
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeLarge),
                      child: InkWell(
                        onTap: () => _appleLogin(),
                        child: Container(
                          height: 40,
                          width: 40,
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusDefault)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(2, 2))
                            ],
                          ),
                          child: Image.asset(Images.appleLogo),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ])
        : const SizedBox();
  }

  void _googleLogin(GoogleSignIn googleSignIn) async {
    try {
      GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) {
        return; // User canceled the sign-in
      }

      GoogleSignInAuthentication auth = await googleAccount.authentication;

      SocialLogInBody googleBodyModel = SocialLogInBody(
        email: googleAccount.email,
        token: auth.idToken, // ✅ Correct
        uniqueId: googleAccount.id,
        medium: 'google',
        loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>()
          .loginWithSocialMedia(googleBodyModel)
          .then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, googleBodyModel, null, null);
        } else {
          showCustomSnackBar(response.message);
        }
      });
    } catch (error) {
      print('Google Sign-In Error: $error');
      showCustomSnackBar('Google Sign-In failed. Please try again.$error');
      FirebaseAnalytics.instance.logEvent(
        name: 'login_failed',
        parameters: {
          'method': 'google',
          'error': error.toString(),
        },
      );
    }
  }

  void _facebookLogin() async {
    final result = await FacebookAuth.instance.login(
      permissions: ["public_profile", "email"],
      loginBehavior: LoginBehavior.nativeWithFallback,
      loginTracking: LoginTracking.enabled,
    );

    if (result.status == LoginStatus.success) {
      final accessToken = result.accessToken;

      final String tokenToSend = accessToken!.tokenString; // ✅ ده الصح 100%
      print("✅ REAL FB Access Token = $tokenToSend");

      // ✅ نجيب البيانات من Facebook API
      final userData = await FacebookAuth.instance.getUserData(
        fields: "id,name,email,picture.width(200)",
      );

      final facebookId = userData['id'];
      final facebookEmail = userData['email'];

      print("✅ FB userId from API = $facebookId");

      SocialLogInBody facebookBodyModel = SocialLogInBody(
        name: userData['name'],
        email: facebookEmail,
        token: tokenToSend, // ✅ الصح
        uniqueId: facebookId, // ✅ الصح
        medium: 'facebook',
        loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>()
          .loginWithSocialMedia(facebookBodyModel)
          .then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, null, null, facebookBodyModel);
        } else {
          showCustomSnackBar(response.message);
        }
      });
    } else {
      showCustomSnackBar('Facebook login cancelled');
    }
  }

  // void facebookLoginWeb() {
  //   html.window.addEventListener("fb-login-success", (event) {
  //     final data = (event as html.CustomEvent).detail;

  //     final token = data['token'];
  //     final userId = data['userId'];
  //     final email = data['email'];
  //     final name = data['name'];

  //     SocialLogInBody facebookBodyModel = SocialLogInBody(
  //       name: name,
  //       email: email,
  //       token: token,
  //       uniqueId: userId,
  //       medium: 'facebook',
  //       loginType: CentralizeLoginType.social.name,
  //     );

  //     Get.find<AuthController>().loginWithSocialMedia(facebookBodyModel);
  //   });

  //   js.context.callMethod("facebookLogin");
  // }

  void _appleLogin() async {
    String clientID =
        Get.find<SplashController>().configModel!.appleLogin![0].clientId!;
    String redirectURL =
        Get.find<SplashController>().configModel!.appleLogin![0].redirectUrl!;

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: GetPlatform.isIOS
          ? null
          : WebAuthenticationOptions(
              clientId: clientID,
              redirectUri: Uri.parse(redirectURL),
            ),
    );

    // webAuthenticationOptions: WebAuthenticationOptions(
    //   clientId: Get.find<SplashController>().configModel.appleLogin[0].clientId,
    //   redirectUri: Uri.parse('https://6ammart-web.6amtech.com/apple'),
    // ),

    SocialLogInBody appleBodyModel = SocialLogInBody(
      email: credential.email,
      token: credential.authorizationCode,
      uniqueId: credential.authorizationCode,
      medium: 'apple',
      loginType: CentralizeLoginType.social.name,
      platform: GetPlatform.isIOS ? 'flutter_app' : 'flutter_web',
    );

    Get.find<AuthController>()
        .loginWithSocialMedia(appleBodyModel)
        .then((response) {
      if (response.isSuccess) {
        _processSocialSuccessSetup(response, null, appleBodyModel, null);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _processSocialSuccessSetup(
      ResponseModel response,
      SocialLogInBody? googleBodyModel,
      SocialLogInBody? appleBodyModel,
      SocialLogInBody? facebookBodyModel) {
    // -----------------------------
    // 🔥 1) Firebase Login Event هنا
    // -----------------------------
    String loginMethod = googleBodyModel != null
        ? 'google'
        : appleBodyModel != null
            ? 'apple'
            : 'facebook';

    FirebaseAnalytics.instance.logLogin(loginMethod: loginMethod);

    print("🔥 Firebase Analytics: Logged login via $loginMethod");

    print('response: ${facebookBodyModel?.email}');
    String? email = googleBodyModel != null
        ? googleBodyModel.email
        : appleBodyModel != null
            ? appleBodyModel.email
            : facebookBodyModel?.email;
    if (response.isSuccess &&
        response.authResponseModel != null &&
        response.authResponseModel!.isExistUser != null) {
      if (appleBodyModel != null) {
        email = response.authResponseModel!.email;
        appleBodyModel.email = email;
      }
      if (ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.dialog(Center(
          child: ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!,
            email: email,
            loginType: CentralizeLoginType.social.name,
            socialLogInBodyModel:
                googleBodyModel ?? appleBodyModel ?? facebookBodyModel,
          ),
        ));
      } else {
        Get.bottomSheet(ExistingUserBottomSheet(
          userModel: response.authResponseModel!.isExistUser!,
          loginType: CentralizeLoginType.social.name,
          socialLogInBodyModel:
              googleBodyModel ?? appleBodyModel ?? facebookBodyModel,
          email: email,
        ));
      }
    } else if (response.isSuccess &&
        response.authResponseModel != null &&
        !response.authResponseModel!.isPersonalInfo!) {
      String? displayName = googleBodyModel != null
          ? googleBodyModel.email?.split('@')[0]
          : appleBodyModel != null
              ? appleBodyModel.email?.split('@')[0]
              : facebookBodyModel?.email?.split('@')[0];

      if (appleBodyModel != null) {
        email = response.authResponseModel!.email;
      }
      if (ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.dialog(NewUserSetupScreen(
            name: displayName ?? '',
            loginType: CentralizeLoginType.social.name,
            phone: '',
            email: email));
      } else {
        Get.toNamed(RouteHelper.getNewUserSetupScreen(
            name: displayName ?? '',
            loginType: CentralizeLoginType.social.name,
            phone: '',
            email: email));
      }
    } else {
      Get.find<LocationController>()
          .navigateToLocationScreen('sign-in', offNamed: true);
    }
  }
}
