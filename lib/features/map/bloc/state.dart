import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

abstract class BikesState extends Equatable {
  BikesState([List props = const []]) : super(props);
}

class BikesLoading extends BikesState {}

class BikesError extends BikesState {}

class BikesLoaded extends BikesState {
  final List<Station> stations;
  final Map<String, Station> idToStation;
  final Map<String, Marker> markers;
  final String selectedMarkerId;
  final LatLng userLocation;
  final bool zoomToLocation;
  final bool hasPermission;
  final CameraPosition cameraPosition;
  bool get wasResumed => cameraPosition != null;

  BikesLoaded({
    @required this.stations,
    @required this.idToStation,
    @required this.markers,
    this.selectedMarkerId,
    this.userLocation,
    this.zoomToLocation = false,
    this.hasPermission = false,
    this.cameraPosition,
  })  : assert(stations != null),
        assert(idToStation != null),
        assert(markers != null),
        super([
          stations,
          idToStation,
          markers,
          selectedMarkerId,
          userLocation,
          zoomToLocation,
          hasPermission,
          cameraPosition,
        ]);

  BikesLoaded copyWith({
    List<Station> stations,
    Map<String, Station> idToStation,
    Map<String, Marker> markers,
    String selectedMarkerId,
    LatLng userLocation,
    bool zoomToLocation,
    bool hasPermission,
    CameraPosition cameraPosition,
  }) =>
      BikesLoaded(
        stations: stations ?? this.stations,
        idToStation: idToStation ?? this.idToStation,
        markers: markers ?? this.markers,
        selectedMarkerId: selectedMarkerId ?? this.selectedMarkerId,
        userLocation: userLocation ?? this.userLocation,
        hasPermission: hasPermission ?? this.hasPermission,
        // One-offs
        zoomToLocation: zoomToLocation ?? false,
        cameraPosition: cameraPosition,
      );
}
