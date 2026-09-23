import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:Oxygen_Mart/features/auth/domain/models/social_log_in_body.dart';
import 'package:Oxygen_Mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:Oxygen_Mart/features/auth/widgets/sign_in/existing_user_bottom_sheet.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/helper/string_extension.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
class LoginSuggestionBottomSheet extends StatelessWidget {
  final bool fromCartPage;
  const LoginSuggestionBottomSheet({super.key, this.fromCartPage = false});

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    final configModel = Get.find<SplashController>().configModel;
    final centralizeLogin = configModel?.centralizeLoginSetup;

    bool socialLoginStatus = centralizeLogin?.socialLoginStatus ?? true;

    bool googleSocialStatus = true;
    bool facebookSocialStatus = true;

    if (configModel?.socialLogin != null && configModel!.socialLogin!.isNotEmpty) {
      for (var social in configModel.socialLogin!) {
        if (social.loginMedium == 'google') {
          googleSocialStatus = social.status ?? true;
        } else if (social.loginMedium == 'facebook') {
          facebookSocialStatus = social.status ?? true;
        }
      }
    }

    bool googleLoginActive = googleSocialStatus && socialLoginStatus && (centralizeLogin?.googleLoginStatus ?? true);
    bool facebookLoginActive = facebookSocialStatus && socialLoginStatus && (centralizeLogin?.facebookLoginStatus ?? true);

    bool canAppleLogin = (configModel?.appleLogin?.isNotEmpty ?? false) && (configModel?.appleLogin?[0].status ?? false) && !GetPlatform.isAndroid;
    bool appleLoginActive = canAppleLogin && socialLoginStatus && (centralizeLogin?.appleLoginStatus ?? false);

