import 'package:bysykkelen_stavanger/shared/localization/localization.dart';

class LocalizationNO extends Localization {
  @override
  String get bookings => 'Reservasjoner';

  @override
  String get bookBike => 'Reserver sykkel';

  @override
  String availableBikes(int availableBikes) => 'Ledige sykler: $availableBikes';

  @override
  String get invalidTimeTitle => 'Ugyldig tid';

  @override
  String get invalidTimeContent =>
      'Du må velge et tidspunkt mellom nå og 10 dager fra nå.';

  @override
  String get bookingErrorTitle => 'Å nei!';

  @override
  String get bookingErrorContent =>
      'Noe gjorde at reservasjonen ikke gikk igjennom 😲';

  @override
  String get addBooking => 'Reserver';

  @override
  String get logIn => 'Logg inn';

  @override
  String get userName => 'Brukernavn';

  @override
  String get password => 'PIN-kode';

  @override
  String get remember => 'Husk?';

  @override
  String get createUserInfo => 'Har du ikke bruker ennå? Opprett en på ';

  @override
  String get noBookingsInfo =>
      'Du har ingen reservasjoner ennå! Gå tilbake og trykk på '
      '"$bookBike"-knappen for å reservere en sykkel.';

  @override
  String deletedBooking(String stationName) =>
      'Reservasjonen din på $stationName ble slettet.';

  @override
  String get deleteFailed => 'Klarte ikke å slette reservasjonen.';

  @override
  String get loginFailed => 'Klarte ikke å logge inn.';

  @override
  String get bookingsFailed => 'Klarte ikke å hente reservasjonene dine.';
}