import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LiveNavigationService {
  static const String _androidMapsApiKey =
      'AIzaSyBCwMrQgkGIiyCTcfG5Km4ftRcC5I53yao';
  static const String _iosMapsApiKey =
      'AIzaSyBaO33dNm_8AyDJFNUN0DD8OngFW2jsUDs';
  static const String _webMapsApiKey =
      'AIzaSyAJIVT_uevhZlMvh8NAgsuQYVJz6iRwa90';

  String get _apiKey {
    if (kIsWeb) {
      return _webMapsApiKey;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _iosMapsApiKey;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return _androidMapsApiKey;
    }
  }

  Future<LatLng?> snapToRoad(LatLng point) async {
    try {
      final Uri uri = Uri.https('roads.googleapis.com', '/v1/nearestRoads', {
        'points': '${point.latitude},${point.longitude}',
        'key': _apiKey,
      });
      final http.Response response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic>? snappedPoints = data['snappedPoints'] as List?;
      if (snappedPoints == null || snappedPoints.isEmpty) {
        return null;
      }

      final Map<String, dynamic>? location =
          snappedPoints.first['location'] as Map<String, dynamic>?;
      if (location == null) {
        return null;
      }

      return LatLng(
        (location['latitude'] as num).toDouble(),
        (location['longitude'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<NavigationRoute?> fetchRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'departure_time': 'now',
          'traffic_model': 'best_guess',
          'alternatives': 'false',
          'language': Get.locale?.languageCode ?? 'en',
          'key': _apiKey,
        },
      );

      final http.Response response = await http.get(uri);
      if (response.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        return null;
      }

      final List<dynamic>? routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return null;
      }

      final Map<String, dynamic> routeJson =
          routes.first as Map<String, dynamic>;
      final List<dynamic>? legs = routeJson['legs'] as List?;
      if (legs == null || legs.isEmpty) {
        return null;
      }

      final Map<String, dynamic> legJson = legs.first as Map<String, dynamic>;
      final List<dynamic> stepJsonList =
          (legJson['steps'] as List?) ?? <dynamic>[];
      final List<NavigationStep> steps = stepJsonList
          .map((dynamic step) =>
              NavigationStep.fromJson(step as Map<String, dynamic>))
          .toList();

      final List<LatLng> detailedPoints = _buildDetailedRoutePoints(
        origin: origin,
        destination: destination,
        steps: steps,
      );

      return NavigationRoute(
        points: detailedPoints,
        bounds: _parseBounds(routeJson['bounds'] as Map<String, dynamic>?),
        steps: steps,
        summary: routeJson['summary']?.toString(),
        distanceMeters:
            ((legJson['distance'] as Map?)?['value'] as num?)?.toDouble() ??
                0,
        durationSeconds: (((legJson['duration_in_traffic'] as Map?)?['value'] ??
                    (legJson['duration'] as Map?)?['value']) as num?)
                ?.toDouble() ??
            0,
      );
    } catch (_) {
      return null;
    }
  }

  List<LatLng> _buildDetailedRoutePoints({
    required LatLng origin,
    required LatLng destination,
    required List<NavigationStep> steps,
  }) {
    final List<LatLng> points = <LatLng>[origin];
    for (final NavigationStep step in steps) {
      if (step.points.isEmpty) {
        points.add(step.endLocation);
      } else {
        points.addAll(step.points);
      }
    }
    points.add(destination);
    return _dedupeConsecutivePoints(points);
  }

  static List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  static LatLngBounds? _parseBounds(Map<String, dynamic>? boundsJson) {
    if (boundsJson == null) {
      return null;
    }

    final Map<String, dynamic>? northEast =
        boundsJson['northeast'] as Map<String, dynamic>?;
    final Map<String, dynamic>? southWest =
        boundsJson['southwest'] as Map<String, dynamic>?;
    if (northEast == null || southWest == null) {
      return null;
    }

    return LatLngBounds(
      northeast: LatLng(
        (northEast['lat'] as num).toDouble(),
        (northEast['lng'] as num).toDouble(),
      ),
      southwest: LatLng(
        (southWest['lat'] as num).toDouble(),
        (southWest['lng'] as num).toDouble(),
      ),
    );
  }

  static List<LatLng> _dedupeConsecutivePoints(List<LatLng> points) {
    final List<LatLng> deduped = <LatLng>[];
    for (final LatLng point in points) {
      if (deduped.isEmpty ||
          deduped.last.latitude != point.latitude ||
          deduped.last.longitude != point.longitude) {
        deduped.add(point);
      }
    }
    return deduped;
  }
}

