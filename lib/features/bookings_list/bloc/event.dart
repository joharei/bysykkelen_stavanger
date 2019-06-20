import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class BookingsEvent extends Equatable {
  BookingsEvent([List props = const []]) : super(props);
}

class FetchBookings extends BookingsEvent {
  BuildContext context;

  FetchBookings({
    @required this.context,
  })  : assert(context != null),
        super([context]);
}
