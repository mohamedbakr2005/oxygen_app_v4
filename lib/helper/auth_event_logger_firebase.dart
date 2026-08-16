import 'package:firebase_analytics/firebase_analytics.dart';

class AuthEventLogger {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> login({
    required String method,
    String? fieldType,
    String? value,
  }) async {
    await _analytics.logEvent(
      name: 'login',
      parameters: {
        'method': method,
        'field_type': fieldType!,
        'value': value!,
      },
    );
  }

  static Future<void> signup({
    String? email,
    String? phone,
  }) async {
    await _analytics.logEvent(
      name: 'signup',
      parameters: {
        'email': email!,
        'phone': phone!,
      },
    );
  }

  static Future<void> logout() async {
    await _analytics.logEvent(
      name: 'logout',
    );
  }

  static Future<void> forgotPassword(String phone) async {
    await _analytics.logEvent(
      name: 'forgot_password',
      parameters: {
        'phone': phone,
      },
    );
  }


  static Future<void> resetPassword(String phone) async {
    await _analytics.logEvent(
      name: 'reset_password',
      parameters: {
        'phone': phone,
      },
    );
  }

  static Future<void> changePassword(String userId) async {
    await _analytics.logEvent(
      name: 'change_password',
      parameters: {
        'user_id': userId,
      },
    );
  }

  static Future<void> otpVerification({
    required String phone,
    required String verified,
  }) async {
    await _analytics.logEvent(
      name: 'otp_verification',
      parameters: {
        'phone': phone,
        'verified': verified,
      },
    );
  }

  static Future<void> socialLogin(String method, {String? email}) async {
    // default Firebase login event
    await _analytics.logLogin(loginMethod: method);

    // custom event
    await _analytics.logEvent(
      name: '${method}_login',
      parameters: {
        'email': email!,
      },
    );
  }
}
