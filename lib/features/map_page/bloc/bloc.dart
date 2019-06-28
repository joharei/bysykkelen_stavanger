import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map_page/png_generator.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

class BikeStationsBloc extends Bloc<BikesEvent, BikesState> {
  final BikeRepository bikeRepository;
  Timer _pollingTimer;
  Location _locationService = Location();

  BikeStationsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BikesState get initialState => BikesLoaded(
        stations: {},
        markers: {},
        selectedMarkerId: null,
      );

  @override
  void dispose() {
    super.dispose();
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
  }

  @override
  Stream<BikesState> mapEventToState(BikesEvent event) async* {
    if (event is StartPollingStations) {
      _mapStartPollingToState(event);
    } else if (event is FetchBikeStations) {
      yield* _mapFetchBikeStationsToState(event);
    } else if (event is MarkerSelected && currentState is BikesLoaded) {
      yield* _mapMarkerSelectedToState(event);
    } else if (event is LocationUpdate && currentState is BikesLoaded) {
      yield (currentState as BikesLoaded).copyWith(
        userLocation: event.userLocation,
        hasPermission: event.hasPermission,
      );
    }
  }

  _mapStartPollingToState(StartPollingStations event) async {
    dispatch(FetchBikeStations());
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
    _pollingTimer = Timer.periodic(
        Duration(seconds: 30), (_) => dispatch(FetchBikeStations()));

    await _getLocation(event.initialState);
  }

  Future<void> _getLocation(bool initialState) async {
    try {
      var hasPermission = await _locationService.hasPermission();
      if (!hasPermission && initialState) {
        hasPermission = await _locationService.requestPermission();
      }

      LatLng userLocation;
      if (initialState && hasPermission) {
        final location = await _locationService.getLocation();
        userLocation = LatLng(
          location.latitude,
          location.longitude,
        );
      }
      dispatch(LocationUpdate(
        userLocation: userLocation,
        hasPermission: hasPermission,
      ));
    } catch (e) {}
  }

  Stream<BikesState> _mapFetchBikeStationsToState(
    FetchBikeStations event,
  ) async* {
    final state = currentState;

    if (!(state is BikesLoaded)) {
      yield BikesLoading();
    }

    try {
      final stations = await bikeRepository.getBikeStations();
      final stationsMap = Map<String, Station>.fromIterable(
        stations,
        key: (station) => station.id,
        value: (station) => station,
      );

      final markerIcons = await Future.wait(
        stations.map(
          (station) async => await generatePngForNumber(
            station.freeBikes,
            active:
                state is BikesLoaded && state.selectedMarkerId == station.id,
          ),
        ),
      );
      final markers =
          Map.fromIterables(stations, markerIcons).map((station, icon) {
        var marker = Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.lat, station.lon),
          icon: BitmapDescriptor.fromBytes(icon),
          anchor: Offset(0.5, 0.5),
          zIndex: 1,
          onTap: () => dispatch(MarkerSelected(stationId: station.id)),
          consumeTapEvents: true,
        );
        return MapEntry(station.id, marker);
      });

      if (state is BikesLoaded) {
        yield state.copyWith(
          stations: stationsMap,
          markers: markers,
        );
      } else {
        yield BikesLoaded(
          stations: stationsMap,
          markers: markers,
        );
      }
    } catch (e) {
      yield BikesError();
    }
  }

  Stream<BikesState> _mapMarkerSelectedToState(MarkerSelected event) async* {
    var state = currentState as BikesLoaded;
    var markers = Map<String, Marker>.from(state.markers);

    if (state.selectedMarkerId != null) {
      var oldMarker = markers[state.selectedMarkerId];
      var oldStation = state.stations[state.selectedMarkerId];
      var oldStationIcon = await generatePngForNumber(oldStation.freeBikes);
      markers[state.selectedMarkerId] = oldMarker.copyWith(
        iconParam: BitmapDescriptor.fromBytes(oldStationIcon),
        zIndexParam: 1,
      );
    }

    var station = state.stations[event.stationId];
    var newIcon = await generatePngForNumber(station.freeBikes, active: true);
    var oldMarker = markers[event.stationId];
    markers[event.stationId] = oldMarker.copyWith(
      iconParam: BitmapDescriptor.fromBytes(newIcon),
      zIndexParam: 2,
    );

    yield BikesLoaded(
      stations: state.stations,
      markers: markers,
      selectedMarkerId: event.stationId,
    );
  }
}
