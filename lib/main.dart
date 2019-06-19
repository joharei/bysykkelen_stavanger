import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/map_page/map_page.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/repositories/bysykkelen_scraper.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() async {
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  BlocSupervisor.delegate = SimpleBlocDelegate();

  var httpClient = http.Client();

  final tempDir = await getTemporaryDirectory();
  final dio = Dio();
  dio.interceptors.add(CookieManager(PersistCookieJar(dir: tempDir.path)));

  final BikeRepository bikeRepository = BikeRepository(
    CitibikesApiClient(httpClient: httpClient),
    BysykkelenScraper(dio: dio),
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
          buttonTheme: ButtonThemeData(
            colorScheme: ColorScheme.fromSwatch(),
            textTheme: ButtonTextTheme.primary,
          ),
          cupertinoOverrideTheme: CupertinoThemeData(
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle:
                  Theme.of(context).textTheme.subhead.copyWith(),
            ),
          ),
        ),
        home: MapPage(bikeRepository: Provider.of<BikeRepository>(context)),
      );
}
