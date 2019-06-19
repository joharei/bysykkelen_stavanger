import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/info_card/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/info_card/bloc/state.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
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

      final spinAtLeastUntil = DateTime.now().add(Duration(seconds: 1));

      try {
        await bikeRepository.bookBike(
          event.stationUid,
          event.bookingDateTime,
          event.minimumDateTime,
          event.userName,
          event.password,
        );
      } catch (e) {
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
}
