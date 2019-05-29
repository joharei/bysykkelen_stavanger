import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BikesState extends Equatable {
  BikesState([List props = const []]) : super(props);
}

class BikesLoading extends BikesState {}

class BikesError extends BikesState {}

class BikesLoaded extends BikesState {
  final List<Station> stations;

  BikesLoaded({@required this.stations})
      : assert(stations != null),
        super(stations);
}
