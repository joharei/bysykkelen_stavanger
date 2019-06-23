import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsListState> {
  final BikeRepository bikeRepository;

  BookingsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BookingsListState get initialState => BookingsReady(
        bookings: [],
        refreshing: true,
      );

  @override
  Stream<BookingsListState> mapEventToState(BookingsEvent event) async* {
    if (event is FetchBookings) {
      yield* _fetchBookings(event.context);
    } else if (event is DeleteBooking) {
      final deletedOk = await bikeRepository.deleteBooking(event.booking);
      if (currentState is BookingsReady) {
        yield (currentState as BookingsReady).copyWith(
          message: deletedOk
              ? Localization.of(event.context)
                  .deletedBooking(event.booking.stationName)
              : Localization.of(event.context).deleteFailed,
        );
      }
      if (deletedOk) {
        yield* _fetchBookings(event.context);
      }
    }
  }

  Stream<BookingsListState> _fetchBookings(BuildContext context) async* {
    if (currentState is BookingsReady) {
      yield (currentState as BookingsReady).copyWith(refreshing: true);
    }

    var clearCookies = false;
    if (!await bikeRepository.loggedIn()) {
      final userNameAndPassword = await promptForUsernameAndPassword(context);
      if (userNameAndPassword == null) {
        yield BookingsError(message: Localization.of(context).loginFailed);
        return;
      }

      clearCookies = !userNameAndPassword.saveCredentials;

      await bikeRepository.login(
        userNameAndPassword.userName,
        userNameAndPassword.password,
      );
    }

    final bookings = await bikeRepository.fetchBookings();

    if (clearCookies) {
      await bikeRepository.clearCookies();
    }

    if (bookings != null) {
      yield BookingsReady(bookings: bookings, refreshing: false);
    } else {
      yield BookingsError(message: Localization.of(context).bookingsFailed);
    }
  }
}
