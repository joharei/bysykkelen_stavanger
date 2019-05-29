import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/event.dart';
import 'package:bysykkelen_stavanger/features/map_page/bloc/state.dart';
import 'package:bysykkelen_stavanger/features/map_page/png_generator.dart';
import 'package:bysykkelen_stavanger/repositories/repositories.dart';
import 'package:meta/meta.dart';

class BikeStationsBloc extends Bloc<BikesEvent, BikesState> {
  final BikeRepository bikeRepository;

  BikeStationsBloc({@required this.bikeRepository})
      : assert(bikeRepository != null);

  @override
  BikesState get initialState => BikesLoaded(stations: {});

  @override
  Stream<BikesState> mapEventToState(BikesEvent event) async* {
    if (event == BikesEvent.start) {
      yield BikesLoading();

      try {
        final stations = await bikeRepository.getBikeStations();
        final markers = await Future.wait(
          stations.map(
            (station) async => await generatePngForNumber(station.freeBikes),
          ),
        );
        yield BikesLoaded(stations: Map.fromIterables(stations, markers));
      } catch (e) {
        print(e);
        yield BikesError();
      }
    }
  }
}
