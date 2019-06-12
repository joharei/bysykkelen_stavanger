import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/info_card/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/info_card/bloc/state.dart';

class BookBikeBloc extends Bloc<BookBikeEvent, BookBikeState> {
  @override
  BookBikeState get initialState => BookingReady();

  @override
  Stream<BookBikeState> mapEventToState(BookBikeEvent event) async* {
    if (event is BookBike) {
      yield BookingLoading();
      await Future.delayed(Duration(seconds: 1));
      yield BookingReady();
    }
  }
}
