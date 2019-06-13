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

  bookBike(int uid) async => _bysykkelenScraper.bookBike(uid);
}
