import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TripDetailsState extends Equatable {
  final Trip trip;

  TripDetailsState(this.trip, [List props = const []]) : super(props + [trip]);
}

class InitialTripDetailsState extends TripDetailsState {
  InitialTripDetailsState(Trip trip) : super(trip);
}

class LoadedTripDetailsState extends TripDetailsState {
  final List<LatLng> points;
  final LatLngBounds bounds;

  LoadedTripDetailsState(Trip trip, this.points, this.bounds)
      : super(trip, [points, bounds]);
}
