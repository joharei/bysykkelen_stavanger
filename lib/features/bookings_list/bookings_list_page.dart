import 'dart:async';
import 'dart:io';

import 'package:bysykkelen_stavanger/features/bookings_list/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/event.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/state.dart';

class BookingsListPage extends StatefulWidget {
  final BikeRepository _bikeRepository;

  BookingsListPage(this._bikeRepository);

  @override
  State<StatefulWidget> createState() => _BookingsListPageState();

  static Future show(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingsListPage(Provider.of(context)),
        ),
      );
}

class _BookingsListPageState extends State<BookingsListPage> {
  BookingsBloc _bloc;
  Completer<void> _refreshCompleter;
  final GlobalKey<RefreshIndicatorState> _refreshIndicator = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bloc = BookingsBloc(bikeRepository: widget._bikeRepository);
    _bloc.dispatch(FetchBookings(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _bloc,
        listener: (context, state) {
          if (state is BookingsReady) {
            if (state.message != null) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
              ));
            }
            if (state.refreshing && _refreshIndicator.currentState != null) {
              _refreshIndicator.currentState.show();
            } else if (_refreshCompleter != null &&
                !_refreshCompleter.isCompleted) {
              _refreshCompleter.complete();
            }
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
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
                      state.bookings.isEmpty &&
                      !state.refreshing)
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
      _bloc.dispatch(FetchBookings(context: context));
    }
    _refreshCompleter = Completer();
    return _refreshCompleter.future;
  }

  CustomScrollView _buildCustomScrollView(BuildContext context, state) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(Localization.of(context).bookings),
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
                        _bloc.dispatch(
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
