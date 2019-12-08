import 'package:bloc/bloc.dart';
import 'package:bysykkelen_stavanger/dependency_injection.dart';
import 'package:bysykkelen_stavanger/features/main_page/bloc/bloc.dart';
import 'package:bysykkelen_stavanger/features/main_page/main_page.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization.dart';
import 'package:bysykkelen_stavanger/theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Crashlytics.instance.enableInDevMode = true;
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  BlocSupervisor.delegate = SimpleBlocDelegate();

  await initDI();

  runApp(App());
}

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
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
        home: BlocProvider(
          create: (context) => MainBloc(),
          child: MainPage(),
        ),
      ),
    );
  }
}
