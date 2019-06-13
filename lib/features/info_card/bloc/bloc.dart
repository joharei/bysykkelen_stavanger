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

      await bikeRepository.bookBike(event.stationUid);

      yield BookingReady();
    }
  }
}
