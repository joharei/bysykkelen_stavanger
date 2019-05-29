class Station {
  final String id;
  final String name;
  final double lat;
  final double lon;
  final int freeBikes;

  Station(this.id, this.name, this.lat, this.lon, this.freeBikes);

  Station.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        lat = json['latitude'],
        lon = json['longitude'],
        freeBikes = json['free_bikes'];
}
