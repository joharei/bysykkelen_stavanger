import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookingsListState extends Equatable {
  BookingsListState([List props = const []]) : super(props);
}

class BookingsReady extends BookingsListState {
  final List<Booking> bookings;
  final bool refreshing;

  BookingsReady({
    @required this.bookings,
    @required this.refreshing,
  })  : assert(bookings != null),
        assert(refreshing != null),
        super([bookings, refreshing]);

  BookingsReady copyWith({
    List<Booking> bookings,
    bool refreshing,
    String message,
  }) =>
      BookingsReady(
        bookings: bookings ?? this.bookings,
        refreshing: refreshing ?? this.refreshing,
      );
}

class BookingsError extends BookingsListState {
  final String message;

  BookingsError({
    @required this.message,
  })  : assert(message != null),
        super([message]);
}
