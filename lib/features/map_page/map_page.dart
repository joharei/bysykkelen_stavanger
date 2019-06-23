import 'package:bysykkelen_stavanger/features/bookings_list/bookings_list_page.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map_page/carousel.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/safe_area_insets.dart';
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

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  BikeStationsBloc _bikeStationsBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bikeStationsBloc = BikeStationsBloc(bikeRepository: widget.bikeRepository);
    _bikeStationsBloc.dispatch(StartPollingStations());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _bikeStationsBloc.dispatch(StopPollingStations());
    } else if (state == AppLifecycleState.resumed) {
      _bikeStationsBloc.dispatch(StartPollingStations());
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
    return BlocBuilder(
      bloc: _bikeStationsBloc,
      builder: (context, BikesState state) {
        return Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: MapPage._stavanger,
              markers: _generateMarkers(state),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: safeAreaBottomInset(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 16,
                      right: MediaQuery.of(context).size.width * 0.05 + 6,
                    ),
                    child: FloatingActionButton(
                      onPressed: () => BookingsListPage.show(context),
                      child: Icon(Icons.view_list),
                      tooltip: Localization.of(context).bookings,
                    ),
                  ),
                  BlocProvider(
                    bloc: _bikeStationsBloc,
                    child: BikeCarousel(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bikeStationsBloc.dispose();
    super.dispose();
  }
}
