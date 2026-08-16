import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/cookies_view.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/notification/controllers/notification_controller.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/firebase_options.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/deep_link_service.dart';
import 'package:Oxygen_Mart/helper/notification_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/theme/dark_theme.dart';
import 'package:Oxygen_Mart/theme/light_theme.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/messages.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:appsflyer_sdk/appsflyer_sdk.dart' as dd;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';

import 'helper/get_di.dart' as di;

Future<void> requestTrackingPermission() async {
  final status = await AppTrackingTransparency.requestTrackingAuthorization();
  print("Tracking permission status: $status");
}
//400a5bac09464a8d238d5ea4e8e6aa03

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// void checkPageSize() {
//   Process.run("getconf", ["PAGE_SIZE"]).then((result) {
//     print(
//         "📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌📌 PAGE SIZE = ${result.stdout}");
//   });
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. إعدادات سريعة جداً (Synchronous) مش بتعطل الأبلكيشن
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();

  // 2. تشغيل الـ SDKs الغير حرجة في الخلفية (بدون await عشان مانوقفش الـ runApp)
  // _initializeNonCriticalSDKs() moved after di.init()

  // 🚨 تم إزالة SharedPreferences.getInstance() من هنا لأنها موجودة داخل di.init()

  // 3. تهيئة الأساسيات (Firebase والـ Dependency Injection)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // بنحمل اللغات والكنترولرز
  Map<String, Map<String, String>> languages = await di.init();

  // 2. تشغيل الـ SDKs الغير حرجة في الخلفية
  await _initializeNonCriticalSDKs();

  // 4. معالجة الإشعارات (لازم نستنى الفايربيز يخلص الأول)
  NotificationBodyModel? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
        if (remoteMessage.data.containsKey('notification_id') &&
            AuthHelper.isLoggedIn()) {
          final notificationId =
              int.tryParse(remoteMessage.data['notification_id'].toString());
          if (notificationId != null) {
            Get.find<NotificationController>()
                .trackNotification(notificationId, 'opened');
          }
        }
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  } catch (e) {
    print("Notification Init Error: $e");
  }

  // 5. تتبع الكراشات
  FlutterError.onError = (FlutterErrorDetails details) async {
    FirebaseAnalytics.instance.logEvent(name: 'app_crashed', parameters: {
      "exception": details.exception.toString(),
    });
    print("🔥 Crash logged");
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseAnalytics.instance.logEvent(name: 'app_crashed', parameters: {
      "exception": error.toString(),
    });
    print("🔥 Uncaught crash logged");
    return true;
  };

  // 6. انطلاق! 🚀
  runApp(MyApp(languages: languages, body: body));
}

// دالة منفصلة لتشغيل الخدمات في الخلفية بدون ما نوقف الـ UI
Future<void> _initializeNonCriticalSDKs() async {
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    final metaAnalyticsService = Get.find<MetaAnalyticsService>();
    await metaAnalyticsService.activateApp();
    print("Graph API initialized via MetaAnalyticsService");
  }

  if (ResponsiveHelper.isWeb()) {
    FacebookAuth.instance.webAndDesktopInitialize(
      appId: "979309183657297",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    unawaited(Get.find<DeepLinkService>().init());
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      FirebaseAnalytics.instance.logEvent(
        name: 'notification_opened',
        parameters: {
          "notification_id": message.messageId.toString(),
          "title": message.notification!.title.toString(),
        },
      );

      print("🔥 notification_opened logged");

      NotificationHelper.convertNotification(message.data);
      RouteHelper.getNotificationRoute();
    });
    _route();
  }

  void _route() async {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if (AddressHelper.getUserAddressFromSharedPref() != null &&
          AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }

      if (!AuthHelper.isLoggedIn() &&
          !AuthHelper
              .isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/) {
        await Get.find<AuthController>().guestLogin();
      }

      if ((AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) &&
          Get.find<SplashController>().cacheModule != null) {
        Get.find<CartController>().getCartDataOnline();
      }

      Get.find<SplashController>().getConfigData(
        loadLandingData: (GetPlatform.isWeb &&
            AddressHelper.getUserAddressFromSharedPref() == null),
        fromMainFunction: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                return (GetPlatform.isWeb &&
                        splashController.configModel == null)
                    ? const SizedBox()
                    : GetMaterialApp(
                        title: AppConstants.appName,
                        debugShowCheckedModeBanner: false,
                        navigatorKey: Get.key,
                        scrollBehavior: const MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.touch,
                          },
                        ),
                        theme: themeController.darkTheme ? dark() : light(),
                        locale: localizeController.locale,
                        translations: Messages(languages: widget.languages),
                        fallbackLocale: Locale(
                          AppConstants.languages[0].languageCode!,
                          AppConstants.languages[0].countryCode,
                        ),
                        initialRoute: GetPlatform.isWeb
                            ? RouteHelper.getInitialRoute()
                            : RouteHelper.getSplashRoute(widget.body),
                        getPages: RouteHelper.routes,
                        defaultTransition: Transition.cupertino,
                        transitionDuration: const Duration(milliseconds: 10),
                        builder: (BuildContext context, widget) {
                          return MediaQuery(
                            data: MediaQuery.of(
                              context,
                            ).copyWith(textScaler: const TextScaler.linear(1)),
                            child: Material(
                              child: Stack(
                                children: [
                                  widget!,
                                  GetBuilder<SplashController>(
                                    builder: (splashController) {
                                      if (!splashController.savedCookiesData &&
                                          !splashController
                                              .getAcceptCookiesStatus(
                                            splashController.configModel != null
                                                ? splashController
                                                    .configModel!.cookiesText!
                                                : '',
                                          )) {
                                        return ResponsiveHelper.isWeb()
                                            ? const Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: CookiesView(),
                                              )
                                            : const SizedBox();
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// a@eLk:Rq#LUvB8?CBx6N
//  git pull --rebase origin main
// >> git push origin main
