import 'dart:async';
import 'dart:io';

import 'package:bysykkelen_stavanger/features/main_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/state.dart';
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
  const MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  Completer<GoogleMapController> mapController = Completer();
  CameraPosition cameraPosition = initialPosition;
  bool cameraPositionRestored = false;

  @override
  void initState() {
    super.initState();
    _togglePolling();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      BlocProvider.of<BikeStationsBloc>(context).add(StopPollingStations());
    } else if (state == AppLifecycleState.resumed) {
      BlocProvider.of<BikeStationsBloc>(context).add(StartPollingStations());
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
    return MultiBlocListener(
      listeners: [
        BlocListener<MainBloc, MainState>(
          condition: (prevState, state) => prevState.navIndex != state.navIndex,
          listener: (context, state) {
            _togglePolling();
          },
        ),
        BlocListener<BikeStationsBloc, BikesState>(
          listener: (context, state) async {
            if (state is BikesLoaded &&
                state.userLocation != null &&
                state.zoomToLocation) {
              final controller = await mapController.future;
              controller.animateCamera(
                  CameraUpdate.newLatLngZoom(state.userLocation, 14));
            }
          },
        ),
        BlocListener<BikeStationsBloc, BikesState>(
          condition: (prevState, state) =>
              !cameraPositionRestored &&
              state is BikesLoaded &&
              state.cameraPosition != null,
          listener: (context, state) {
            setState(() {
              cameraPosition = (state as BikesLoaded).cameraPosition;
              cameraPositionRestored = true;
            });
          },
        )
      ],
      child: BlocBuilder<BikeStationsBloc, BikesState>(
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
                child: BikeCarousel(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _togglePolling() {
    final mainBloc = BlocProvider.of<MainBloc>(context);
    final bikeStationsBloc = BlocProvider.of<BikeStationsBloc>(context);

    if (mainBloc.state.navIndex == 0) {
      bikeStationsBloc.add(StartPollingStations(
        initialState: bikeStationsBloc.state is BikesLoading,
      ));
    } else {
      bikeStationsBloc.add(PageOnDispose(cameraPosition: cameraPosition));
    }
  }
}
