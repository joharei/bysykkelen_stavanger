import 'package:bysykkelen_stavanger/features/info_card/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/info_card/bloc/event.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookBikePage extends StatefulWidget {
  final BikeRepository _bikeRepository;
  final Station _station;

  BookBikePage(this._bikeRepository, this._station);

  @override
  State<StatefulWidget> createState() => _BookBikePageState();

  static Future show(
    BuildContext context,
    BikeRepository bikeRepository,
    Station station,
  ) =>
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        builder: (context) => BookBikePage(bikeRepository, station),
      );
}

class _BookBikePageState extends State<BookBikePage> {
  BookBikeBloc _bookBikeBloc;

  @override
  void initState() {
    super.initState();
    _bookBikeBloc = BookBikeBloc(bikeRepository: widget._bikeRepository);
  }

  @override
  void dispose() {
    _bookBikeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bookBikeBloc,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Text('Book bike', style: Theme.of(context).textTheme.headline),
              RaisedButton(
                onPressed: () => _bookBikeBloc
                    .dispatch(BookBike(stationUid: widget._station.uid)),
                child: Text('Login'),
              ),
            ],
          ),
        );
      },
    );
  }
}
