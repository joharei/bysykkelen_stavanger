import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map_page/png_generator.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class BikeStationsBloc extends Bloc<BikesEvent, BikesState> {
  final BikeRepository bikeRepository;
  Timer _pollingTimer;

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
      _mapStartPollingToState();
    } else if (event is FetchBikeStations) {
      yield* _mapFetchBikeStationsToState();
    } else if (event is MarkerSelected && currentState is BikesLoaded) {
      yield* _mapMarkerSelectedToState(event);
    }
  }

  _mapStartPollingToState() {
    dispatch(FetchBikeStations());
    if (_pollingTimer != null) {
      _pollingTimer.cancel();
    }
    _pollingTimer = Timer.periodic(
        Duration(seconds: 30), (_) => dispatch(FetchBikeStations()));
  }

  Stream<BikesState> _mapFetchBikeStationsToState() async* {
    if (!(currentState is BikesLoaded)) {
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
          (station) async => await generatePngForNumber(station.freeBikes),
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

      String selectedMarkerId;
      if (currentState is BikesLoaded) {
        selectedMarkerId = (currentState as BikesLoaded).selectedMarkerId;
      }

      yield BikesLoaded(
        stations: stationsMap,
        markers: markers,
        selectedMarkerId: selectedMarkerId,
      );
    } catch (e) {
      print(e);
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
