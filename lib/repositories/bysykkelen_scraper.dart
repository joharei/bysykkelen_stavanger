import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class BysykkelenScraper {
  static const String _baseUrl = 'https://my.bysykkelen.no/nb';
  final http.Client httpClient;

  BysykkelenScraper({@required this.httpClient}) : assert(httpClient != null);

  bookBike(int uid) async {
    var loginFormResponse = await httpClient.get('$_baseUrl/account/signin');

    var cookieJar = CookieJar.fromResponse(loginFormResponse);

    var loginFormToken = parser
        .parse(loginFormResponse.body)
        .querySelector('input[name=__RequestVerificationToken]')
        .attributes['value'];

    var loginResponse = await httpClient.post(
      '$_baseUrl/account/signin',
      body: {
        'UserName': '',
        'Password': '',
        '__RequestVerificationToken': loginFormToken,
      },
      headers: {'Cookie': cookieJar.toString()},
    );
    cookieJar.update(loginResponse);

    var bookingFormResponse = await httpClient.get(
      '$_baseUrl/reservations/add?dsId=$uid&isNotEmpty=True',
      headers: {'Cookie': cookieJar.toString()},
    );
    var bookingFormDocument = parser.parse(bookingFormResponse.body);
    var bookingFormToken = bookingFormDocument
        .querySelector('input[name=__RequestVerificationToken]')
        .attributes['value'];
    var maxDays = bookingFormDocument
        .querySelector('input[name=MaxDays]')
        .attributes['value'];

    var bookingResponse = await httpClient.post(
      '$_baseUrl/reservations/add?dsId=$uid&isNotEmpty=True',
      body: {
        'StartDate': '14/06/2019 14:00',
        'MinDate': '13/06/2019 23:10',
        'DockingStationId': '$uid',
        'MaxDays': maxDays,
        '__RequestVerificationToken': bookingFormToken,
      },
      headers: {'Cookie': cookieJar.toString()},
    );
    print(bookingResponse.body);
  }
}

class CookieJar {
  final Map<String, String> cookies = {};

  CookieJar.fromResponse(http.Response response) {
    cookies.addAll(_extractHeaders(response));
  }

  @override
  String toString() => cookies
      .map((key, value) => MapEntry(key, '$key=$value'))
      .values
      .join('; ');

  update(http.Response response) {
    cookies.addAll(_extractHeaders(response));
  }

  Map<String, String> _extractHeaders(http.Response loginFormResponse) {
    var cookieList = loginFormResponse.headers['set-cookie']
        .splitMapJoin(
          RegExp(r',(\w)'),
          onMatch: (match) => ',,,${match.group(0)}',
          onNonMatch: (nonMatch) => nonMatch,
        )
        .split(',,,,')
        .map((cookieString) {
      var match = RegExp(r'^([^=]+)=(.+?);').firstMatch(cookieString);
      return MapEntry(match.group(1), match.group(2));
    });
    return Map.fromEntries(cookieList);
  }
}