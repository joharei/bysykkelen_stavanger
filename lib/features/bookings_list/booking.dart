import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Booking extends Equatable {
  final String stationName;
  final String time;
  final String id;
  final String requestVerificationToken;

  Booking({
    @required this.stationName,
    @required this.time,
    @required this.id,
    @required this.requestVerificationToken,
  })  : assert(stationName != null),
        assert(time != null),
        assert(id != null),
        assert(requestVerificationToken != null),
        super([
          stationName,
          time,
          id,
          requestVerificationToken,
        ]);
}
