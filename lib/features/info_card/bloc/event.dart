import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class BookBikeEvent extends Equatable {
  BookBikeEvent([List props = const []]) : super(props);
}

class BookBike extends BookBikeEvent {
  final int stationUid;

  BookBike({@required this.stationUid})
      : assert(stationUid != null),
        super([stationUid]);
}
