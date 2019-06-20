import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookingsListState extends Equatable {
  BookingsListState([List props = const []]) : super(props);
}

class BookingsReady extends BookingsListState {}

class BookingsLoading extends BookingsListState {}

class BookingsError extends BookingsListState {
  final String message;

  BookingsError({
    @required this.message,
  })  : assert(message != null),
        super([message]);
}
