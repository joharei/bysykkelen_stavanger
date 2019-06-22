import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookingsListState extends Equatable {
  BookingsListState([List props = const []]) : super(props);
}

class BookingsReady extends BookingsListState {
  final List<Booking> bookings;
  final String message;

  BookingsReady({
    @required this.bookings,
    this.message,
  })  : assert(bookings != null),
        super([bookings, message]);

  BookingsReady copyWith({
    List<Booking> bookings,
    String message,
  }) =>
      BookingsReady(
        bookings: bookings ?? this.bookings,
        message: message,
      );
}

class BookingsLoading extends BookingsListState {}

class BookingsError extends BookingsListState {
  final String message;

  BookingsError({
    @required this.message,
  })  : assert(message != null),
        super([message]);
}
