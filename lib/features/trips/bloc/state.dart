import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class TripsListState extends Equatable {
  TripsListState([List props = const []]) : super(props);
}

class TripsReady extends TripsListState {
  final List<Trip> trips;
  final bool hasReachedEnd;
  final bool refreshing;

  TripsReady({
    @required this.trips,
    @required this.hasReachedEnd,
    @required this.refreshing,
  })  : assert(trips != null),
        assert(hasReachedEnd != null),
        assert(refreshing != null),
        super([trips, hasReachedEnd, refreshing]);

  TripsReady copyWith({
    List<Trip> trips,
    bool hasReachedEnd,
    bool refreshing,
  }) =>
      TripsReady(
        trips: trips ?? this.trips,
        hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
        refreshing: refreshing ?? this.refreshing,
      );
}

class TripsError extends TripsListState {
  final String message;

  TripsError({
    @required this.message,
  })  : assert(message != null),
        super([message]);
}
