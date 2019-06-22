import 'package:bysykkelen_stavanger/features/book_bike/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/book_bike/progress_button.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/shared/safe_area_insets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        backgroundColor: Colors.white,
        builder: (context) => BookBikePage(bikeRepository, station),
      );
}

class _BookBikePageState extends State<BookBikePage> {
  BookBikeBloc _bookBikeBloc;
  DateTime _chosenDate;

  @override
  void initState() {
    super.initState();
    _bookBikeBloc = BookBikeBloc(bikeRepository: widget._bikeRepository);
    _chosenDate = _getInitialDateTime();
  }

  @override
  void dispose() {
    _bookBikeBloc.dispose();
    super.dispose();
  }

  DateTime _getMinimumDateTime() {
    final now = DateTime.now();
    return now.add(Duration(minutes: 5 - now.minute % 5));
  }

  DateTime _getMaximumDateTime() =>
      _getMinimumDateTime().add(Duration(days: 10));

  DateTime _getInitialDateTime() =>
      _getMinimumDateTime().add(Duration(minutes: 30));

  _addBookingButtonPressed(
    BuildContext context,
    DateTime minimumDateTime,
    DateTime maximumDateTime,
  ) async {
    if (_chosenDate.isBefore(minimumDateTime) ||
        _chosenDate.isAfter(maximumDateTime)) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Invalid time'),
              content: Text(
                'You must choose a value between now and 10 days from now.',
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      return;
    }

    _bookBikeBloc.dispatch(BookBike(
      station: widget._station,
      bookingDateTime: _chosenDate,
      minimumDateTime: minimumDateTime,
      context: context,
    ));
  }

  _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong while booking the bike 😲'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final minimumDateTime = _getMinimumDateTime();
    final maximumDateTime = _getMaximumDateTime();

    return BlocListener(
      bloc: _bookBikeBloc,
      listener: (context, state) {
        if (state is CloseBookingPage) {
          Navigator.of(context).pop();
        } else if (state is BookingError) {
          _showErrorDialog(context);
        }
      },
      child: BlocBuilder(
        bloc: _bookBikeBloc,
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 32,
              bottom: safeAreaBottomInset(context) + 8,
            ),
            children: [
              Text('Book bike', style: Theme.of(context).textTheme.headline),
              Container(
                height: MediaQuery.of(context).size.height / 4,
                child: CupertinoDatePicker(
                  onDateTimeChanged: (date) => _chosenDate = date,
                  use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  initialDateTime: _getInitialDateTime(),
                  minimumDate: minimumDateTime.subtract(Duration(days: 1)),
                  maximumDate: maximumDateTime,
                  minuteInterval: 5,
                ),
              ),
              Center(
                child: ProgressButton(
                  text: 'Add booking',
                  state: state is BookingLoading
                      ? ProgressState.loading
                      : state is BookingDone
                          ? ProgressState.done
                          : state is CloseBookingPage
                              ? ProgressState.done
                              : ProgressState.idle,
                  onPressed: () => _addBookingButtonPressed(
                        context,
                        minimumDateTime,
                        maximumDateTime,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
