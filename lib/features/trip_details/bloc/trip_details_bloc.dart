import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trip_details/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/trip.dart';

class TripDetailsBloc extends Bloc<TripDetailsEvent, TripDetailsState> {
  final Trip _trip;

  TripDetailsBloc(this._trip);

  @override
  TripDetailsState get initialState => InitialTripDetailsState(_trip);

  @override
  Stream<TripDetailsState> mapEventToState(
    TripDetailsEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
