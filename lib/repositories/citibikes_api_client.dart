import 'dart:convert';

import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class CitibikesApiClient {
  static const _baseUrl = 'http://api.citybik.es/v2';
  final http.Client httpClient;

  CitibikesApiClient({@required this.httpClient}) : assert(httpClient != null);

  Future<List<Station>> getBikeStations() async {
    final stationsUrl = '$_baseUrl/networks/bysykkelen?fields=stations';
    final stationsResponse = await httpClient.get(stationsUrl);
    if (stationsResponse.statusCode != 200) {
      throw Exception('${stationsResponse.statusCode}: error getting stations');
    }

    final stationsJson =
        jsonDecode(stationsResponse.body)['network']['stations'] as List;
    return stationsJson.map((json) => Station.fromJson(json)).toList();
  }
}
