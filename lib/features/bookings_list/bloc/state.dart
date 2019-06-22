import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookingsListState extends Equatable {
  BookingsListState([List props = const []]) : super(props);
}

class BookingsReady extends BookingsListState {
  final List<Booking> bookings;

  BookingsReady({
    @required this.bookings,
  })  : assert(bookings != null),
        super([bookings]);
}

class BookingsLoading extends BookingsListState {}

class BookingsError extends BookingsListState {
  final String message;

  BookingsError({
    @required this.message,
  })  : assert(message != null),
        super([message]);
}
