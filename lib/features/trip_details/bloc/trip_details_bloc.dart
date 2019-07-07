import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trip_details/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
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

      yield LoadedTripDetailsState(
        details.trip,
        details.points,
        LatLngBounds(
          northeast: northeast,
          southwest: southwest,
        ),
      );
    }
  }
}