class NavigationRoute {
  final List<LatLng> points;
  final LatLngBounds? bounds;
  final List<NavigationStep> steps;
  final String? summary;
  final double distanceMeters;
  final double durationSeconds;

  const NavigationRoute({
    required this.points,
    required this.bounds,
    required this.steps,
    required this.summary,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class NavigationStep {
  final String instruction;
  final String? maneuver;
  final LatLng startLocation;
  final LatLng endLocation;
  final double distanceMeters;
  final double durationSeconds;
  final List<LatLng> points;

  const NavigationStep({
    required this.instruction,
    required this.maneuver,
    required this.startLocation,
    required this.endLocation,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.points,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> startLocation =
        json['start_location'] as Map<String, dynamic>;
    final Map<String, dynamic> endLocation =
        json['end_location'] as Map<String, dynamic>;
    final String encodedPolyline =
        ((json['polyline'] as Map?)?['points'] as String?) ?? '';

    return NavigationStep(
      instruction: _sanitizeInstruction(
          json['html_instructions']?.toString() ?? 'Continue'),
      maneuver: json['maneuver']?.toString(),
      startLocation: LatLng(
        (startLocation['lat'] as num).toDouble(),
        (startLocation['lng'] as num).toDouble(),
      ),
      endLocation: LatLng(
        (endLocation['lat'] as num).toDouble(),
        (endLocation['lng'] as num).toDouble(),
      ),
      distanceMeters:
          ((json['distance'] as Map?)?['value'] as num?)?.toDouble() ?? 0,
      durationSeconds:
          ((json['duration'] as Map?)?['value'] as num?)?.toDouble() ?? 0,
      points: encodedPolyline.isEmpty
          ? <LatLng>[]
          : LiveNavigationService.decodePolyline(encodedPolyline),
    );
  }

  NavigationTurnType get turnType {
    final String maneuverText = (maneuver ?? instruction).toLowerCase();
    if (maneuverText.contains('roundabout')) {
      return NavigationTurnType.roundabout;
    }
    if (maneuverText.contains('uturn') || maneuverText.contains('u-turn')) {
      return NavigationTurnType.uTurn;
    }
    if (maneuverText.contains('sharp right')) {
      return NavigationTurnType.sharpRight;
    }
    if (maneuverText.contains('sharp left')) {
      return NavigationTurnType.sharpLeft;
    }
    if (maneuverText.contains('slight right')) {
      return NavigationTurnType.slightRight;
    }
    if (maneuverText.contains('slight left')) {
      return NavigationTurnType.slightLeft;
    }
    if (maneuverText.contains('right')) {
      return NavigationTurnType.right;
    }
    if (maneuverText.contains('left')) {
      return NavigationTurnType.left;
    }
    if (maneuverText.contains('merge')) {
      return NavigationTurnType.merge;
    }
    if (maneuverText.contains('arrive')) {
      return NavigationTurnType.arrive;
    }
    return NavigationTurnType.straight;
  }

  static String _sanitizeInstruction(String htmlInstruction) {
    return htmlInstruction
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

enum NavigationTurnType {
  straight,
  left,
  right,
  slightLeft,
  slightRight,
  sharpLeft,
  sharpRight,
  uTurn,
  arrive,
  roundabout,
  merge,
}