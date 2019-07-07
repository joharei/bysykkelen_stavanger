import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TripDetailsEvent extends Equatable {
  TripDetailsEvent([List props = const []]) : super(props);
}

class FetchTripDetails extends TripDetailsEvent {}
