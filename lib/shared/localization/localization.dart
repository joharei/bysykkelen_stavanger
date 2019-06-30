import 'package:bysykkelen_stavanger/shared/localization/localization_en.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization_no.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

abstract class Localization {
  static Localization of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization);

  String get bookBike;

  String availableBikes(int availableBikes);

  String get invalidTimeTitle;

  String get invalidTimeContent;

  String get bookingErrorTitle;

  String get bookingErrorContent;

  String get addBooking;

  String get ok => 'Ok';

  String get logIn;

  String get userName;

  String get password;

  String get remember;

  String get createUserInfo;

  String get noBookingsInfo;

  String deletedBooking(String stationName);

  String get deleteFailed;

  String get loginFailed;

  String get bookingsFailed;

  String get mapPageTitle;

  String get bookingsPageTitle;

  String get tripsPageTitle;

  String get noTripsInfo;

  String get tripsFailed;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'nb'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) {
    if (locale.languageCode == 'nb') {
      return SynchronousFuture(LocalizationNO());
    } else {
      return SynchronousFuture(LocalizationEN());
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
