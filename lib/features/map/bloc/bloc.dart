import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map/png_generator.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kiwi/kiwi.dart';
import 'package:location_permissions/location_permissions.dart';

class BikeStationsBloc extends Bloc<BikesEvent, BikesState> {
  final BikeRepository _bikeRepository;
  Timer _pollingTimer;
  Geolocator _locationService = Geolocator();

  BikeStationsBloc() : _bikeRepository = Container().resolve();

  @override
  BikesState get initialState => BikesLoading();

  @override
  Future<void> close() {
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
    return super.close();
  }

  @override
  Stream<BikesState> mapEventToState(BikesEvent event) async* {
    final currentState = state;

    if (event is StartPollingStations) {
      _mapStartPollingToState(event);
    } else if (event is FetchBikeStations) {
      yield* _mapFetchBikeStationsToState(event);
    } else if (event is MarkerSelected && currentState is BikesLoaded) {
      yield* _mapMarkerSelectedToState(event);
    } else if (event is LocationUpdate && currentState is BikesLoaded) {
      final stations = currentState.stations;
      await _sortStationsByDistanceToUser(stations, event.userLocation);
      yield currentState.copyWith(
        userLocation: event.userLocation,
        zoomToLocation: true,
        hasPermission: event.hasPermission,
        stations: stations,
      );
      add(MarkerSelected(stationId: stations[0].id));
    } else if (event is PageOnDispose && currentState is BikesLoaded) {
      yield currentState.copyWith(cameraPosition: event.cameraPosition);
    }
  }

  _mapStartPollingToState(StartPollingStations event) async {
    add(FetchBikeStations());
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
    _pollingTimer =
        Timer.periodic(Duration(seconds: 30), (_) => add(FetchBikeStations()));

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
      add(LocationUpdate(
        userLocation: userLocation,
        hasPermission: hasPermission,
      ));
    } catch (e) {}
  }

  Stream<BikesState> _mapFetchBikeStationsToState(
    FetchBikeStations event,
  ) async* {
    final currentState = state;

    if (!(currentState is BikesLoaded)) {
      yield BikesLoading();
    }

    try {
      final stations = await _bikeRepository.getBikeStations();
      if (currentState is BikesLoaded && currentState.userLocation != null) {
        await _sortStationsByDistanceToUser(
            stations, currentState.userLocation);
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
            active: currentState is BikesLoaded &&
                currentState.selectedMarkerId == station.id,
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
          onTap: () => add(MarkerSelected(stationId: station.id)),
          consumeTapEvents: true,
        );
        return MapEntry(station.id, marker);
      });

      if (currentState is BikesLoaded) {
        yield currentState.copyWith(
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
    var currentState = state as BikesLoaded;
    var markers = Map<String, Marker>.from(currentState.markers);

    if (currentState.selectedMarkerId != null) {
      var oldMarker = markers[currentState.selectedMarkerId];
      var oldStation = currentState.idToStation[currentState.selectedMarkerId];
      var oldStationIcon = await generatePngForNumber(oldStation.freeBikes);
      markers[currentState.selectedMarkerId] = oldMarker.copyWith(
        iconParam: BitmapDescriptor.fromBytes(oldStationIcon),
        zIndexParam: 1,
      );
    }

    var station = currentState.idToStation[event.stationId];
    var newIcon = await generatePngForNumber(station.freeBikes, active: true);
    var oldMarker = markers[event.stationId];
    markers[event.stationId] = oldMarker.copyWith(
      iconParam: BitmapDescriptor.fromBytes(newIcon),
      zIndexParam: 2,
    );

    yield currentState.copyWith(
      markers: markers,
      selectedMarkerId: event.stationId,
    );
  }
}
