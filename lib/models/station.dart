import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final String id;
  final int uid;
  final String name;
  final double lat;
  final double lon;
  final int freeBikes;

  Station(this.id, this.uid, this.name, this.lat, this.lon, this.freeBikes);

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        json['id'],
        json['extra']['uid'],
        json['name'],
        json['latitude'],
        json['longitude'],
        json['free_bikes'],
      );

  @override
  List<Object> get props => [id, uid, name, lat, lon, freeBikes];
}
