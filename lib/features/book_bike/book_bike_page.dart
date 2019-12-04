import 'package:bysykkelen_stavanger/features/book_bike/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/book_bike/progress_button.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/safe_area_insets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookBikePage extends StatefulWidget {
  final Station _station;

  BookBikePage(this._station);

  @override
  State<StatefulWidget> createState() => _BookBikePageState();

  static Future show(
    BuildContext context,
    Station station,
  ) =>
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        backgroundColor: Colors.white,
        builder: (context) => BookBikePage(station),
        isScrollControlled: true,
      );
}

class _BookBikePageState extends State<BookBikePage> {
  final BookBikeBloc _bookBikeBloc = BookBikeBloc();
  DateTime _chosenDate;

  @override
  void initState() {
    super.initState();
    _chosenDate = _getInitialDateTime();
  }

  @override
  void dispose() {
    _bookBikeBloc.close();
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
              title: Text(Localization.of(context).invalidTimeTitle),
              content: Text(Localization.of(context).invalidTimeContent),
              actions: <Widget>[
                FlatButton(
                  child: Text(Localization.of(context).ok),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
      return;
    }

    _bookBikeBloc.add(BookBike(
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
          title: Text(Localization.of(context).bookingErrorTitle),
          content: Text(Localization.of(context).bookingErrorContent),
          actions: <Widget>[
            FlatButton(
              child: Text(Localization.of(context).ok),
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

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
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
                controller: scrollController,
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 32,
                  bottom: safeAreaBottomInset(context) + 8,
                ),
                children: [
                  Text(Localization.of(context).bookBike,
                      style: Theme.of(context).textTheme.headline),
                  Container(
                    height: MediaQuery.of(context).size.height / 4,
                    child: CupertinoDatePicker(
                      onDateTimeChanged: (date) => _chosenDate = date,
                      use24hFormat:
                          MediaQuery.of(context).alwaysUse24HourFormat,
                      initialDateTime: _getInitialDateTime(),
                      minimumDate: minimumDateTime.subtract(Duration(days: 1)),
                      maximumDate: maximumDateTime,
                      minuteInterval: 5,
                    ),
                  ),
                  Center(
                    child: ProgressButton(
                      text: Localization.of(context).addBooking,
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
      },
    );
  }
}
