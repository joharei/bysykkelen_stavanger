import 'package:bysykkelen_stavanger/features/trip_details/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/trip.dart';
import 'package:bysykkelen_stavanger/shared/initial_position.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/safe_area_insets.dart';
import 'package:flutter/material.dart';
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
    return Column(
      children: [
        Text(
          Localization.of(context)
              .fromTo(state.trip.fromStation, state.trip.toStation),
        ),
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: initialPosition,
          padding: EdgeInsets.only(bottom: safeAreaBottomInset(context)),
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          compassEnabled: true,
        ),
      ],
    );
  }
}
