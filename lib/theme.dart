import 'package:flutter/cupertino.dart'
    show CupertinoThemeData, CupertinoTextThemeData;
import 'package:flutter/material.dart';

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    primaryColorBrightness: Brightness.dark,
    accentColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    appBarTheme: AppBarTheme(
      brightness: Brightness.light,
      color: Colors.white,
      textTheme: Theme.of(context).textTheme,
      iconTheme: Theme.of(context).iconTheme,
      actionsIconTheme: Theme.of(context).iconTheme,
    ),
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.fromSwatch(),
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blueAccent,
    ),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
      },
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        dateTimePickerTextStyle: Theme.of(context).textTheme.subhead.copyWith(),
      ),
    ),
  );
}
