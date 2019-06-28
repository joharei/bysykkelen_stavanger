import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class BikesEvent extends Equatable {
  BikesEvent([List props = const []]) : super(props);
}

class StartPollingStations extends BikesEvent {
  final bool initialState;

  StartPollingStations({this.initialState = false}) : super([initialState]);
}

class StopPollingStations extends BikesEvent {}

class FetchBikeStations extends BikesEvent {}

class MarkerSelected extends BikesEvent {
  final String stationId;

  MarkerSelected({@required this.stationId})
      : assert(stationId != null),
        super([stationId]);
}

class LocationUpdate extends BikesEvent {
  final LatLng userLocation;
  final bool hasPermission;

  LocationUpdate({
    @required this.userLocation,
    @required this.hasPermission,
  })  : assert(hasPermission != null),
        super([userLocation, hasPermission]);
}
