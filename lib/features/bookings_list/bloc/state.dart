import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookingsListState extends Equatable {
  BookingsListState([List props = const []]) : super(props);
}

class BookingsReady extends BookingsListState {
  final List<Booking> bookings;
  final String message;
  final bool refreshing;

  BookingsReady({
    @required this.bookings,
    @required this.refreshing,
    this.message,
  })  : assert(bookings != null),
        assert(refreshing != null),
        super([bookings, refreshing, message]);

  BookingsReady copyWith({
    List<Booking> bookings,
    bool refreshing,
    String message,
  }) =>
      BookingsReady(
        bookings: bookings ?? this.bookings,
        refreshing: refreshing ?? this.refreshing,
        message: message,
      );
}

class BookingsError extends BookingsListState {
  final String message;

  BookingsError({
    @required this.message,
  })  : assert(message != null),
        super([message]);
}
