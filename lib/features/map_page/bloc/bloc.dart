import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map_page/png_generator.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:meta/meta.dart';

class BikeStationsBloc extends Bloc<BikesEvent, BikesState> {
  final BikeRepository bikeRepository;
  Timer _pollingTimer;
  Geolocator _locationService = Geolocator();

  BikeStationsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BikesState get initialState => BikesLoaded(
        stations: [],
        idToStation: {},
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
    final state = currentState;

    if (event is StartPollingStations) {
      _mapStartPollingToState(event);
    } else if (event is FetchBikeStations) {
      yield* _mapFetchBikeStationsToState(event);
    } else if (event is MarkerSelected && state is BikesLoaded) {
      yield* _mapMarkerSelectedToState(event);
    } else if (event is LocationUpdate && state is BikesLoaded) {
      final stations = state.stations;
      await _sortStationsByDistanceToUser(stations, event.userLocation);
      yield state.copyWith(
        userLocation: event.userLocation,
        zoomToLocation: true,
        hasPermission: event.hasPermission,
        stations: stations,
      );
      dispatch(MarkerSelected(stationId: stations[0].id));
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
      var hasPermission =
          await _locationService.checkGeolocationPermissionStatus() ==
              GeolocationStatus.granted;
      if (!hasPermission && initialState) {
        hasPermission = await LocationPermissions().requestPermissions(
              permissionLevel: LocationPermissionLevel.locationWhenInUse,
            ) ==
            PermissionStatus.granted;
      }

      LatLng userLocation;
      if (initialState && hasPermission) {
        final location = await _locationService.getLastKnownPosition();
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
      if (state is BikesLoaded && state.userLocation != null) {
        await _sortStationsByDistanceToUser(stations, state.userLocation);
      }
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
          stations: stations,
          idToStation: stationsMap,
          markers: markers,
        );
      } else {
        yield BikesLoaded(
          stations: stations,
          idToStation: stationsMap,
          markers: markers,
        );
      }
    } catch (e) {
      yield BikesError();
    }
  }

  Future _sortStationsByDistanceToUser(
    List<Station> stations,
    LatLng userLocation,
  ) async {
    final distances = await Future.wait(
        stations.map((station) => _locationService.distanceBetween(
              userLocation.latitude,
              userLocation.longitude,
              station.lat,
              station.lon,
            )));
    final stationToDistance = Map<Station, double>.fromIterables(
      stations,
      distances,
    );
    stations.sort((stationA, stationB) =>
        (stationToDistance[stationA] - stationToDistance[stationB]).toInt());
  }

  Stream<BikesState> _mapMarkerSelectedToState(MarkerSelected event) async* {
    var state = currentState as BikesLoaded;
    var markers = Map<String, Marker>.from(state.markers);

    if (state.selectedMarkerId != null) {
      var oldMarker = markers[state.selectedMarkerId];
      var oldStation = state.idToStation[state.selectedMarkerId];
      var oldStationIcon = await generatePngForNumber(oldStation.freeBikes);
      markers[state.selectedMarkerId] = oldMarker.copyWith(
        iconParam: BitmapDescriptor.fromBytes(oldStationIcon),
        zIndexParam: 1,
      );
    }

    var station = state.idToStation[event.stationId];
    var newIcon = await generatePngForNumber(station.freeBikes, active: true);
    var oldMarker = markers[event.stationId];
    markers[event.stationId] = oldMarker.copyWith(
      iconParam: BitmapDescriptor.fromBytes(newIcon),
      zIndexParam: 2,
    );

    yield state.copyWith(
      markers: markers,
      selectedMarkerId: event.stationId,
    );
  }
}
