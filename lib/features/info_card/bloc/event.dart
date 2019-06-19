import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookBikeEvent extends Equatable {
  BookBikeEvent([List props = const []]) : super(props);
}

class BookBike extends BookBikeEvent {
  final Station station;
  final DateTime bookingDateTime;
  final DateTime minimumDateTime;
  final String userName;
  final String password;

  BookBike({
    @required this.station,
    @required this.bookingDateTime,
    @required this.minimumDateTime,
    @required this.userName,
    @required this.password,
  })  : assert(station != null),
        assert(bookingDateTime != null),
        assert(minimumDateTime != null),
        assert(userName != null),
        assert(password != null),
        super([
          station,
          bookingDateTime,
          minimumDateTime,
          userName,
          password,
        ]);
}
