import 'dart:async';
import 'dart:io';

import 'package:bysykkelen_stavanger/features/trips/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/state.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoSliverRefreshControl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripsPage extends StatefulWidget {
  final TripsBloc tripsBloc;

  const TripsPage({Key key, @required this.tripsBloc}) : super(key: key);

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  Completer<void> _refreshCompleter;
  final GlobalKey<RefreshIndicatorState> _refreshIndicator = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.tripsBloc.dispatch(FetchTrips(context: context));
  }

  Future<void> _onRefresh(state, BuildContext context) {
    if (state is TripsReady && !state.refreshing) {
      widget.tripsBloc.dispatch(FetchTrips(context: context));
    }
    _refreshCompleter = Completer();
    return _refreshCompleter.future;
  }

  CustomScrollView _buildCustomScrollView(BuildContext context, state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(Localization.of(context).tripsPageTitle),
          floating: true,
          pinned: true,
        ),
        if (Platform.isIOS)
          CupertinoSliverRefreshControl(
            onRefresh: () => _onRefresh(state, context),
          ),
        if (state is TripsReady)
          SliverFixedExtentList(
            itemExtent: 75,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final trip = state.trips[index];
                return ListTile(
                  title: Text(trip.fromPlace),
                  subtitle: Text(trip.time),
                );
              },
              childCount: state.trips.length,
            ),
          ),
      ],
    );
  }

  Widget _buildRootWidget(BuildContext context, TripsListState state) {
    return Stack(
      children: [
        if (Platform.isAndroid)
          RefreshIndicator(
            key: _refreshIndicator,
            displacement: 60,
            onRefresh: () => _onRefresh(state, context),
            child: _buildCustomScrollView(context, state),
          ),
        if (Platform.isIOS) _buildCustomScrollView(context, state),
        if (state is TripsError)
          Center(
            child: Text(
              state.message,
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
        if (state is TripsReady && state.trips.isEmpty)
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              Localization.of(context).noTripsInfo,
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: widget.tripsBloc,
      listener: (context, state) {
        if (state is TripsReady) {
          if (state.refreshing && _refreshIndicator.currentState != null) {
            _refreshIndicator.currentState.show();
          } else if (_refreshCompleter != null &&
              !_refreshCompleter.isCompleted) {
            _refreshCompleter.complete();
          }
        }
      },
      child: BlocBuilder(
        bloc: widget.tripsBloc,
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: _buildRootWidget(context, state),
            ),
          );
        },
      ),
    );
  }
}
