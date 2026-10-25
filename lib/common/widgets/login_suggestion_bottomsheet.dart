import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
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

    final bool socialLoginStatus = centralizeLogin?.socialLoginStatus ?? true;

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

    final bool googleLoginActive = googleSocialStatus && socialLoginStatus && (centralizeLogin?.googleLoginStatus ?? true);
    final bool facebookLoginActive = facebookSocialStatus && socialLoginStatus && (centralizeLogin?.facebookLoginStatus ?? true);

    final bool canAppleLogin = (configModel?.appleLogin?.isNotEmpty ?? false) && (configModel?.appleLogin?[0].status ?? false) && !GetPlatform.isAndroid;
    final bool appleLoginActive = canAppleLogin && socialLoginStatus && (centralizeLogin?.appleLoginStatus ?? false);

    final bool isOtpActive = centralizeLogin?.otpLoginStatus ?? true;
    final bool isManualLoginActive = centralizeLogin?.manualLoginStatus ?? true;
    final bool hasSocialLogin = googleLoginActive || facebookLoginActive || appleLoginActive;

    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color cardColor = theme.cardColor;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: isDesktop ? 480 : context.width,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(28),
          bottom: Radius.circular(isDesktop ? 28 : 0),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _SheetHeaderBar(
                  onClose: () => Get.back(),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                _BrandHeroBadge(
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                _HeaderSection(
                  fromCartPage: fromCartPage,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                if (hasSocialLogin) ...<Widget>[
                  _SectionLabel(
                    title: 'continue_with'.tr.toCapitalized(),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  _SocialLoginRow(
                    googleActive: googleLoginActive,
                    facebookActive: facebookLoginActive,
                    appleActive: appleLoginActive,
                    onGoogleTap: () {
                      Get.back();
                      _googleLogin(googleSignIn);
                    },
                    onFacebookTap: () {
                      Get.back();
                      _facebookLogin();
                    },
                    onAppleTap: () {
                      Get.back();
                      _appleLogin();
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  const _StyledOrDivider(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                if (isOtpActive)
                  _PrimaryAuthButton(
                    title: 'login_with_otp'.tr,
                    icon: Icons.sms_outlined,
                    isPrimary: true,
                    onTap: () async {
                      Get.back();
                      Get.find<AuthController>().enableOtpView(enable: true);
                      await _openSignInScreen();
                    },
                  ),

                if (isOtpActive && isManualLoginActive)
                  const SizedBox(height: Dimensions.paddingSizeSmall + 2),

                if (isManualLoginActive)
                  _PrimaryAuthButton(
                    title: 'login_with_password'.tr,
                    icon: Icons.lock_outline_rounded,
                    isPrimary: !isOtpActive,
                    onTap: () async {
                      Get.back(result: true);
                      await _openSignInScreen();
                    },
                  ),

                const SizedBox(height: Dimensions.paddingSizeDefault),

                _GuestContinueButton(
                  onTap: () => Get.back(),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                const _TermsAndPrivacyFooter(),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              ],
            ),
          ),
        ),
      ),
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

      SocialLogInBody googleBodyModel = SocialLogInBody(
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
    LoginResult result = await FacebookAuth.instance.login(permissions: <String>["public_profile", "email"]);
    if (result.status == LoginStatus.success) {
      Map<dynamic, dynamic> userData = await FacebookAuth.instance.getUserData();

      SocialLogInBody facebookBodyModel = SocialLogInBody(
        email: userData['email']?.toString(),
        token: result.accessToken!.tokenString,
        uniqueId: userData['id']?.toString(),
        medium: 'facebook',
        loginType: CentralizeLoginType.social.name,
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
      scopes: <AppleIDAuthorizationScopes>[
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: GetPlatform.isIOS ? null : WebAuthenticationOptions(
        clientId: clientID,
        redirectUri: Uri.parse(redirectURL),
      ),
    );

    SocialLogInBody appleBodyModel = SocialLogInBody(
      email: credential.email,
      token: credential.authorizationCode,
      uniqueId: credential.authorizationCode,
      medium: 'apple',
      loginType: CentralizeLoginType.social.name,
      platform: GetPlatform.isIOS ? 'flutter_app' : 'flutter_web',
    );

    Get.find<AuthController>().loginWithSocialMedia(appleBodyModel, alreadyInApp: true).then((response) {
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
    SocialLogInBody? facebookBodyModel,
  ) {
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
    }
  }
}

class _SheetHeaderBar extends StatelessWidget {
  final VoidCallback onClose;

  const _SheetHeaderBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: theme.disabledColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Material(
              color: theme.disabledColor.withValues(alpha: 0.12),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onClose,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeroBadge extends StatelessWidget {
  final Color primaryColor;

  const _BrandHeroBadge({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            primaryColor.withValues(alpha: 0.22),
            primaryColor.withValues(alpha: 0.04),
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Image.asset(
            Images.logo,
            height: 38,
            width: 38,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.shopping_bag_outlined,
              color: primaryColor,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool fromCartPage;

  const _HeaderSection({this.fromCartPage = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Text(
          fromCartPage ? 'create_account'.tr : 'welcome_back'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeOverLarge,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall + 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Text(
            fromCartPage
                ? 'login_or_signup_to_view_and_track_your_orders'.tr
                : 'to_get_more_personalised_experience'.tr,
            style: robotoRegular.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
              fontSize: Dimensions.fontSizeSmall,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: robotoMedium.copyWith(
        fontSize: Dimensions.fontSizeSmall,
        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
      ),
    );
  }
}

class _SocialLoginRow extends StatelessWidget {
  final bool googleActive;
  final bool facebookActive;
  final bool appleActive;
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;
  final VoidCallback onAppleTap;

  const _SocialLoginRow({
    required this.googleActive, required this.facebookActive, required this.appleActive,
    required this.onGoogleTap, required this.onFacebookTap, required this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (googleActive)
          Expanded(
            child: _SocialIconButton(
              iconPath: Images.google,
              label: 'Google',
              onTap: onGoogleTap,
            ),
          ),
        if (googleActive && (facebookActive || appleActive))
          const SizedBox(width: Dimensions.paddingSizeSmall),
        if (facebookActive)
          Expanded(
            child: _SocialIconButton(
              iconPath: Images.facebook2,
              label: 'Facebook',
              onTap: onFacebookTap,
            ),
          ),
        if (facebookActive && appleActive)
          const SizedBox(width: Dimensions.paddingSizeSmall),
        if (appleActive)
          Expanded(
            child: _SocialIconButton(
              iconPath: Images.appleLogo,
              label: 'Apple',
              onTap: onAppleTap,
            ),
          ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _SocialIconButton({
    required this.iconPath, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return CustomInkWell(
      onTap: onTap,
      radius: 14,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.disabledColor.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }
}

class _StyledOrDivider extends StatelessWidget {
  const _StyledOrDivider();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  theme.disabledColor.withValues(alpha: 0.02),
                  theme.disabledColor.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
            decoration: BoxDecoration(
              color: theme.disabledColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
            child: Text(
              'or'.tr.toUpperCase(),
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: theme.disabledColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  theme.disabledColor.withValues(alpha: 0.22),
                  theme.disabledColor.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PrimaryAuthButton({
    required this.title, required this.icon, required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.primaryColor;

    return CustomInkWell(
      onTap: onTap,
      radius: 16,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary
              ? LinearGradient(
                  colors: <Color>[
                    primary,
                    theme.secondaryHeaderColor,
                  ],
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                )
              : null,
          color: isPrimary ? null : theme.cardColor,
          border: isPrimary
              ? null
              : Border.all(
                  color: theme.disabledColor.withValues(alpha: 0.25),
                  width: 1.2,
                ),
          boxShadow: isPrimary
              ? <BoxShadow>[
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.85),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                title,
                style: robotoBold.copyWith(
                  color: isPrimary ? Colors.white : theme.textTheme.bodyLarge?.color,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GuestContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return CustomInkWell(
      onTap: onTap,
      radius: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          color: theme.disabledColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'continue_as_guest'.tr,
              style: robotoMedium.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                fontSize: Dimensions.fontSizeSmall + 1,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsAndPrivacyFooter extends StatelessWidget {
  const _TermsAndPrivacyFooter();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.55) ?? Colors.grey;
    final Color linkColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall + 1,
            color: textColor,
            height: 1.4,
          ),
          children: <InlineSpan>[
            TextSpan(
              text: 'by_continuing_you_agree_to_our'.tr,
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'terms_and_conditions'.tr,
              style: robotoMedium.copyWith(
                color: linkColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'and'.tr,
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: 'privacy_policy'.tr,
              style: robotoMedium.copyWith(
                color: linkColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
            ),
          ],
        ),
      ),
    );
  }
}

// Backward compatibility if any other feature imports SocialLoginButton
class SocialLoginButton extends StatelessWidget {
  final String? label;
  final String iconPath;
  final VoidCallback onTap;

  const SocialLoginButton({super.key,
    this.label, required this.iconPath, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SocialIconButton(
      iconPath: iconPath,
      label: label ?? '',
      onTap: onTap,
    );
  }
}