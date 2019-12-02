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
  });

  @override
  List<Object> get props => [
        fromStation,
        fromDate,
        toStation,
        toDate,
        price,
        detailsUrl,
      ];
}
