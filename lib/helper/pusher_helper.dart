import 'dart:convert';
import 'dart:developer';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/ride_share_module/common/controllers/map_controller.dart';
import 'package:Oxygen_Mart/features/ride_share_module/common/widgets/confirmation_trip_dialog.dart';
import 'package:Oxygen_Mart/features/ride_share_module/ride_order/controllers/ride_controller.dart';
import 'package:Oxygen_Mart/features/ride_share_module/ride_order/screens/ride_order_complete_screen.dart';
import 'package:Oxygen_Mart/features/ride_share_module/ride_payment/screens/ride_payment_screen.dart';
import 'package:Oxygen_Mart/features/ride_share_module/safety_alert/controllers/safety_alert_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/features/ride_share_module/ride_location/screens/map_screen.dart';

class PusherHelper {
  static PusherChannelsClient? pusherClient;

  static Future<void> initializePusher() async {
    PusherChannelsOptions testOptions = PusherChannelsOptions.fromHost(
      host: Get.find<SplashController>().configModel?.websocketUrl ?? '192.168.1.62',
      scheme: 'ws',
      key: '6ammart',
      port: 6001,
    );

    pusherClient = PusherChannelsClient.websocket(
      options: testOptions,
      connectionErrorHandler: (exception, trace, refresh) async {
        log('=================$exception');
        refresh();
      },
    );

    pusherClient?.lifecycleStream.listen((event) {
      log('=================Pusher Event: $event');
    });

    await pusherClient?.connect();
  }

  late PublicChannel? publicChannel;

  void pusherDriverStatus({required String deliverymanId, required Function(RecordLocationBodyModel) onLocationReceived}) {
    String channel = 'dm_location_$deliverymanId';

    log('========channel is: $channel');

    publicChannel = pusherClient!.publicChannel(channel);
    publicChannel?.subscribeIfNotUnsubscribed();

    publicChannel?.bind('pusher:subscription_succeeded').listen((_) {
      log('=======Public Subscribed');
    });

    publicChannel?.bind('pusher:subscription_error').listen((error) {
      log('=======Public Subscription Failed: ${error.data}');
    });

    publicChannel?.bind(channel).listen((event) {
      log('===========pusherDriverStatus bind is: ${event.data}');
      onLocationReceived(RecordLocationBodyModel(
        latitude: jsonDecode(event.data)['latitude'],
        longitude: jsonDecode(event.data)['longitude'],
        location: jsonDecode(event.data)['location'],
      ));
    });
  }

  late PrivateChannel pusherDriverAccepted;
  late PrivateChannel driverTripStarted;
  late PrivateChannel driverTripCancelled;
  late PrivateChannel driverTripCompleted;
  late PrivateChannel driverPaymentReceived;

