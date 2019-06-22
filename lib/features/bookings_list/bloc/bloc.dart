import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsListState> {
  final BikeRepository bikeRepository;

  BookingsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BookingsListState get initialState => BookingsLoading();

  @override
  Stream<BookingsListState> mapEventToState(BookingsEvent event) async* {
    if (event is FetchBookings) {
      yield* _fetchBookings(event.context);
    } else if (event is DeleteBooking) {
      final deletedOk = await bikeRepository.deleteBooking(event.booking);
      if (currentState is BookingsReady) {
        yield (currentState as BookingsReady).copyWith(
          message: deletedOk
              ? 'Deleted your booking at ${event.booking.stationName}'
              : 'Failed to delete booking',
        );
      }
      if (deletedOk) {
        yield* _fetchBookings(event.context);
      }
    }
  }

  Stream<BookingsListState> _fetchBookings(BuildContext context) async* {
    yield BookingsLoading();

    if (!await bikeRepository.loggedIn()) {
      final userNameAndPassword =
      await promptForUsernameAndPassword(context);
      if (userNameAndPassword == null) {
        yield BookingsError(message: 'Couldn\'t log in');
        return;
      }

      await bikeRepository.login(
        userNameAndPassword.userName,
        userNameAndPassword.password,
      );
    }

    final bookings = await bikeRepository.fetchBookings();

    if (bookings != null) {
      yield BookingsReady(bookings: bookings);
    } else {
      yield BookingsError(message: 'Failed to get bookings');
    }
  }
}
