import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/map_page.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  final BikeRepository bikeRepository = BikeRepository(
    citibikesApiClient: CitibikesApiClient(
      httpClient: http.Client(),
    ),
  );

  runApp(App(bikeRepository: bikeRepository));
}

class App extends StatelessWidget {
  final BikeRepository bikeRepository;

  App({Key key, @required this.bikeRepository})
      : assert(bikeRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MapPage(bikeRepository: bikeRepository),
      );
}
