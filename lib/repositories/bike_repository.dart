import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/bysykkelen_scraper.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';

class BikeRepository {
  final CitibikesApiClient _citibikesApiClient;
  final BysykkelenScraper _bysykkelenScraper;

  BikeRepository(this._citibikesApiClient, this._bysykkelenScraper)
      : assert(_citibikesApiClient != null),
        assert(_bysykkelenScraper != null);

  Future<List<Station>> getBikeStations() async {
    return await _citibikesApiClient.getBikeStations();
  }

  Future<bool> loggedIn() => _bysykkelenScraper.loggedIn();

  Future<bool> login(String userName, String password) =>
      _bysykkelenScraper.login(userName, password);

  Future<bool> bookBike(
    Station station,
    DateTime bookingDateTime,
    DateTime minimumDateTime,
  ) =>
      _bysykkelenScraper.bookBike(
        station,
        bookingDateTime,
        minimumDateTime,
      );

  Future<List<Booking>> fetchBookings() => _bysykkelenScraper.fetchBookings();
}
