import 'package:bysykkelen_stavanger/features/bookings_list/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/event.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _bloc = BookingsBloc(bikeRepository: widget._bikeRepository);
    _bloc.dispatch(FetchBookings(context: context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder(
        bloc: _bloc,
        builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text('Bookings'),
                    floating: true,
                    pinned: true,
                  ),
                  if (state is BookingsReady)
                    SliverFixedExtentList(
                      itemExtent: 100,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final booking = state.bookings[index];
                          return ListTile(
                            title: Text(booking.stationName),
                            subtitle: Text(booking.time),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => {},
                            ),
                          );
                        },
                        childCount: state.bookings.length,
                      ),
                    ),
                ],
              ),
              if (state is BookingsLoading)
                Center(child: CircularProgressIndicator()),
              if (state is BookingsError)
                Center(
                  child: Text(
                    state.message,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}