    bool isOtpActive = centralizeLogin?.otpLoginStatus ?? true;
    bool isManualloginActive = centralizeLogin?.manualLoginStatus ?? true;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radiusLarge),
          topRight: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Stack( children: [
          Column(mainAxisSize: MainAxisSize.min,  children: <Widget>[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtremeLarge),
              child: Column(children: [
                Text(
                  fromCartPage ? 'create_account'.tr : 'welcome_back'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  fromCartPage ? 'login_or_signup_to_view_and_track_your_orders'.tr : "to_get_more_personalised_experience".tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5), fontSize: Dimensions.fontSizeSmall),
                  textAlign: TextAlign.center,
                ),
                if(facebookLoginActive || googleLoginActive || appleLoginActive) const SizedBox(height: Dimensions.paddingSizeExtremeLarge),
                if(facebookLoginActive || googleLoginActive || appleLoginActive)
                  Text( "continue_with".tr.toCapitalized(), style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                  Row(spacing: 8, children: <Widget>[
                    if(facebookLoginActive)
                      Expanded(child: SocialLoginButton(
                        iconPath: Images.facebook2,
                        onTap: () {
                          Get.back();
                          _facebookLogin();
                        },
                      )),

                    if(googleLoginActive)
                      Expanded(child: SocialLoginButton(
                        iconPath: Images.google,
                        onTap: () {
                          Get.back();
                          _googleLogin(googleSignIn);
                        },
                      )),

                    if(appleLoginActive)
                      Expanded(child: SocialLoginButton(
                        iconPath: Images.appleLogo,
                        onTap: () {
                          Get.back();
                          _appleLogin();
                        },
                      )),
                  ]),
                
                if(facebookLoginActive || googleLoginActive || appleLoginActive) const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                if(facebookLoginActive || googleLoginActive || appleLoginActive) Row(children: [
                  const Expanded(child: Divider()),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text("or".tr.toUpperCase(), style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  const Expanded(child: Divider()),
                ]),
                if(facebookLoginActive || googleLoginActive || appleLoginActive) const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                if (isManualloginActive) CustomButton(
                  height: 50, buttonText: 'login_with_password'.tr,
                  onPressed: () async {
                    Get.back(result: true);
                    await _openSignInScreen();
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                if(isOtpActive)
                  CustomButton(
                    height: 50, buttonText: 'login_with_otp'.tr,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () async {
                      Get.back();
                      Get.find<AuthController>().enableOtpView(enable: true);
                      await _openSignInScreen();
                    },
                  ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                InkWell(
                  onTap: () =>Get.back(),
                  child: Text("continue_as_guest".tr, style: robotoMedium.copyWith(color: Colors.blueAccent, fontSize: Dimensions.fontSizeLarge))
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: RichText(textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'by_continuing_you_agree_to_our'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'terms_and_conditions'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'and'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: 'privacy_policy'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.blueAccent,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

              ]),
            ),

          ]),
          Align(alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).disabledColor),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ]),
      ]),
    );
  }

  Future<void> _openSignInScreen() async {
    await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
  }

  void _googleLogin(GoogleSignIn googleSignIn) async {
    if (kIsWeb) {
      await _googleWebSignIn();
    } else {
      try {
        if (googleSignIn.supportsAuthenticate()) {
          await googleSignIn
              .initialize(serverClientId: AppConstants.googleServerClientId)
              .then((_) async {
            googleSignIn.signOut();
            GoogleSignInAccount googleAccount =
                await googleSignIn.authenticate();
            const List<String> scopes = <String>['email'];
            GoogleSignInClientAuthorization? auth = await googleAccount
                .authorizationClient
                .authorizationForScopes(scopes);

            SocialLogInBody googleBodyModel = SocialLogInBody(
              email: googleAccount.email,
              token: auth?.accessToken,
              uniqueId: googleAccount.id,
              medium: 'google',
              accessToken: 1,
              loginType: CentralizeLoginType.social.name,
            );

            Get.find<AuthController>()
                .loginWithSocialMedia(googleBodyModel, alreadyInApp: true)
                .then((response) {
              if (response.isSuccess) {
                _processSocialSuccessSetup(
                    response, googleBodyModel, null, null);
              } else {
                showCustomSnackBar(response.message);
              }
            });
          });
        } else {
          debugPrint("Google Sign-In not supported on this device.");
        }
      } catch (e) {
        debugPrint('Error in google sign in: $e');
      }
    }
  }

  Future<void> _googleWebSignIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential = await auth.signInWithPopup(googleProvider);

      SocialLogInBody googleBodyModel =  SocialLogInBody(
        uniqueId: userCredential.credential?.accessToken,
        token: userCredential.credential?.accessToken,
        accessToken: 1,
        medium: 'google',
        email: userCredential.user?.email,
        loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(googleBodyModel, alreadyInApp: true).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, googleBodyModel, null, null);
        } else {
          showCustomSnackBar(response.message);
        }
      });

    } catch (e) {
      showCustomSnackBar(e.toString());
    }
  }

  void _facebookLogin() async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ["public_profile", "email"]);
    if (result.status == LoginStatus.success) {
      Map userData = await FacebookAuth.instance.getUserData();

      SocialLogInBody facebookBodyModel = SocialLogInBody(
        email: userData['email'], token: result.accessToken!.tokenString, uniqueId: userData['id'],
        medium: 'facebook', loginType: CentralizeLoginType.social.name,
      );

      Get.find<AuthController>().loginWithSocialMedia(facebookBodyModel, alreadyInApp: true).then((response) {
        if (response.isSuccess) {
          _processSocialSuccessSetup(response, null, null, facebookBodyModel);
        } else {
          showCustomSnackBar(response.message);
        }
      });
    }
  }

  void _appleLogin() async {
    String clientID = Get.find<SplashController>().configModel!.appleLogin![0].clientId!;
    String redirectURL = Get.find<SplashController>().configModel!.appleLogin![0].redirectUrl!;

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: GetPlatform.isIOS ? null : WebAuthenticationOptions(
        clientId: clientID,
        redirectUri: Uri.parse(redirectURL),
      ),
    );

    SocialLogInBody appleBodyModel = SocialLogInBody(
      email: credential.email, token: credential.authorizationCode, uniqueId: credential.authorizationCode,
      medium: 'apple', loginType: CentralizeLoginType.social.name, platform: GetPlatform.isIOS ? 'flutter_app' : 'flutter_web',
    );

    Get.find<AuthController>().loginWithSocialMedia(appleBodyModel, alreadyInApp: true).then((response) {
      if (response.isSuccess) {
        _processSocialSuccessSetup(response, null, appleBodyModel, null);
      } else {
        showCustomSnackBar(response.message);
      }
    });
  }

  void _processSocialSuccessSetup(ResponseModel response, SocialLogInBody? googleBodyModel, SocialLogInBody? appleBodyModel, SocialLogInBody? facebookBodyModel) {
    String? email = googleBodyModel != null ? googleBodyModel.email : appleBodyModel != null ? appleBodyModel.email : facebookBodyModel?.email;
    if(response.isSuccess && response.authResponseModel != null && response.authResponseModel!.isExistUser != null) {
      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
        appleBodyModel.email = email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)) {
        Get.back();
        Get.dialog(Center(
          child: ExistingUserBottomSheet(
            userModel: response.authResponseModel!.isExistUser!, email: email, loginType: CentralizeLoginType.social.name,
            socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel, backFromThis: true,
          ),
        ));
      } else {
        Get.bottomSheet(ExistingUserBottomSheet(
          userModel: response.authResponseModel!.isExistUser!, loginType: CentralizeLoginType.social.name,
          socialLogInBodyModel: googleBodyModel ?? appleBodyModel ?? facebookBodyModel, email: email, backFromThis: true,
        ));
      }
    } else if(response.isSuccess && response.authResponseModel != null && response.authResponseModel!.requiresProfileCompletion) {

      String? displayName = googleBodyModel != null ? googleBodyModel.email?.split('@')[0] : appleBodyModel != null ? appleBodyModel.email?.split('@')[0] : facebookBodyModel?.email?.split('@')[0];

      if(appleBodyModel != null) {
        email = response.authResponseModel!.email;
      }
      if(ResponsiveHelper.isDesktop(Get.context)){
        Get.back();
        Get.dialog(NewUserSetupScreen(name: displayName ?? '', loginType: CentralizeLoginType.social.name, phone: '', email: email, backFromThis: true));
      } else {
        Get.toNamed(RouteHelper.getNewUserSetupScreen(name: displayName ?? '', loginType: CentralizeLoginType.social.name, phone: '', email: email, backFromThis: true));
      }
    } else {
      Get.find<LocationController>().syncZoneData();
      // Get.back();
      // Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
    }
  }
}

class SocialLoginButton extends StatelessWidget {
  final String? label;
  final String iconPath;
  final VoidCallback onTap;

  const SocialLoginButton({
    super.key, this.label,
    required this.iconPath, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onTap,
      radius: Dimensions.radiusDefault,
      child: Container(
        height: 50, width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: label != null ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Theme.of(context).disabledColor.withValues(alpha: 0.2)),
          color: label != null ? Theme.of(context).disabledColor.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Image.asset(iconPath, height: 24, width: 24),
            label != null ? const SizedBox(width: 2) : const SizedBox.shrink(),

            label != null ? Text(label ?? '', style: robotoBold) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}