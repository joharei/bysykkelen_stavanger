import 'dart:async';
import 'dart:io';

import 'package:bysykkelen_stavanger/features/trips/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/trips/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/trips/trips_navigator.dart';
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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.tripsBloc.getNextListPage(context);
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

  Future<void> _onRefresh(state, BuildContext context) {
    if (state is TripsReady && !state.refreshing) {
      widget.tripsBloc.refresh(context);
    }
    _refreshCompleter = Completer();
    return _refreshCompleter.future;
  }

  Widget _buildCustomScrollView(BuildContext context, state) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification(context, state),
      child: CustomScrollView(
        controller: _scrollController,
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= state.trips.length) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final trip = state.trips[index];
                  return ListTile(
                    title: Text(Localization.of(context)
                        .fromTo(trip.fromStation, trip.toStation)),
                    subtitle: Text(trip.fromDate),
                    trailing:
                        trip.price == '0' ? null : Text('${trip.price} kr'),
                    onTap: () => Navigator.of(context)
                        .pushNamed(TripsRoutes.details, arguments: trip),
                  );
                },
                childCount: state.hasReachedEnd || state.trips.isEmpty
                    ? state.trips.length
                    : state.trips.length + 1,
              ),
            ),
        ],
      ),
    );
  }

  NotificationListenerCallback<ScrollNotification> _handleScrollNotification(
    BuildContext context,
    TripsListState state,
  ) =>
      (ScrollNotification notification) {
        if (notification is ScrollEndNotification &&
            _scrollController.position.extentAfter == 0 &&
            state is TripsReady &&
            !state.hasReachedEnd) {
          widget.tripsBloc.getNextListPage(context);
        }
        return false;
      };

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
        if (state is TripsReady && !state.refreshing && state.trips.isEmpty)
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
}
