import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:Oxygen_Mart/features/auth/domain/models/social_log_in_body.dart';

class FacebookLoginHelper {

  static Future<void> login({required Function(ResponseModel response, SocialLogInBody facebookBodyModel) onSuccess}) async {
    // On iOS 17+ the Facebook SDK only issues a classic (Graph API) token when tracking is authorized,
    // otherwise it falls back to Limited Login and returns an OIDC JWT instead.
    await _requestTrackingAuthorization();

    LoginResult result = await FacebookAuth.instance.login(
      permissions: ["public_profile", "email"],
      loginTracking: LoginTracking.enabled,
    );
    if (result.status != LoginStatus.success || result.accessToken == null) {
      return;
    }

    Map userData = await FacebookAuth.instance.getUserData();

    SocialLogInBody facebookBodyModel = SocialLogInBody(
      email: userData['email'], token: result.accessToken!.tokenString, uniqueId: userData['id'],
      medium: 'facebook', loginType: CentralizeLoginType.social.name,
    );

    ResponseModel response = await Get.find<AuthController>().loginWithSocialMedia(facebookBodyModel);
    if (response.isSuccess) {
      onSuccess(response, facebookBodyModel);
    } else if (result.accessToken is LimitedToken) {
      // The backend verifies the token through the Graph API, which rejects Limited Login JWTs.
      await FacebookAuth.instance.logOut();
      showCustomSnackBar('facebook_login_could_not_be_completed'.tr);
    } else {
      showCustomSnackBar(response.message);
    }
  }

  static Future<void> _requestTrackingAuthorization() async {
    if (GetPlatform.isWeb || !GetPlatform.isIOS) {
      return;
    }

    try {
      await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (e) {
      debugPrint('Tracking authorization request failed: $e');
    }
  }
}
