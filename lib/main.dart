import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/main_page/main_page.dart';
import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/repositories/bysykkelen_scraper.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/theme.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() async {
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };

  BlocSupervisor.delegate = SimpleBlocDelegate();

  final tempDir = await getTemporaryDirectory();
  final dio = Dio();
  dio.interceptors.add(CookieManager(PersistCookieJar(dir: tempDir.path)));

  final BikeRepository bikeRepository = BikeRepository(
    CitibikesApiClient(dio: dio),
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
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme(context),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('nb', ''),
      ],
      home: MainPage(bikeRepository: Provider.of(context)),
    );
  }
}
