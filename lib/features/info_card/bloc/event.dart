import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookBikeEvent extends Equatable {
  BookBikeEvent([List props = const []]) : super(props);
}

class BookBike extends BookBikeEvent {
  final String stationId;

  BookBike({@required this.stationId})
      : assert(stationId != null),
        super([stationId]);
}
