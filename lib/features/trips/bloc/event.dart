import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class TripsEvent extends Equatable {
  TripsEvent([List props = const []]) : super(props);
}

class FetchTrips extends TripsEvent {
  final BuildContext context;

  FetchTrips({
    @required this.context,
  })  : assert(context != null),
        super([context]);
}
