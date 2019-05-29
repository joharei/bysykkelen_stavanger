import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final int freeBikes;

  Station(this.id, this.name, this.lat, this.lon, this.freeBikes)
      : super([id, name, lat, lon, freeBikes]);

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        json['id'],
        json['name'],
        json['latitude'],
        json['longitude'],
        json['free_bikes'],
      );
}
