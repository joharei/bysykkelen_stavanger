import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class TripsBloc extends Bloc<TripsEvent, TripsListState> {
  final BikeRepository bikeRepository;

  TripsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  TripsListState get initialState => TripsReady(
        trips: [],
        refreshing: true,
      );

  @override
  Stream<TripsListState> mapEventToState(TripsEvent event) async* {
    if (event is FetchTrips) {
      yield* _fetchTrips(event.context);
    }
  }

  Stream<TripsListState> _fetchTrips(BuildContext context) async* {
    if (currentState is TripsReady) {
      yield (currentState as TripsReady).copyWith(refreshing: true);
    }

    var clearCookies = false;
    if (!await bikeRepository.loggedIn()) {
      final userNameAndPassword = await promptForUsernameAndPassword(context);
      if (userNameAndPassword == null) {
        yield TripsError(message: Localization.of(context).loginFailed);
        return;
      }

      clearCookies = !userNameAndPassword.saveCredentials;

      await bikeRepository.login(
        userNameAndPassword.userName,
        userNameAndPassword.password,
      );
    }

    final trips = await bikeRepository.fetchTrips();

    if (clearCookies) {
      await bikeRepository.clearCookies();
    }

    if (trips != null) {
      yield TripsReady(trips: trips, refreshing: false);
    } else {
      yield TripsError(message: Localization.of(context).tripsFailed);
    }
  }
}
