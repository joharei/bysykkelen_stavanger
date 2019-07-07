import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/book_bike/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/shared/login_prompt.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class BookBikeBloc extends Bloc<BookBikeEvent, BookBikeState> {
  final BikeRepository _bikeRepository;

  BookBikeBloc() : _bikeRepository = kiwi.Container().resolve();

  @override
  BookBikeState get initialState => BookingReady();

  @override
  Stream<BookBikeState> mapEventToState(BookBikeEvent event) async* {
    if (event is BookBike) {
      yield BookingLoading();

      var clearCookies = false;
      if (!await _bikeRepository.loggedIn()) {
        final userNameAndPassword =
            await promptForUsernameAndPassword(event.context);
        if (userNameAndPassword == null) {
          yield BookingReady();
          return;
        }

        clearCookies = !userNameAndPassword.saveCredentials;

        await _bikeRepository.login(
          userNameAndPassword.userName,
          userNameAndPassword.password,
        );
      }

      final spinAtLeastUntil = DateTime.now().add(Duration(seconds: 1));

      final bookingOk = await _bikeRepository.bookBike(
        event.station,
        event.bookingDateTime,
        event.minimumDateTime,
      );

      if (clearCookies) {
        await _bikeRepository.clearCookies();
      }

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

      await Future.delayed(Duration(seconds: 3));

      yield CloseBookingPage();
    }
  }
}
