import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/chat/domain/models/conversation_model.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/services/live_navigation_service.dart';
import 'package:Oxygen_Mart/features/order/widgets/track_details_view_widget.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/marker_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen(
      {super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = {};
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;

  // ── Live navigation state ──────────────────────────────────────────────────
  late AnimationController _driverAnimController;
  final LiveNavigationService _navigationService = LiveNavigationService();
  LatLng? _animatedDriverPosition;

  // ── Cached marker bitmaps (loaded once) ────────────────────────────────────
  BitmapDescriptor? _driverMarkerBitmap;
  BitmapDescriptor? _storeMarkerBitmap;
  BitmapDescriptor? _destinationMarkerBitmap;
  bool _bitmapsLoaded = false;

  // ── Driver position change detection ───────────────────────────────────────
  String? _lastDriverLat;
  String? _lastDriverLng;
  LatLng? _customerLatLng;
  LatLng? _storeLatLng;
  LatLng? _snappedDriverPosition;
  NavigationRoute? _navigationRoute;
  List<LatLng> _completedRoutePoints = <LatLng>[];
  List<LatLng> _remainingRoutePoints = <LatLng>[];
  List<LatLng> _transitionRoutePoints = <LatLng>[];
  List<LatLng> _transitionCompletedPreview = <LatLng>[];
  List<LatLng> _transitionRemainingPreview = <LatLng>[];
  double _driverBearing = 0;
  int _navRequestSerial = 0;

  // ── Live delivery info ──────────────────────────────────────────────────────
  double? _liveDistanceKm;
  int? _liveEtaMinutes;

  // ── Camera user-interaction guard ──────────────────────────────────────────
  bool _userInteractingWithMap = false;
  bool _programmaticCameraMove = false;
  Timer? _cameraIdleTimer;
  double _sheetExtent = 0.18;
  bool _isPollingTrackOrder = false;

  void _loadData() async {
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true,
        contactNumber: widget.contactNumber);
    await Get.find<OrderController>()
        .refreshDeliveryManLocation(widget.orderID.toString());
    await Get.find<LocationController>().getCurrentLocation(true,
        notify: false,
        defaultLatLng: LatLng(
          double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
          double.parse(
              AddressHelper.getUserAddressFromSharedPref()!.longitude!),
        ));
    if (mounted) {
      _syncDriverPositionFromTrack(
        Get.find<OrderController>().trackModel,
        animateCamera: false,
      );
    }
  }

  void _startApiCall() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isPollingTrackOrder || !mounted) {
        return;
      }

      _isPollingTrackOrder = true;
      try {
        await Get.find<OrderController>().timerTrackOrder(
          widget.orderID.toString(),
          contactNumber: widget.contactNumber,
          canUpdate: false,
        );
        await Get.find<OrderController>().refreshDeliveryManLocation(
            widget.orderID.toString(),
            canUpdate: false);
        if (!mounted) {
          return;
        }
        _syncDriverPositionFromTrack(Get.find<OrderController>().trackModel);
      } finally {
        _isPollingTrackOrder = false;
      }
    });
  }

  void _syncDriverPositionFromTrack(
    OrderModel? track, {
    bool animateCamera = true,
  }) {
    if (track?.deliveryMan == null || _isLoading) {
      return;
    }

    final String? lat = track!.deliveryMan!.lat;
    final String? lng = track.deliveryMan!.lng;
    if (lat == null || lng == null) {
      return;
    }

    final LatLng newPos =
        LatLng(double.tryParse(lat) ?? 0, double.tryParse(lng) ?? 0);

    if (_lastDriverLat == null || _lastDriverLng == null) {
      _lastDriverLat = lat;
      _lastDriverLng = lng;
      if (_animatedDriverPosition == null) {
        _animatedDriverPosition = newPos;
      }
      if (_snappedDriverPosition == null) {
        _snappedDriverPosition = newPos;
      }
      return;
    }

    if (lat == _lastDriverLat && lng == _lastDriverLng) {
      return;
    }

    _lastDriverLat = lat;
    _lastDriverLng = lng;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _onDriverPositionChanged(newPos);
      if (!animateCamera) {
        _userInteractingWithMap = true;
        _cameraIdleTimer?.cancel();
        _cameraIdleTimer = Timer(
          const Duration(milliseconds: 300),
          () => _userInteractingWithMap = false,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _driverAnimController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )
      ..addListener(_onDriverAnimTick)
      ..addStatusListener(_onDriverAnimStatusChanged);
    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    _cameraIdleTimer?.cancel();
    _driverAnimController.dispose();
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool _onSheetNotification(DraggableScrollableNotification notification) {
    final double nextExtent = notification.extent;
    if ((nextExtent - _sheetExtent).abs() < 0.01 || !mounted) {
      return false;
    }
    setState(() {
      _sheetExtent = nextExtent;
    });
    return false;
  }

  // ── Animation listener: move driver along the routed road path ─────────────
  void _onDriverAnimTick() {
    if (_transitionRoutePoints.isEmpty) return;
    final double curved =
        Curves.easeInOutCubic.transform(_driverAnimController.value);
    final _NavigationPathFrame frame =
        _samplePathFrame(_transitionRoutePoints, curved);
    _animatedDriverPosition = frame.position;
    _driverBearing = frame.bearing;
    _transitionCompletedPreview = frame.completed;
    _transitionRemainingPreview = frame.remaining;
    _rebuildDriverMarker();
    _followDriverCamera();
  }

  void _onDriverAnimStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || _transitionRoutePoints.isEmpty) {
      return;
    }
    _completedRoutePoints =
        _mergePathPoints(_completedRoutePoints, _transitionRoutePoints);
    _animatedDriverPosition = _transitionRoutePoints.last;
    _transitionRoutePoints = <LatLng>[];
    _transitionCompletedPreview = <LatLng>[];
    _transitionRemainingPreview = <LatLng>[];
    _rebuildDriverMarker();
  }

  // ── Rebuild driver marker in-place (no bitmap reload) ─────────────────────
  void _rebuildDriverMarker() {
    if (_driverMarkerBitmap == null || _animatedDriverPosition == null) return;

    final Set<Marker> updatedMarkers = Set<Marker>.from(_markers);
    updatedMarkers
        .removeWhere((m) => m.markerId == const MarkerId('delivery_boy'));
    updatedMarkers.add(Marker(
      markerId: const MarkerId('delivery_boy'),
      position: _animatedDriverPosition!,
      icon: _driverMarkerBitmap!,
      rotation: _driverBearing,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      zIndexInt: 3,
    ));
    _markers = updatedMarkers;

    _updatePolylinesInPlace();
    if (mounted) setState(() {});
  }

  // ── Update polylines without reloading bitmaps ─────────────────────────────
  void _updatePolylinesInPlace() {
    if (_animatedDriverPosition == null || _customerLatLng == null) return;
    final List<LatLng> completedPath = _buildDisplayedCompletedPath();
    final List<LatLng> remainingPath = _buildDisplayedRemainingPath();
    final Set<Polyline> updated = {};
    if (completedPath.length > 1) {
      updated.add(Polyline(
        polylineId: const PolylineId('completed_route'),
        points: completedPath,
        color: Colors.blueGrey.shade300,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ));
    }
    if (remainingPath.length > 1) {
      updated.add(Polyline(
        polylineId: const PolylineId('active_route_glow'),
        points: remainingPath,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.16),
        width: 11,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 1,
      ));
      updated.add(Polyline(
        polylineId: const PolylineId('active_route'),
        points: remainingPath,
        color: Theme.of(context).primaryColor,
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: 2,
      ));
    }
    _polylines = updated;
  }

  // ── Compass bearing for driver marker rotation ─────────────────────────────
  double _calculateBearing(LatLng? from, LatLng? to) {
    if (from == null || to == null) return 0.0;
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  void _updateLiveInfoFallback(LatLng driverPos, LatLng customerPos) {
    final meters = Geolocator.distanceBetween(
      driverPos.latitude,
      driverPos.longitude,
      customerPos.latitude,
      customerPos.longitude,
    );
    final km = meters / 1000;
    final etaMin = (km / 25 * 60).round().clamp(1, 999);
    if (mounted) {
      setState(() {
        _liveDistanceKm = km;
        _liveEtaMinutes = etaMin;
      });
    }
  }

  void _updateLiveInfoFromRoute(NavigationRoute route) {
    if (!mounted) return;
    setState(() {
      _liveDistanceKm = route.distanceMeters / 1000;
      _liveEtaMinutes = math.max(1, (route.durationSeconds / 60).round());
    });
  }

  // ── Fit full route overview ────────────────────────────────────────────────
  void _updateSmartCamera(LatLng driverPos, LatLng customerPos) {
    if (_controller == null) return;
    final LatLngBounds? routeBounds = _navigationRoute?.bounds;
    if (routeBounds != null) {
      _moveCamera(CameraUpdate.newLatLngBounds(routeBounds, 100),
          animate: true);
      return;
    }
    final sw = LatLng(
      math.min(driverPos.latitude, customerPos.latitude),
      math.min(driverPos.longitude, customerPos.longitude),
    );
    final ne = LatLng(
      math.max(driverPos.latitude, customerPos.latitude),
      math.max(driverPos.longitude, customerPos.longitude),
    );
    _moveCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: sw, northeast: ne), 90),
      animate: true,
    );
  }

  // ── Triggered when controller detects driver moved ─────────────────────────
  Future<void> _onDriverPositionChanged(LatLng newPos) async {
    if (_customerLatLng == null) return;
    final int requestId = ++_navRequestSerial;
    final LatLng snappedDriverPos =
        await _navigationService.snapToRoad(newPos) ?? newPos;
    if (!mounted || requestId != _navRequestSerial) {
      return;
    }

    final bool offRoute = _isOffRoute(snappedDriverPos);
    final List<LatLng> transitionPath =
        _buildTransitionPath(snappedDriverPos, offRoute);
    _startDriverAnimation(transitionPath);

    setState(() {
      _snappedDriverPosition = snappedDriverPos;
    });

    final NavigationRoute? route = await _navigationService.fetchRoute(
      origin: snappedDriverPos,
      destination: _customerLatLng!,
    );
    if (!mounted || requestId != _navRequestSerial) {
      return;
    }

    if (route == null) {
      _updateLiveInfoFallback(snappedDriverPos, _customerLatLng!);
      _updatePolylinesInPlace();
      _followDriverCamera();
      return;
    }

    setState(() {
      _navigationRoute = route;
      _remainingRoutePoints =
          _normalizeRemainingRoute(route.points, snappedDriverPos);
    });
    _updateLiveInfoFromRoute(route);
    _updatePolylinesInPlace();
    _followDriverCamera(animate: offRoute);
  }

  Future<void> _initializeNavigation(
    LatLng driverPos, {
    bool followCamera = true,
  }) async {
    if (_customerLatLng == null) return;
    final int requestId = ++_navRequestSerial;
    final LatLng snappedDriverPos =
        await _navigationService.snapToRoad(driverPos) ?? driverPos;
    if (!mounted || requestId != _navRequestSerial) {
      return;
    }

    final NavigationRoute? route = await _navigationService.fetchRoute(
      origin: snappedDriverPos,
      destination: _customerLatLng!,
    );
    if (!mounted || requestId != _navRequestSerial) {
      return;
    }

    _snappedDriverPosition = snappedDriverPos;
    _animatedDriverPosition = snappedDriverPos;
    _completedRoutePoints = <LatLng>[snappedDriverPos];
    _transitionRoutePoints = <LatLng>[];
    _transitionCompletedPreview = <LatLng>[];
    _transitionRemainingPreview = <LatLng>[];

    if (route != null) {
      _navigationRoute = route;
      _remainingRoutePoints =
          _normalizeRemainingRoute(route.points, snappedDriverPos);
      _driverBearing = _bearingFromRoute(_remainingRoutePoints);
      _updateLiveInfoFromRoute(route);
    } else {
      _remainingRoutePoints = _customerLatLng == null
          ? <LatLng>[]
          : <LatLng>[snappedDriverPos, _customerLatLng!];
      _driverBearing = _customerLatLng == null
          ? 0
          : _calculateBearing(snappedDriverPos, _customerLatLng);
      _updateLiveInfoFallback(snappedDriverPos, _customerLatLng!);
    }

    _rebuildDriverMarker();
    if (followCamera) {
      _followDriverCamera(animate: true);
    }
  }

  void _startDriverAnimation(List<LatLng> transitionPath) {
    final List<LatLng> normalizedPath = _dedupePath(transitionPath);
    if (normalizedPath.isEmpty) {
      return;
    }

    if (_transitionCompletedPreview.length > 1) {
      _completedRoutePoints =
          _mergePathPoints(_completedRoutePoints, _transitionCompletedPreview);
    }

    _driverAnimController.stop();
    if (normalizedPath.length == 1 || _pathLengthMeters(normalizedPath) < 3) {
      _transitionRoutePoints = <LatLng>[];
      _transitionCompletedPreview = <LatLng>[];
      _transitionRemainingPreview = <LatLng>[];
      _animatedDriverPosition = normalizedPath.last;
      _driverBearing = _bearingFromRoute(
        normalizedPath.length > 1 ? normalizedPath : _remainingRoutePoints,
      );
      _rebuildDriverMarker();
      _followDriverCamera();
      return;
    }

    _transitionRoutePoints = normalizedPath;
    _transitionCompletedPreview = <LatLng>[normalizedPath.first];
    _transitionRemainingPreview = normalizedPath;
    _driverAnimController.duration =
        Duration(milliseconds: _animationDurationMs(normalizedPath));
    _driverAnimController
      ..reset()
      ..forward();
  }

  List<LatLng> _buildTransitionPath(LatLng snappedDriverPos, bool offRoute) {
    final LatLng start =
        _animatedDriverPosition ?? _snappedDriverPosition ?? snappedDriverPos;
    if (!offRoute && _remainingRoutePoints.length > 1) {
      final int targetIndex =
          _closestPointIndex(_remainingRoutePoints, snappedDriverPos);
      final double snapDistance = Geolocator.distanceBetween(
        snappedDriverPos.latitude,
        snappedDriverPos.longitude,
        _remainingRoutePoints[targetIndex].latitude,
        _remainingRoutePoints[targetIndex].longitude,
      );
      if (snapDistance <= 75 && targetIndex > 0) {
        return _dedupePath(<LatLng>[
          start,
          ..._remainingRoutePoints.sublist(1, targetIndex + 1),
          snappedDriverPos,
        ]);
      }
    }
    return _dedupePath(<LatLng>[start, snappedDriverPos]);
  }

  List<LatLng> _normalizeRemainingRoute(List<LatLng> route, LatLng origin) {
    if (route.isEmpty) {
      return _customerLatLng == null
          ? <LatLng>[origin]
          : <LatLng>[origin, _customerLatLng!];
    }
    final int closestIndex = _closestPointIndex(route, origin);
    final List<LatLng> normalized = <LatLng>[origin];
    if (closestIndex < route.length - 1) {
      normalized.addAll(route.sublist(closestIndex + 1));
    } else if (_customerLatLng != null) {
      normalized.add(_customerLatLng!);
    }
    return _dedupePath(normalized);
  }

  bool _isOffRoute(LatLng snappedDriverPos) {
    if (_remainingRoutePoints.length < 2) {
      return false;
    }
    final int closestIndex =
        _closestPointIndex(_remainingRoutePoints, snappedDriverPos);
    final LatLng nearestPoint = _remainingRoutePoints[closestIndex];
    final double deviationMeters = Geolocator.distanceBetween(
      snappedDriverPos.latitude,
      snappedDriverPos.longitude,
      nearestPoint.latitude,
      nearestPoint.longitude,
    );
    return deviationMeters > 70;
  }

  List<LatLng> _buildDisplayedCompletedPath() {
    if (_transitionCompletedPreview.length > 1) {
      return _mergePathPoints(
          _completedRoutePoints, _transitionCompletedPreview);
    }
    return _completedRoutePoints;
  }

  List<LatLng> _buildDisplayedRemainingPath() {
    if (_animatedDriverPosition == null) {
      return _remainingRoutePoints;
    }
    if (_transitionRemainingPreview.length > 1) {
      return _mergePathPoints(
        _transitionRemainingPreview,
        _remainingRoutePoints.length > 1
            ? _remainingRoutePoints.sublist(1)
            : <LatLng>[],
      );
    }
    if (_remainingRoutePoints.length > 1) {
      return _mergePathPoints(
        <LatLng>[_animatedDriverPosition!],
        _remainingRoutePoints.sublist(1),
      );
    }
    return _customerLatLng == null
        ? <LatLng>[_animatedDriverPosition!]
        : <LatLng>[_animatedDriverPosition!, _customerLatLng!];
  }

  List<LatLng> _mergePathPoints(List<LatLng> first, List<LatLng> second) {
    final List<LatLng> merged = <LatLng>[...first];
    for (final LatLng point in second) {
      if (merged.isEmpty ||
          Geolocator.distanceBetween(
                merged.last.latitude,
                merged.last.longitude,
                point.latitude,
                point.longitude,
              ) >
              2) {
        merged.add(point);
      }
    }
    return merged;
  }

  List<LatLng> _dedupePath(List<LatLng> points) {
    if (points.isEmpty) return <LatLng>[];
    final List<LatLng> deduped = <LatLng>[points.first];
    for (final LatLng point in points.skip(1)) {
      if (Geolocator.distanceBetween(
            deduped.last.latitude,
            deduped.last.longitude,
            point.latitude,
            point.longitude,
          ) >
          1) {
        deduped.add(point);
      }
    }
    return deduped;
  }

  _NavigationPathFrame _samplePathFrame(List<LatLng> path, double progress) {
    if (path.length < 2) {
      final LatLng fallback = path.isNotEmpty
          ? path.last
          : (_animatedDriverPosition ?? const LatLng(0, 0));
      return _NavigationPathFrame(
        position: fallback,
        bearing: _driverBearing,
        completed: path,
        remaining: path,
      );
    }

    final double totalDistance = _pathLengthMeters(path);
    if (totalDistance <= 0) {
      return _NavigationPathFrame(
        position: path.last,
        bearing: _calculateBearing(path.first, path.last),
        completed: path,
        remaining: <LatLng>[path.last],
      );
    }

    final double targetDistance = totalDistance * progress;
    double traversed = 0;
    final List<LatLng> completed = <LatLng>[path.first];

    for (int index = 0; index < path.length - 1; index++) {
      final LatLng start = path[index];
      final LatLng end = path[index + 1];
      final double segmentDistance = Geolocator.distanceBetween(
          start.latitude, start.longitude, end.latitude, end.longitude);

      if (traversed + segmentDistance >= targetDistance) {
        final double localProgress = segmentDistance == 0
            ? 1
            : (targetDistance - traversed) / segmentDistance;
        final LatLng currentPoint = LatLng(
          start.latitude + (end.latitude - start.latitude) * localProgress,
          start.longitude + (end.longitude - start.longitude) * localProgress,
        );
        if (Geolocator.distanceBetween(
              completed.last.latitude,
              completed.last.longitude,
              currentPoint.latitude,
              currentPoint.longitude,
            ) >
            1) {
          completed.add(currentPoint);
        }
        return _NavigationPathFrame(
          position: currentPoint,
          bearing: _calculateBearing(start, end),
          completed: completed,
          remaining: <LatLng>[currentPoint, ...path.sublist(index + 1)],
        );
      }

      traversed += segmentDistance;
      completed.add(end);
    }

    return _NavigationPathFrame(
      position: path.last,
      bearing: _calculateBearing(path[path.length - 2], path.last),
      completed: path,
      remaining: <LatLng>[path.last],
    );
  }

  double _pathLengthMeters(List<LatLng> path) {
    double distance = 0;
    for (int index = 0; index < path.length - 1; index++) {
      distance += Geolocator.distanceBetween(
        path[index].latitude,
        path[index].longitude,
        path[index + 1].latitude,
        path[index + 1].longitude,
      );
    }
    return distance;
  }

  int _animationDurationMs(List<LatLng> path) {
    final double distance = _pathLengthMeters(path);
    if (distance < 80) {
      return 1000;
    }
    if (distance < 180) {
      return 1400;
    }
    if (distance < 320) {
      return 1800;
    }
    return 2400;
  }

  int _closestPointIndex(List<LatLng> points, LatLng target) {
    if (points.isEmpty) {
      return 0;
    }
    double minDistance = double.infinity;
    int minIndex = 0;
    for (int index = 0; index < points.length; index++) {
      final LatLng point = points[index];
      final double distance = Geolocator.distanceBetween(
        target.latitude,
        target.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        minIndex = index;
      }
    }
    return minIndex;
  }

  double _bearingFromRoute(List<LatLng> route) {
    if (route.length < 2) {
      return _driverBearing;
    }
    return _calculateBearing(route.first, route[1]);
  }

  void _followDriverCamera({bool animate = false}) {
    if (_controller == null ||
        _animatedDriverPosition == null ||
        _userInteractingWithMap) {
      return;
    }
    final double zoom = _resolveNavigationZoom();
    final LatLng focusPoint =
        _offsetPoint(_animatedDriverPosition!, _driverBearing, 110);
    final CameraPosition cameraPosition = CameraPosition(
      target: focusPoint,
      zoom: zoom,
      tilt: 58,
      bearing: _driverBearing,
    );
    _moveCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
      animate: animate,
    );
  }

  double _resolveNavigationZoom() {
    final double remainingKm = _liveDistanceKm ?? 0;
    if (remainingKm < 0.35) {
      return 18.3;
    }
    if (remainingKm < 0.8) {
      return 17.8;
    }
    if (remainingKm < 2) {
      return 17.0;
    }
    if (remainingKm < 4) {
      return 16.3;
    }
    return 15.7;
  }

  LatLng _offsetPoint(LatLng source, double bearing, double distanceMeters) {
    const double earthRadius = 6378137;
    final double distanceRatio = distanceMeters / earthRadius;
    final double bearingRad = bearing * math.pi / 180;
    final double lat1 = source.latitude * math.pi / 180;
    final double lng1 = source.longitude * math.pi / 180;

    final double lat2 = math.asin(math.sin(lat1) * math.cos(distanceRatio) +
        math.cos(lat1) * math.sin(distanceRatio) * math.cos(bearingRad));
    final double lng2 = lng1 +
        math.atan2(
          math.sin(bearingRad) * math.sin(distanceRatio) * math.cos(lat1),
          math.cos(distanceRatio) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(lat2 * 180 / math.pi, lng2 * 180 / math.pi);
  }

  void _moveCamera(CameraUpdate update, {bool animate = false}) {
    if (_controller == null) return;
    _programmaticCameraMove = true;
    if (animate) {
      _controller!.animateCamera(update);
    } else {
      _controller!.moveCamera(update);
    }
  }

  void onEntered(bool hovered) {
    setState(() => isHovered = hovered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if (orderController.trackModel != null) {
          track = orderController.trackModel;

          if (track!.orderType != 'parcel') {
            if (track.store!.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store!.storeSubscription != null &&
                track.store!.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        final double viewportHeight = ResponsiveHelper.isDesktop(context)
            ? 700
            : MediaQuery.of(context).size.height;
        final double mapBottomPadding = viewportHeight * _sheetExtent + 24;
        final double actionButtonsBottom =
            mapBottomPadding + Dimensions.paddingSizeSmall;

        return track != null
            ? SingleChildScrollView(
                physics: isHovered || !ResponsiveHelper.isDesktop(context)
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                child: FooterView(
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      height: viewportHeight,
                      child: Stack(children: [
                        // ── Map ─────────────────────────────────────────
                        MouseRegion(
                          onEnter: (_) => onEntered(true),
                          onExit: (_) => onEntered(false),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                double.parse(track.deliveryAddress!.latitude!),
                                double.parse(track.deliveryAddress!.longitude!),
                              ),
                              zoom: 15,
                            ),
                            minMaxZoomPreference:
                                const MinMaxZoomPreference(0, 18),
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            buildingsEnabled: true,
                            compassEnabled: false,
                            padding: EdgeInsets.only(
                              top: 170,
                              bottom: mapBottomPadding,
                            ),
                            markers: _markers,
                            polylines: _polylines,
                            myLocationButtonEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              _controller = controller;
                              _isLoading = false;
                              _initializeMapMarkers(track!);
                            },
                            onCameraMoveStarted: () {
                              if (!_programmaticCameraMove) {
                                _userInteractingWithMap = true;
                              }
                            },
                            onCameraIdle: () {
                              if (_programmaticCameraMove) {
                                _programmaticCameraMove = false;
                                return;
                              }
                              _cameraIdleTimer?.cancel();
                              _cameraIdleTimer = Timer(
                                const Duration(seconds: 5),
                                () => _userInteractingWithMap = false,
                              );
                            },
                            style: Get.isDarkMode
                                ? Get.find<ThemeController>().darkMap
                                : Get.find<ThemeController>().lightMap,
                          ),
                        ),

                        // ── Loading overlay ──────────────────────────────
                        if (_isLoading)
                          Container(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withValues(alpha: 0.5),
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),

                        // ── Floating back button ─────────────────────────
                        Positioned(
                          top: MediaQuery.of(context).padding.top +
                              Dimensions.paddingSizeSmall,
                          left: Dimensions.paddingSizeSmall,
                          child: _FloatingCircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Get.back(),
                          ),
                        ),

                        // ── Floating help button ─────────────────────────
                        Positioned(
                          top: MediaQuery.of(context).padding.top +
                              Dimensions.paddingSizeSmall,
                          right: Dimensions.paddingSizeSmall,
                          child: _FloatingCircleButton(
                            icon: Icons.question_mark_rounded,
                            onTap: () =>
                                Get.toNamed(RouteHelper.getSupportRoute()),
                          ),
                        ),

                        // ── Live ETA + distance pill ─────────────────────
                        if (_liveDistanceKm != null &&
                            track.deliveryMan != null)
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 60,
                            left: 48,
                            right: 48,
                            child: _LiveInfoPill(
                              distanceKm: _liveDistanceKm!,
                              etaMinutes: _liveEtaMinutes ?? 1,
                            ),
                          ),

                        // ── Re-center / my-location button ──────────────
                        Positioned(
                          right: 15,
                          bottom: actionButtonsBottom,
                          child: _FloatingCircleButton(
                            icon: Icons.my_location_rounded,
                            onTap: () => _checkPermission(() async {
                              AddressModel address =
                                  await Get.find<LocationController>()
                                      .getCurrentLocation(false,
                                          mapController: _controller);
                              _initializeMapMarkers(track!,
                                  currentAddress: address,
                                  fromCurrentLocation: true);
                            }),
                          ),
                        ),

                        // ── Fit-all button ────────────────────────────────
                        Positioned(
                          right: 15,
                          bottom: actionButtonsBottom + 60,
                          child: _FloatingCircleButton(
                            icon: Icons.fit_screen_rounded,
                            onTap: () {
                              if (_animatedDriverPosition != null &&
                                  _customerLatLng != null) {
                                _userInteractingWithMap = false;
                                _updateSmartCamera(
                                  _animatedDriverPosition!,
                                  _customerLatLng!,
                                );
                              }
                            },
                          ),
                        ),

                        // ── Bottom sheet ─────────────────────────────────
                        // ── Bottom sheet ─────────────────────────────────
                        Positioned.fill(
                          child: NotificationListener<
                              DraggableScrollableNotification>(
                            onNotification: _onSheetNotification,
                            child: DraggableScrollableSheet(
                              key: const Key('order_tracking_sheet'),
                              initialChildSize: 0.18,
                              minChildSize: 0.14,
                              maxChildSize: 0.78,
                              expand: true,
                              builder: (context, scrollController) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  child: TrackDetailsViewWidget(
                                    status: track!.orderStatus,
                                    track: track,
                                    scrollController: scrollController,
                                    showChatPermission: showChatPermission,
                                    liveDistanceKm: _liveDistanceKm,
                                    liveEtaMinutes: _liveEtaMinutes,
                                    callback: () async {
                                      _timer?.cancel();
                                      await Get.toNamed(
                                          RouteHelper.getChatRoute(
                                        notificationBody: NotificationBodyModel(
                                            deliverymanId:
                                                track!.deliveryMan!.id,
                                            orderId:
                                                int.parse(widget.orderID!)),
                                        user: User(
                                            id: track.deliveryMan!.id,
                                            fName: track.deliveryMan!.fName,
                                            lName: track.deliveryMan!.lName,
                                            imageFullUrl: track
                                                .deliveryMan!.imageFullUrl),
                                      ));
                                      _startApiCall();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  // ── Initialize map markers and camera (first load or re-center) ────────────
  Future<void> _initializeMapMarkers(
    OrderModel track, {
    AddressModel? currentAddress,
    bool fromCurrentLocation = false,
  }) async {
    try {
      final bool parcel = track.orderType == 'parcel';
      final bool takeAway = track.orderType == 'take_away';
      final bool isRestaurant = track.moduleType == 'food';

      final Store? store = parcel
          ? Store(
              latitude: track.receiverDetails!.latitude,
              longitude: track.receiverDetails!.longitude,
              address: track.receiverDetails!.address,
              name: track.receiverDetails!.contactPersonName)
          : track.store;

      final AddressModel? addressModel = takeAway
          ? (Get.find<LocationController>().position.latitude == 0
              ? track.deliveryAddress
              : AddressModel(
                  latitude: Get.find<LocationController>()
                      .position
                      .latitude
                      .toString(),
                  longitude: Get.find<LocationController>()
                      .position
                      .longitude
                      .toString(),
                  address: Get.find<LocationController>().address,
                ))
          : track.deliveryAddress;

      // Load bitmaps once; reuse on subsequent calls
      if (!_bitmapsLoaded) {
        _storeMarkerBitmap = await MarkerHelper.convertAssetToBitmapDescriptor(
          width: (isRestaurant || parcel) ? 50 : 70,
          imagePath: Images.modernStorePin,
        );
        _driverMarkerBitmap = await MarkerHelper.convertAssetToBitmapDescriptor(
          width: 50,
          imagePath: Images.modernDeliveryPin,
        );
        _destinationMarkerBitmap =
            await MarkerHelper.convertAssetToBitmapDescriptor(
          width: 50,
          imagePath: Images.modernCustomerPin,
        );
        _bitmapsLoaded = true;
      }

      // Cache reference positions for later live updates
      if (store != null) {
        _storeLatLng = LatLng(
            double.parse(store.latitude!), double.parse(store.longitude!));
      }
      if (addressModel != null) {
        _customerLatLng = LatLng(double.parse(addressModel.latitude!),
            double.parse(addressModel.longitude!));
      }

      if (track.deliveryMan == null) {
        _navigationRoute = null;
        _completedRoutePoints = <LatLng>[];
        _remainingRoutePoints = <LatLng>[];
        _transitionRoutePoints = <LatLng>[];
        _transitionCompletedPreview = <LatLng>[];
        _transitionRemainingPreview = <LatLng>[];
      }

      // Build marker set
      _markers = HashSet<Marker>();

      if (currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndexInt: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(double.parse(currentAddress.latitude!),
              double.parse(currentAddress.longitude!)),
          icon: _destinationMarkerBitmap!,
        ));
      }

      if (currentAddress == null && addressModel != null) {
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!)),
          infoWindow: InfoWindow(
            title: parcel ? 'sender'.tr : 'destination'.tr,
            snippet: addressModel.address,
          ),
          icon: _destinationMarkerBitmap!,
          zIndexInt: 2,
        ));
      }

      if (store != null) {
        _markers.add(Marker(
          markerId: const MarkerId('store'),
          position: _storeLatLng!,
          infoWindow: InfoWindow(
            title: parcel ? 'receiver'.tr : 'store'.tr,
            snippet: store.address,
          ),
          icon: _storeMarkerBitmap!,
          zIndexInt: 2,
        ));
      }

      if (track.deliveryMan != null) {
        final driverPos = LatLng(
          double.tryParse(track.deliveryMan!.lat ?? '0') ?? 0,
          double.tryParse(track.deliveryMan!.lng ?? '0') ?? 0,
        );
        _animatedDriverPosition = driverPos;
        _snappedDriverPosition = driverPos;
        _lastDriverLat = track.deliveryMan!.lat;
        _lastDriverLng = track.deliveryMan!.lng;

        _markers.add(Marker(
          markerId: const MarkerId('delivery_boy'),
          position: driverPos,
          infoWindow: InfoWindow(
              title: 'delivery_man'.tr, snippet: track.deliveryMan!.location),
          icon: _driverMarkerBitmap!,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 3,
        ));

        if (_customerLatLng != null) {
          await _initializeNavigation(driverPos,
              followCamera: !fromCurrentLocation);
        }
      }

      // Camera
      if (fromCurrentLocation && currentAddress != null) {
        _moveCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(double.parse(currentAddress.latitude!),
                double.parse(currentAddress.longitude!)),
            zoom: GetPlatform.isWeb ? 7 : 15,
          )),
          animate: true,
        );
      } else if (_animatedDriverPosition != null && _customerLatLng != null) {
        if (_navigationRoute != null) {
          _followDriverCamera(animate: true);
        } else {
          _updateSmartCamera(_animatedDriverPosition!, _customerLatLng!);
        }
      } else if (addressModel != null && store != null) {
        _fitBoundsToStoreAndCustomer(addressModel, store);
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void _fitBoundsToStoreAndCustomer(AddressModel addressModel, Store store) {
    if (_controller == null) return;
    try {
      final LatLngBounds bounds;
      if (double.parse(addressModel.latitude!) <
          double.parse(store.latitude!)) {
        bounds = LatLngBounds(
          southwest: LatLng(double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!)),
          northeast: LatLng(
              double.parse(store.latitude!), double.parse(store.longitude!)),
        );
      } else {
        bounds = LatLngBounds(
          southwest: LatLng(
              double.parse(store.latitude!), double.parse(store.longitude!)),
          northeast: LatLng(double.parse(addressModel.latitude!),
              double.parse(addressModel.longitude!)),
        );
      }
      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      _controller!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: center, zoom: GetPlatform.isWeb ? 10 : 15)));
      if (!ResponsiveHelper.isWeb()) {
        zoomToFit(_controller, bounds, center,
            padding: GetPlatform.isWeb ? 15 : 3);
      }
    } catch (_) {}
  }

  // ── Keep-legacy helpers used by re-center / zoom-to-fit ───────────────────
  // ignore: unused_element
  void _legacySetMarker(Store? store, DeliveryMan? deliveryMan,
      AddressModel? addressModel, bool takeAway, bool parcel, bool isRestaurant,
      {AddressModel? currentAddress, bool fromCurrentLocation = false}) {
    if (addressModel != null && store != null) {
      _initializeMapMarkers(
        Get.find<OrderController>().trackModel!,
        currentAddress: currentAddress,
        fromCurrentLocation: fromCurrentLocation,
      );
    }
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    } else {
      onTap();
    }
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds,
      LatLng centerBounds,
      {double padding = 0.5}) async {
    bool keepZoomingOut = true;
    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      } else {
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    return screenBounds.northeast.latitude >= fitBounds.northeast.latitude &&
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude &&
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude &&
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;
  }
}

