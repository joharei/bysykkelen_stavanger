import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class BikesEvent extends Equatable {}

class StartPollingStations extends BikesEvent {
  final bool initialState;

  StartPollingStations({this.initialState = false});

  @override
  List<Object> get props => [initialState];
}

class StopPollingStations extends BikesEvent {
  @override
  List<Object> get props => [];
}

class FetchBikeStations extends BikesEvent {
  @override
  List<Object> get props => [];
}

class MarkerSelected extends BikesEvent {
  final String stationId;

  MarkerSelected({@required this.stationId}) : assert(stationId != null);

  @override
  List<Object> get props => [stationId];
}

class LocationUpdate extends BikesEvent {
  final LatLng userLocation;
  final bool hasPermission;

  LocationUpdate({
    @required this.userLocation,
    @required this.hasPermission,
  }) : assert(hasPermission != null);

  @override
  List<Object> get props => [userLocation, hasPermission];
}

class PageOnDispose extends BikesEvent {
  final CameraPosition cameraPosition;

  PageOnDispose({@required this.cameraPosition})
      : assert(cameraPosition != null);

  @override
  List<Object> get props => [cameraPosition];
}
