import 'dart:async';
import 'dart:io';

import 'package:bysykkelen_stavanger/features/map/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map/carousel.dart';
import 'package:bysykkelen_stavanger/shared/initial_position.dart';
import 'package:bysykkelen_stavanger/shared/safe_area_insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final BikeStationsBloc bikeStationsBloc;

  const MapPage({Key key, @required this.bikeStationsBloc}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  Completer<GoogleMapController> mapController = Completer();
  CameraPosition cameraPosition = initialPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final currentState = widget.bikeStationsBloc.currentState;
    if (currentState is BikesLoaded && currentState.cameraPosition != null) {
      cameraPosition = currentState.cameraPosition;
    }
    widget.bikeStationsBloc.dispatch(StartPollingStations(
      initialState: currentState is BikesLoading,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.bikeStationsBloc
        .dispatch(PageOnDispose(cameraPosition: cameraPosition));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.bikeStationsBloc.dispatch(StopPollingStations());
    } else if (state == AppLifecycleState.resumed) {
      widget.bikeStationsBloc.dispatch(StartPollingStations());
    }
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
    return BlocListener(
      bloc: widget.bikeStationsBloc,
      listener: (context, state) async {
        if (state is BikesLoaded &&
            state.userLocation != null &&
            state.zoomToLocation) {
          final controller = await mapController.future;
          controller.animateCamera(
              CameraUpdate.newLatLngZoom(state.userLocation, 14));
        }
      },
      child: BlocBuilder(
        bloc: widget.bikeStationsBloc,
        builder: (context, BikesState state) {
          return Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: cameraPosition,
                markers: _generateMarkers(state),
                padding: EdgeInsets.only(
                    bottom: safeAreaBottomInset(context) +
                        (Platform.isAndroid ? 165 : 135)),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                compassEnabled: true,
                onMapCreated: (controller) {
                  mapController.complete(controller);
                },
                onCameraMove: (cameraPosition) {
                  this.cameraPosition = cameraPosition;
                },
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: safeAreaBottomInset(context)),
                child: BlocProvider(
                  bloc: widget.bikeStationsBloc,
                  child: BikeCarousel(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
