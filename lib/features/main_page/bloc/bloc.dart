import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  @override
  MainState get initialState => MainState(navIndex: 0);

  @override
  Stream<MainState> mapEventToState(MainEvent event) async* {
    yield MainState(navIndex: event.navIndex);
  }
}
