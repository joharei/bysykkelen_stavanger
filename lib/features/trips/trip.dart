import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class Trip extends Equatable {
  final String fromStation;
  final String fromDate;
  final String toStation;
  final String toDate;
  final String price;
  final String detailsUrl;

  Trip({
    @required this.fromStation,
    @required this.fromDate,
    @required this.toStation,
    @required this.toDate,
    @required this.price,
    @required this.detailsUrl,
  }) : super([
          fromStation,
          fromDate,
          toStation,
          toDate,
          price,
          detailsUrl,
        ]);
}
