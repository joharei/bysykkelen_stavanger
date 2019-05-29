import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BikesEvent extends Equatable {
  BikesEvent([List props = const []]) : super(props);
}

class StartPollingStations extends BikesEvent {}

class StopPollingStations extends BikesEvent {}

class FetchBikeStations extends BikesEvent {}

class MarkerSelected extends BikesEvent {
  final String stationId;

  MarkerSelected({@required this.stationId})
      : assert(stationId != null),
        super([stationId]);
}