  void pusherRiderStatus(String tripId) {
    if (Get.find<SplashController>().pusherConnectionStatus != null || Get.find<SplashController>().pusherConnectionStatus == 'Connected') {
      pusherDriverAccepted = pusherClient!.privateChannel("private-driver-trip-accepted.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.pusherBroadcustUrl}'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods': "PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      pusherDriverAccepted.subscribeIfNotUnsubscribed();
      pusherDriverAccepted.bind("driver-trip-accepted.$tripId").listen((event) {
        print('======driver-trip-accepted');
        Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']?.toString() ?? '').then((value) {
          if (value.statusCode == 200) {
            Get.find<RideController>().updateRideCurrentState(RideState.acceptingRider);
            Get.find<RideController>().startLocationRecord();
            Get.find<RideController>().updateRideController();
            print('----pusher--current route: ${Get.currentRoute}');
            if (Get.currentRoute == '/MapScreen') {
              Get.off(() => const MapScreen(fromScreen: MapScreenType.dashboard));
            } else {
              Get.to(() => const MapScreen(fromScreen: MapScreenType.dashboard));
            }
          }
        });
      });

      driverTripStarted = pusherClient!.privateChannel("private-driver-trip-started.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.pusherBroadcustUrl}'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods': "PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      driverTripStarted.subscribeIfNotUnsubscribed();
      driverTripStarted.bind("driver-trip-started.$tripId").listen((event) {
        print('======driver-trip-started');
        Get.find<RideController>().remainingDistance(jsonDecode(event.data!)['id']?.toString() ?? '', mapBound: false);
        Get.find<RideController>().startLocationRecord();
        Get.find<RideController>().getRideDetails(jsonDecode(event.data!)['id']?.toString() ?? '');
        Get.find<RideController>().updateRideCurrentState(RideState.ongoingRide);
        Get.find<SafetyAlertController>().checkDriverNeedSafety();
        if (Get.currentRoute != '/MapScreen') {
          Get.to(() => const MapScreen(fromScreen: MapScreenType.splash));
        }
      });

      driverTripCancelled = pusherClient!.privateChannel("private-driver-trip-cancelled.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.pusherBroadcustUrl}'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods': "PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      driverTripCancelled.subscribeIfNotUnsubscribed();
      driverTripCancelled.bind("driver-trip-cancelled.$tripId").listen((event) async {
        print('======driver-trip-cancelled');
        Get.find<RideController>().getCurrentRide();
        Get.find<RideController>().stopLocationRecord();
        Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();

        if (Get.currentRoute == '/MapScreen') {
          Get.off(() => RideOrderCompleteScreen(tripId: jsonDecode(event.data!)['id']?.toString() ?? ''));
        } else {
          Get.to(() => RideOrderCompleteScreen(tripId: jsonDecode(event.data!)['id']?.toString() ?? ''));
        }
      });

      driverTripCompleted = pusherClient!.privateChannel("private-driver-trip-completed.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.pusherBroadcustUrl}'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods': "PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      driverTripCompleted.subscribeIfNotUnsubscribed();
      driverTripCompleted.bind("driver-trip-completed.$tripId").listen((event) {
        print('======driver-trip-completed');
        Get.find<SafetyAlertController>().cancelDriverNeedSafetyStream();
        Get.dialog(
          const ConfirmationTripDialog(isStartedTrip: false),
          barrierDismissible: false,
        );
        Get.find<RideController>().getFinalFare(jsonDecode(event.data!)['id']?.toString() ?? '').then((value) {
          if (value.statusCode == 200) {
            Get.find<RideController>().updateRideCurrentState(RideState.completeRide);
            Get.find<MapController>().notifyMapController();
            Get.back();
            Get.off(() => RidePaymentScreen(rideId: jsonDecode(event.data!)['id']?.toString() ?? ''));
          }
        });
      });

      driverPaymentReceived = pusherClient!.privateChannel("private-driver-payment-received.$tripId", authorizationDelegate:
      EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${AppConstants.baseUrl}${AppConstants.pusherBroadcustUrl}'),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${Get.find<AuthController>().getUserToken()}",
          "Access-Control-Allow-Origin": "*",
          'Access-Control-Allow-Methods': "PUT, GET, POST, DELETE, OPTIONS"
        },
      ));

      driverPaymentReceived.subscribeIfNotUnsubscribed();
      driverPaymentReceived.bind("driver-payment-received.$tripId").listen((event) {
        if (Get.find<SplashController>().configModel!.reviewStatus ?? false) {
          if (jsonDecode(event.data!)['type'] == 'ride_request' && Get.find<SplashController>().configModel!.reviewStatus!) {
            Get.off(() => RidePaymentScreen(rideId: jsonDecode(event.data!)['id']?.toString() ?? ''));
          }
          Get.find<RideController>().tripDetails = null;
        } else {
          Get.offAll(() => RideOrderCompleteScreen(tripId: jsonDecode(event.data!)['id']?.toString() ?? ''));
          Get.find<RideController>().tripDetails = null;
        }
      });
    }
  }

  void pusherDisconnectPusher() {
    publicChannel?.unsubscribe();
    pusherClient?.disconnect();
  }
}

class RecordLocationBodyModel {
  String? latitude;
  String? longitude;
  String? location;

  RecordLocationBodyModel({this.latitude, this.longitude, this.location});
}
