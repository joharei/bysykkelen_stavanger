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
  final Map<String, Station> stations;
  final Map<String, Marker> markers;
  final String selectedMarkerId;

  BikesLoaded({
    @required this.stations,
    @required this.markers,
    @required this.selectedMarkerId,
  })  : assert(stations != null),
        assert(markers != null),
        super([stations, markers, selectedMarkerId]);
}
