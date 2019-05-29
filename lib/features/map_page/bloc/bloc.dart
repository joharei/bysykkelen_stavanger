import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/models/station.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:meta/meta.dart';

class BikeStationsBloc extends Bloc<BikesEvent, BikesState> {
  final BikeRepository bikeRepository;

  BikeStationsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  List<Station> _stations = [];

  List<Station> get stations => _stations;

  fetchStations() {}

  @override
  BikesState get initialState => BikesLoaded(stations: []);

  @override
  Stream<BikesState> mapEventToState(BikesEvent event) async* {
    if (event == BikesEvent.start) {
      yield BikesLoading();

      try {
        final stations = await bikeRepository.getBikeStations();
        yield BikesLoaded(stations: stations);
      } catch (e) {
        yield BikesError();
      }
    }
  }
}
