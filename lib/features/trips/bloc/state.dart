import 'package:bysykkelen_stavanger/features/trips/Trip.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class TripsListState extends Equatable {
  TripsListState([List props = const []]) : super(props);
}

class TripsReady extends TripsListState {
  final List<Trip> trips;
  final bool refreshing;

  TripsReady({
    @required this.trips,
    @required this.refreshing,
  })  : assert(trips != null),
        assert(refreshing != null),
        super([trips, refreshing]);

  TripsReady copyWith({
    List<Trip> trips,
    bool refreshing,
    String message,
  }) =>
      TripsReady(
        trips: trips ?? this.trips,
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
