import 'package:bysykkelen_stavanger/features/trip_details/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:bysykkelen_stavanger/shared/initial_position.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/safe_area_insets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetailsPage extends StatefulWidget {
  final Trip trip;

  const TripDetailsPage({Key key, @required this.trip}) : super(key: key);

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  TripDetailsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = TripDetailsBloc(widget.trip);
    _bloc.fetchTripDetails();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, TripDetailsState state) => Scaffold(
        appBar: AppBar(
          title: Text(
            Localization.of(context).toStation(state.trip.toStation),
          ),
        ),
        body: state is LoadedTripDetailsState
            ? _buildDetailsPage(state)
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildDetailsPage(LoadedTripDetailsState state) {
    String distance;
    if (state.distanceInMeters >= 1000) {
      final km = state.distanceInMeters / 1000;
      distance =
          km.toStringAsFixed(km.truncateToDouble() == km ? 0 : 1) + ' km';
    } else {
      distance = '${state.distanceInMeters} m';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localization.of(context)
                    .fromTo(state.trip.fromStation, state.trip.toStation),
                style: Theme.of(context).textTheme.subhead,
              ),
              Text(
                '${state.trip.fromDate} - ${state.trip.toDate}',
                style: Theme.of(context).textTheme.subhead,
              ),
              Text(
                Localization.of(context).distance(distance),
                style: Theme.of(context).textTheme.subhead,
              ),
              Text(
                Localization.of(context).price(state.trip.price),
                style: Theme.of(context).textTheme.subhead,
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Expanded(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: initialPosition,
            padding: EdgeInsets.only(bottom: safeAreaBottomInset(context)),
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            compassEnabled: true,
            polylines: {
              Polyline(
                polylineId: PolylineId(state.trip.detailsUrl),
                color: Theme.of(context).primaryColor,
                points: state.points,
                width: 16,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              )
            },
            onMapCreated: (controller) {
              WidgetsBinding.instance.addPostFrameCallback((_) => controller
                  .moveCamera(CameraUpdate.newLatLngBounds(state.bounds, 16)));
            },
          ),
        ),
      ],
    );
  }
}
