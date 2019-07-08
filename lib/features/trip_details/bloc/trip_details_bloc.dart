import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trip_details/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kiwi/kiwi.dart';

class TripDetailsBloc extends Bloc<TripDetailsEvent, TripDetailsState> {
  final BikeRepository _bikeRepository;
  final Trip _trip;

  TripDetailsBloc(this._trip) : _bikeRepository = Container().resolve();

  void fetchTripDetails() {
    dispatch(FetchTripDetails());
  }

  @override
  TripDetailsState get initialState => InitialTripDetailsState(_trip);

  @override
  Stream<TripDetailsState> mapEventToState(TripDetailsEvent event) async* {
    if (event is FetchTripDetails) {
      final details = await _bikeRepository.fetchTripDetails(_trip);
      final northeast = details.points.reduce(
        (point1, point2) => LatLng(
          max(point1.latitude, point2.latitude),
          max(point1.longitude, point2.longitude),
        ),
      );
      final southwest = details.points.reduce(
        (point1, point2) => LatLng(
          min(point1.latitude, point2.latitude),
          min(point1.longitude, point2.longitude),
        ),
      );

      var pairs = <List<LatLng>>[];
      for (var i = 0; i < details.points.length - 1; i += 1) {
        pairs.add(details.points.sublist(i, i + 2));
      }
      final distances = await Future.wait(
        pairs.map(
          (pair) => Geolocator().distanceBetween(
            pair[0].latitude,
            pair[0].longitude,
            pair[1].latitude,
            pair[1].longitude,
          ),
        ),
      );
      final distance = distances.reduce((d1, d2) => d1 + d2).round();

      yield LoadedTripDetailsState(
        details.trip,
        details.points,
        LatLngBounds(
          northeast: northeast,
          southwest: southwest,
        ),
        distance,
      );
    }
  }
}
