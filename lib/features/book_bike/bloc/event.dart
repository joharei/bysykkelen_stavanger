import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class BookBikeEvent extends Equatable {}

class BookBike extends BookBikeEvent {
  final Station station;
  final DateTime bookingDateTime;
  final DateTime minimumDateTime;
  final BuildContext context;

  BookBike({
    @required this.station,
    @required this.bookingDateTime,
    @required this.minimumDateTime,
    @required this.context,
  })  : assert(station != null),
        assert(bookingDateTime != null),
        assert(minimumDateTime != null),
        assert(context != null);

  @override
  List<Object> get props => [
        station,
        bookingDateTime,
        minimumDateTime,
        context,
      ];
}
