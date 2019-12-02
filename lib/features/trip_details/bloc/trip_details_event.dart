import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TripDetailsEvent extends Equatable {}

class FetchTripDetails extends TripDetailsEvent {
  @override
  List<Object> get props => [];
}