class _FloatingCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _FloatingCircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon,
              size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}

// ── Live info pill shown above the map ────────────────────────────────────────
class _LiveInfoPill extends StatelessWidget {
  final double distanceKm;
  final int etaMinutes;

  const _LiveInfoPill({required this.distanceKm, required this.etaMinutes});

  @override
  Widget build(BuildContext context) {
    final distLabel = distanceKm < 1
        ? '${(distanceKm * 1000).round()} ${'m'.tr}'
        : '${distanceKm.toStringAsFixed(1)} ${'km'.tr}';

    return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PillChip(
                    icon: Icons.timer_outlined,
                    value: '$etaMinutes ${'min'.tr}',
                    label: 'estimated_delivery_time'.tr,
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                  _PillChip(
                    icon: Icons.straighten_rounded,
                    value: distLabel,
                    label: 'distance'.tr,
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                  Row(children: [
                    const _PulsingDot(),
                    const SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ]),
                ],
              ),
            )));
  }
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PillChip(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 15, color: Theme.of(context).primaryColor),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        Text(label,
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).hintColor,
            )),
      ]),
    ]);
  }
}

// ── Pulsing green dot for LIVE indicator ─────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _NavigationPathFrame {
  final LatLng position;
  final double bearing;
  final List<LatLng> completed;
  final List<LatLng> remaining;

  const _NavigationPathFrame({
    required this.position,
    required this.bearing,
    required this.completed,
    required this.remaining,
  });
}
