import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';
import 'package:meta/meta.dart';

class BikeRepository {
  final CitibikesApiClient citibikesApiClient;

  BikeRepository({@required this.citibikesApiClient})
      : assert(citibikesApiClient != null);

  Future<List<Station>> getBikeStations() async {
    return await citibikesApiClient.getBikeStations();
  }
}
