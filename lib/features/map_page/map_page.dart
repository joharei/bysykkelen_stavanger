import 'package:bysykkelen_stavanger/features/map_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final BikeRepository bikeRepository;
  static final _stavanger = CameraPosition(
    target: LatLng(58.9109397, 5.7244898),
    zoom: 11.5,
  );

  const MapPage({
    Key key,
    @required this.bikeRepository,
  })  : assert(bikeRepository != null),
        super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  BikeStationsBloc _bikeStationsBloc;

  @override
  void initState() {
    super.initState();
    _bikeStationsBloc = BikeStationsBloc(bikeRepository: widget.bikeRepository);
    _bikeStationsBloc.dispatch(BikesEvent.start);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bikeStationsBloc,
      builder: (_, state) {
        Set<Marker> markers = {};
        if (state is BikesLoaded) {
          for (var station in state.stations) {
            markers.add(
              Marker(
                markerId: MarkerId(station.id),
                position: LatLng(station.lat, station.lon),
                infoWindow: InfoWindow(
                  title: station.name,
                  snippet: 'Free bikes: ${station.freeBikes}',
                ),
              ),
            );
          }
        }
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: MapPage._stavanger,
          markers: markers,
        );
      },
    );
  }
}
