import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../booking.dart';

abstract class BookingsEvent extends Equatable {}

class FetchBookings extends BookingsEvent {
  final BuildContext context;

  FetchBookings({
    @required this.context,
  }) : assert(context != null);

  @override
  List<Object> get props => [context];
}

class DeleteBooking extends BookingsEvent {
  final BuildContext context;
  final Booking booking;

  DeleteBooking({
    @required this.context,
    @required this.booking,
  })  : assert(context != null),
        assert(booking != null);

  @override
  List<Object> get props => [context, booking];
}
