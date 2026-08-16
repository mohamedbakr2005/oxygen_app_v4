import 'dart:io';  // For platform detection
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class AppsFlyerService {
  static final AppsFlyerService _instance = AppsFlyerService._internal();

  factory AppsFlyerService() {
    return _instance;
  }

  late AppsflyerSdk _appsFlyerSdk;
  Map? _deepLinkData;

  AppsFlyerService._internal();  // Private constructor

  Future<void> initAppsFlyer() async {
    print("Initializing AppsFlyer...");
    try {
      final AppsFlyerOptions options = AppsFlyerOptions(
        afDevKey: 'NnneRqTKYNoAbYp6XvV7NT',   // Replace with your actual Dev Key
        appId: '6736767925' ,  // iOS App ID only for iOS
        showDebug: true,   // Enable debug logs
        timeToWaitForATTUserAuthorization: Platform.isIOS ? 15 : null,  // iOS privacy prompt
      );

      _appsFlyerSdk = AppsflyerSdk(options);

      _appsFlyerSdk.onAppOpenAttribution((res) {
        print("onAppOpenAttribution: ${res.toString()}");
      });

      _appsFlyerSdk.onInstallConversionData((res) {
        print("onInstallConversionData: ${res.toString()}");
      });

      _appsFlyerSdk.onDeepLinking((DeepLinkResult dp) {
        switch (dp.status) {
          case Status.FOUND:
            print("Deep link found: ${dp.deepLink?.toString()}");
            // _deepLinkData = dp.deepLink;
            break;
          case Status.NOT_FOUND:
            print("Deep link not found");
            break;
          case Status.ERROR:
            print("Deep link error: ${dp.error}");
            break;
          case Status.PARSE_ERROR:
            print("Deep link parse error");
            break;
        }
      });

      await _appsFlyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );

      print("AppsFlyer Initialized Successfully!");
    } catch (e) {
      print("Error initializing AppsFlyer: $e");
    }
  }

  void logEvent(String eventName, Map<String, dynamic> parameters) async {
    try {
      await _appsFlyerSdk.logEvent(eventName, parameters);
      print("Event '$eventName' logged with parameters: $parameters");
    } catch (e) {
      print("Failed to log event $eventName: $e");
    }
  }

  Map? getDeepLinkData() {
    return _deepLinkData;
  }
}
