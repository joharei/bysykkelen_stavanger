import 'package:bysykkelen_stavanger/shared/localization/localization.dart';

class LocalizationEN extends Localization {
  @override
  String get bookBike => 'Book bike';

  @override
  String availableBikes(int availableBikes) =>
      'Available bikes: $availableBikes';

  @override
  String get invalidTimeTitle => 'Invalid time';

  @override
  String get invalidTimeContent =>
      'You must choose a time between now and 10 days from now.';

  @override
  String get bookingErrorTitle => 'Oh no!';

  @override
  String get bookingErrorContent =>
      'Something went wrong while booking the bike 😲';

  @override
  String get addBooking => 'Add booking';

  @override
  String get logIn => 'Log in';

  @override
  String get userName => 'User name';

  @override
  String get password => 'PIN code';

  @override
  String get remember => 'Remember?';

  @override
  String get createUserInfo => 'Don\'t have a user? Create one at ';

  @override
  String get noBookingsInfo =>
      'You don\'t have any bookings yet! Go back and press the "$bookBike" '
      'button to make a booking.';

  @override
  String deletedBooking(String stationName) =>
      'Deleted your booking at $stationName.';

  @override
  String get deleteFailed => 'Failed to delete booking.';

  @override
  String get loginFailed => 'Couldn\'t log in.';

  @override
  String get bookingsFailed => 'Failed to get your bookings.';

  @override
  String get mapPageTitle => 'Map';

  @override
  String get bookingsPageTitle => 'Bookings';

  @override
  String get tripsPageTitle => 'Trips';

  @override
  String get noTripsInfo => 'You don\'t have any trips yet! When you use the '
      'city bikes, your trips will appear here.';

  @override
  String get tripsFailed => 'Failed to get your trips.';

  @override
  String fromTo(String from, String to) => '$from to $to';

  @override
  String toStation(String to) => 'To $to';

  @override
  String price(String price) => 'Price: $price kr';

  @override
  String distance(String distance) => 'Distance: $distance ';
}
