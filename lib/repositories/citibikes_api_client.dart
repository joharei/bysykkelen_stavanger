import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

class CitibikesApiClient {
  static const _baseUrl = 'http://api.citybik.es/v2';
  final Dio dio;

  CitibikesApiClient({@required this.dio}) : assert(dio != null);

  Future<List<Station>> getBikeStations() async {
    dio.options = BaseOptions(
      responseType: ResponseType.json,
    );

    final stationsUrl = '$_baseUrl/networks/bysykkelen?fields=stations';
    final stationsResponse = await dio.get(stationsUrl);

    final stationsJson = stationsResponse.data['network']['stations'] as List;
    return stationsJson.map((json) => Station.fromJson(json)).toList();
  }
}
