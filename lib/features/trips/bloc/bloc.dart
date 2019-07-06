import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/Trip.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class TripsBloc extends Bloc<TripsEvent, TripsListState> {
  final BikeRepository bikeRepository;

  TripsBloc({@required this.bikeRepository}) : assert(bikeRepository != null);

  void getNextListPage(BuildContext context) {
    dispatch(FetchTrips(context: context, refresh: false));
  }

  void refresh(BuildContext context) {
    dispatch(FetchTrips(context: context, refresh: true));
  }

  @override
  TripsListState get initialState => TripsReady(
        trips: [],
        hasReachedEnd: false,
        refreshing: true,
      );

  @override
  Stream<TripsListState> mapEventToState(TripsEvent event) async* {
    if (event is FetchTrips) {
      yield* _fetchTrips(event.context, event.refresh);
    }
  }

  Stream<TripsListState> _fetchTrips(
    BuildContext context,
    bool refresh,
  ) async* {
    final state = currentState;
    if (state is TripsReady && state.trips.isEmpty) {
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

    try {
      final page = !refresh && state is TripsReady
          ? (state.trips.length / 10).ceil()
          : 0;
      final trips = await bikeRepository.fetchTrips(page);

      final List<Trip> existingTrips = !refresh && state is TripsReady ? state.trips : [];

      yield TripsReady(
        trips: existingTrips + trips,
        refreshing: false,
        hasReachedEnd: false,
      );
    } on NoNextPageException catch (_) {
      if (state is TripsReady) {
        yield state.copyWith(hasReachedEnd: true, refreshing: false);
      } else {
        yield TripsError(message: Localization.of(context).tripsFailed);
      }
    } on ScrapingException catch (_) {
      yield TripsError(message: Localization.of(context).tripsFailed);
    }

    if (clearCookies) {
      await bikeRepository.clearCookies();
    }
  }
}
