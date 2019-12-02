import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Booking extends Equatable {
  final String stationName;
  final String time;
  final String id;
  final String requestVerificationToken;
  final String deleteUrl;

  Booking({
    @required this.stationName,
    @required this.time,
    @required this.id,
    @required this.requestVerificationToken,
    @required this.deleteUrl,
  })  : assert(stationName != null),
        assert(time != null),
        assert(id != null),
        assert(requestVerificationToken != null),
        assert(deleteUrl != null);

  @override
  List<Object> get props => [
        stationName,
        time,
        id,
        requestVerificationToken,
        deleteUrl,
      ];
}
