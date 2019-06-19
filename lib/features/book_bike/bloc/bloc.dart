import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/book_bike/username_and_password.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookBikeBloc extends Bloc<BookBikeEvent, BookBikeState> {
  final BikeRepository bikeRepository;

  BookBikeBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BookBikeState get initialState => BookingReady();

  @override
  Stream<BookBikeState> mapEventToState(BookBikeEvent event) async* {
    if (event is BookBike) {
      yield BookingLoading();

      if (!await bikeRepository.loggedIn()) {
        final userNameAndPassword =
            await _promptForUsernameAndPassword(event.context);
        if (userNameAndPassword == null) {
          yield BookingReady();
          return;
        }

        await bikeRepository.login(
          userNameAndPassword.userName,
          userNameAndPassword.password,
        );
      }

      final spinAtLeastUntil = DateTime.now().add(Duration(seconds: 1));

      final bookingOk = await bikeRepository.bookBike(
        event.station,
        event.bookingDateTime,
        event.minimumDateTime,
      );

      if (!bookingOk) {
        yield BookingError();
        return;
      }

      final now = DateTime.now();
      if (spinAtLeastUntil.isAfter(now)) {
        // Delay a little if the booking was too fast for the animation to complete
        await Future.delayed(spinAtLeastUntil.difference(now));
      }

      yield BookingDone();

      await Future.delayed(Duration(seconds: 1));

      yield CloseBookingPage();
    }
  }

  Future<UsernameAndPassword> _promptForUsernameAndPassword(
    BuildContext context,
  ) async {
    String userName;
    String password;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Log in'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'User name'),
                  autocorrect: false,
                  onChanged: (value) {
                    userName = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Password'),
                  autocorrect: false,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context)
                      .pop(UsernameAndPassword(userName, password));
                },
              ),
            ],
          );
        });
  }
}
