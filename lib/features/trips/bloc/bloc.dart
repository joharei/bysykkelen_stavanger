import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class TripsBloc extends Bloc<TripsEvent, TripsListState> {
  final BikeRepository _bikeRepository;

  TripsBloc() : _bikeRepository = kiwi.Container().resolve();

  void getNextListPage(BuildContext context) {
    add(FetchTrips(context: context, refresh: false));
  }

  void refresh(BuildContext context) {
    add(FetchTrips(context: context, refresh: true));
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
    final currentState = state;
    if (currentState is TripsReady && currentState.trips.isEmpty) {
      yield currentState.copyWith(refreshing: true);
    }

    var clearCookies = false;
    if (!await _bikeRepository.loggedIn()) {
      final userNameAndPassword = await promptForUsernameAndPassword(context);
      if (userNameAndPassword == null) {
        yield TripsError(message: Localization.of(context).loginFailed);
        return;
      }

      clearCookies = !userNameAndPassword.saveCredentials;

      await _bikeRepository.login(
        userNameAndPassword.userName,
        userNameAndPassword.password,
      );
    }

    try {
      final page = !refresh && currentState is TripsReady
          ? (currentState.trips.length / 10).ceil()
          : 0;
      final trips = await _bikeRepository.fetchTrips(page);

      final List<Trip> existingTrips =
          !refresh && currentState is TripsReady ? currentState.trips : [];

      yield TripsReady(
        trips: existingTrips + trips,
        refreshing: false,
        hasReachedEnd: false,
      );
    } on NoNextPageException catch (_) {
      if (currentState is TripsReady) {
        yield currentState.copyWith(hasReachedEnd: true, refreshing: false);
      } else {
        yield TripsError(message: Localization.of(context).tripsFailed);
      }
    } on ScrapingException catch (_) {
      yield TripsError(message: Localization.of(context).tripsFailed);
    }

    if (clearCookies) {
      await _bikeRepository.clearCookies();
    }
  }
}
