import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class TripsEvent extends Equatable {}

class FetchTrips extends TripsEvent {
  final BuildContext context;
  final bool refresh;

  FetchTrips({
    @required this.context,
    @required this.refresh,
  })  : assert(context != null),
        assert(refresh != null);

  @override
  List<Object> get props => [context, refresh];
}
