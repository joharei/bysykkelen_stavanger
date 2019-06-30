import 'dart:async';
import 'dart:io';

import 'package:bysykkelen_stavanger/features/bookings_list/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/event.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/state.dart';

class BookingsListPage extends StatefulWidget {
  final BookingsBloc bookingsBloc;

  const BookingsListPage({Key key, @required this.bookingsBloc})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends State<BookingsListPage> {
  Completer<void> _refreshCompleter;
  final GlobalKey<RefreshIndicatorState> _refreshIndicator = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.bookingsBloc.dispatch(FetchBookings(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: widget.bookingsBloc,
        listener: (context, state) {
          if (state is BookingsReady) {
            if (state.refreshing && _refreshIndicator.currentState != null) {
              _refreshIndicator.currentState.show();
            } else if (_refreshCompleter != null &&
                !_refreshCompleter.isCompleted) {
              _refreshCompleter.complete();
            }
          }
        },
        child: BlocBuilder(
          bloc: widget.bookingsBloc,
          builder: (context, state) {
            return SafeArea(
              child: Stack(
                children: [
                  if (Platform.isAndroid)
                    RefreshIndicator(
                      key: _refreshIndicator,
                      displacement: 60,
                      onRefresh: () => _onRefresh(state, context),
                      child: _buildCustomScrollView(context, state),
                    ),
                  if (Platform.isIOS) _buildCustomScrollView(context, state),
                  if (state is BookingsError)
                    Center(
                      child: Text(
                        state.message,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                  if (state is BookingsReady &&
                      state.bookings.isEmpty)
                    Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: Text(
                        Localization.of(context).noBookingsInfo,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(state, BuildContext context) {
    if (state is BookingsReady && !state.refreshing) {
      widget.bookingsBloc.dispatch(FetchBookings(context: context));
    }
    _refreshCompleter = Completer();
    return _refreshCompleter.future;
  }

  CustomScrollView _buildCustomScrollView(BuildContext context, state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(Localization.of(context).bookingsPageTitle),
          floating: true,
          pinned: true,
        ),
        if (Platform.isIOS)
          CupertinoSliverRefreshControl(
            onRefresh: () => _onRefresh(state, context),
          ),
        if (state is BookingsReady)
          SliverFixedExtentList(
            itemExtent: 75,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final booking = state.bookings[index];
                return ListTile(
                  title: Text(booking.stationName),
                  subtitle: Text(booking.time),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      return {
                        widget.bookingsBloc.dispatch(
                          DeleteBooking(
                            context: context,
                            booking: booking,
                          ),
                        )
                      };
                    },
                  ),
                );
              },
              childCount: state.bookings.length,
            ),
          ),
      ],
    );
  }
}
