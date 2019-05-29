import 'dart:async';

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
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _bikeStationsBloc = BikeStationsBloc(bikeRepository: widget.bikeRepository);
    _bikeStationsBloc.dispatch(StartPollingStations());
  }

  Set<Marker> _generateMarkers(BikesState state) {
    Set<Marker> markers = {};
    if (state is BikesLoaded) {
      markers = Set.of(state.markers.values);
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bikeStationsBloc,
      builder: (_, BikesState state) => GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: MapPage._stavanger,
            markers: _generateMarkers(state),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
    );
  }

  @override
  void dispose() {
    _bikeStationsBloc.dispose();
    super.dispose();
  }
}
