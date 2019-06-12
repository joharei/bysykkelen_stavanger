import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class BysykkelenScraper {
  final http.Client httpClient;

  BysykkelenScraper({@required this.httpClient}) : assert(httpClient != null);
}
