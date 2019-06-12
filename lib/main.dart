import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/map_page.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() {
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  BlocSupervisor.delegate = SimpleBlocDelegate();

  final BikeRepository bikeRepository = BikeRepository(
    citibikesApiClient: CitibikesApiClient(
      httpClient: http.Client(),
    ),
  );

  runApp(
    Provider.value(
      value: bikeRepository,
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MapPage(bikeRepository: Provider.of<BikeRepository>(context)),
      );
}
