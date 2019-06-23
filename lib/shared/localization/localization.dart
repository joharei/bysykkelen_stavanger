import 'package:bysykkelen_stavanger/shared/localization/localization_en.dart';
import 'package:bysykkelen_stavanger/shared/localization/localization_no.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

abstract class Localization {
  static Localization of(BuildContext context) =>
      Localizations.of<Localization>(context, Localization);
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
