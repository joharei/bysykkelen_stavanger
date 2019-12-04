import 'package:bysykkelen_stavanger/features/trip_details/trip_details_page.dart';
import 'package:bysykkelen_stavanger/features/trips/trips_page.dart';
import 'package:flutter/material.dart';

class TripsRoutes {
  static const String root = '/';
  static const String details = '/details';
}

class TripsNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, Function(Object)> _routes;

  TripsNavigator({Key key, @required this.navigatorKey})
      : _routes = {
          TripsRoutes.root: (arguments) => TripsPage(),
          TripsRoutes.details: (arguments) => TripDetailsPage(trip: arguments),
        },
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TripsRoutes.root,
      onGenerateRoute: (routeSettings) => MaterialPageRoute(
        builder: (context) =>
            _routes[routeSettings.name](routeSettings.arguments),
      ),
    );
  }
}
