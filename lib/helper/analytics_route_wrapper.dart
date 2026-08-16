import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsRouteWrapper extends StatefulWidget {
  final Widget child;

  const AnalyticsRouteWrapper({super.key, required this.child});

  @override
  State<AnalyticsRouteWrapper> createState() => _AnalyticsRouteWrapperState();
}

class _AnalyticsRouteWrapperState extends State<AnalyticsRouteWrapper> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);

    if (route != null) {
      final routeName = route.settings.name ?? "unknown_route";
      final screenName = widget.child.runtimeType.toString();

      FirebaseAnalytics.instance.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenName,
      );

      FirebaseAnalytics.instance.logEvent(
        name: "screen_view",
        parameters: {
          "route": routeName,
          "screen": screenName,
        },
      );

      print("🔥 Auto Analytics → $screenName ($routeName)");
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
