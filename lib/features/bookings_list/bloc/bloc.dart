import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/bookings_list/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class BookBikeBloc extends Bloc<BookingsEvent, BookingsListState> {
  final BikeRepository bikeRepository;

  BookBikeBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BookingsListState get initialState => BookingsLoading();

  @override
  Stream<BookingsListState> mapEventToState(BookingsEvent event) async* {
    if (event is FetchBookings) {
      yield BookingsLoading();

      if (!await bikeRepository.loggedIn()) {
        final userNameAndPassword =
        await promptForUsernameAndPassword(event.context);
        if (userNameAndPassword == null) {
          yield BookingsError(message: 'Couldn\'t log in');
          return;
        }

        await bikeRepository.login(
          userNameAndPassword.userName,
          userNameAndPassword.password,
        );
      }
    }
  }
}
