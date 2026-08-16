import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class SocketService {
  static PusherChannelsClient? client;
  static StreamSubscription? eventSubscription;
  static PublicChannel? channel;

  static Future<void> connect({
    required int userId,
    required Function(dynamic data) onCartUpdate,
  }) async {
    try {
      print("🚀 Connecting to Laravel WebSockets for user: $userId");

      PusherChannelsPackageLogger.enableLogs();

      final options = PusherChannelsOptions.fromHost(
        scheme: 'ws',
        host: 'oxygenmart.online',
        key: 'f58dc52f0c9e3b137796',
        port: 6001,
      );

      client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) async {
          print("❌ Socket Error: $exception");
          refresh();
        },
      );

      channel = client!.publicChannel("cart.$userId");

      eventSubscription =
          channel!.bind("cart.updated").listen((ChannelReadEvent event) {
        print("📩 CART EVENT RECEIVED");
        print("📦 DATA: ${event.data}");

        try {
          final decoded = jsonDecode(event.data);
          onCartUpdate(decoded);
        } catch (e) {
          print("❌ JSON Decode Error: $e");
        }
      });

      client!.onConnectionEstablished.listen((_) {
        print("✅ WebSocket Connected Successfully");
        channel!.subscribeIfNotUnsubscribed();
      });

      await client!.connect();

      print("📡 Subscribed to cart.$userId");
    } catch (e) {
      print("Socket Connection Error: $e");
    }
  }

  static Future<void> disconnect() async {
    await eventSubscription?.cancel();
    channel?.unsubscribe();
    client?.dispose();

    print("🔌 Socket Disconnected");
  }
}
