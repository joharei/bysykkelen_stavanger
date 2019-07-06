import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:bysykkelen_stavanger/features/trips/Trip.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:meta/meta.dart';

class BysykkelenScraper {
  static const String _baseUrl = 'https://my.bysykkelen.no/nb';
  final Dio dio;

  BysykkelenScraper({@required this.dio}) : assert(dio != null);

  Future<bool> loggedIn() async {
    dio.options = BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status == 200,
      followRedirects: false,
    );

    try {
      await dio.get('$_baseUrl/dashboard');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String userName, String password) async {
    dio.options = BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status == 200 || status == 302,
    );

    try {
      final loginFormResponse = await dio.get('$_baseUrl/account/signin');

      final loginFormToken = parser
          .parse(loginFormResponse.data.toString())
          .querySelector('input[name=__RequestVerificationToken]')
          .attributes['value'];

      await dio.post(
        '$_baseUrl/account/signin',
        data: FormData.from({
          'UserName': userName,
          'Password': password,
          '__RequestVerificationToken': loginFormToken,
        }),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> bookBike(
    Station station,
    DateTime bookingDateTime,
    DateTime minimumDateTime,
  ) async {
    dio.options = BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status == 200 || status == 302,
    );

    try {
      final isNotEmpty = station.freeBikes > 0 ? 'True' : 'False';

      final bookingFormResponse = await dio.get(
        '$_baseUrl/reservations/add?dsId=${station.uid}&isNotEmpty=$isNotEmpty',
      );
      final bookingFormDocument =
          parser.parse(bookingFormResponse.data.toString());
      final bookingFormToken = bookingFormDocument
          .querySelector('input[name=__RequestVerificationToken]')
          .attributes['value'];
      final maxDays = bookingFormDocument
          .querySelector('input[name=MaxDays]')
          .attributes['value'];

      await dio.post(
        '$_baseUrl/reservations/add?dsId=${station.uid}&isNotEmpty=$isNotEmpty',
        data: FormData.from({
          'StartDate': _formatDateTime(bookingDateTime),
          'MinDate': _formatDateTime(minimumDateTime),
          'DockingStationId': '${station.uid}',
          'MaxDays': maxDays,
          '__RequestVerificationToken': bookingFormToken,
        }),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Booking>> fetchBookings() async {
    dio.options = BaseOptions(
      baseUrl: _baseUrl,
      responseType: ResponseType.plain,
      validateStatus: (status) => status == 200,
    );

    final bookings =
        await _fetchBookingsUrl('/bookings/indextable', 'data-booking-id');
    final reservations = await _fetchBookingsUrl(
        '/reservations/indextable', 'data-reservation-id');

    if (bookings == null && reservations == null) {
      return null;
    }

    return (bookings ?? [])..addAll(reservations ?? []);
  }

  Future<List<Booking>> _fetchBookingsUrl(String url, String idName) async {
    try {
      final bookingsResponse = await dio.get(url, queryParameters: {
        'NoHeader': 'False',
        'Page': 0,
      });
      final bookingsDocument = parser.parse(bookingsResponse.data.toString());
      final bookingElements =
          bookingsDocument.querySelectorAll('table tr[$idName]');
      final bookings = bookingElements.map((element) {
        return Booking(
          stationName: element.children[2].text,
          time: element.children[1].text,
          id: element.attributes[idName],
          requestVerificationToken: element
              .querySelector('input[name=__RequestVerificationToken]')
              .attributes['value'],
          deleteUrl: element.querySelector('form').attributes['action'],
        );
      });
      return bookings.toList();
    } catch (e) {
      return null;
    }
  }

  Future<List<Trip>> fetchTrips(int page) async {
    dio.options = BaseOptions(
      baseUrl: _baseUrl,
      responseType: ResponseType.plain,
      validateStatus: (status) => status == 200,
    );

    try {
      final tripsResponse = await dio.get(
        '/trips/indextable',
        queryParameters: {
          'NoHeader': 'True',
          'Page': page,
        },
      );
      final tripsDocument = parser.parse(tripsResponse.data.toString());

      if (tripsDocument.querySelector('h4') != null) {
        throw NoNextPageException();
      }

      final tripsElements = tripsDocument.querySelectorAll('tr');
      final trips = tripsElements.map(
        (element) => Trip(
          fromDate: element.children[1].text,
          fromStation: element.children[2].text,
          toDate: element.children[3].text,
          toStation: element.children[4].text,
          price: element.children[5].text,
          detailsUrl: element.querySelector('a').attributes['href'],
        ),
      );

      return trips.toList();
    } on NoNextPageException catch (e) {
      throw e;
    } catch (_) {
      throw ScrapingException();
    }
  }

  Future<bool> deleteBooking(Booking booking) async {
    dio.options = BaseOptions(
      baseUrl: 'https://my.bysykkelen.no',
      responseType: ResponseType.plain,
      validateStatus: (status) => status == 200 || status == 302,
    );

    try {
      await dio.post(
        booking.deleteUrl,
        data: FormData.from({
          '__RequestVerificationToken': booking.requestVerificationToken,
          'id': booking.id,
          'returnUrl': '',
        }),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future clearCookies() {
    CookieManager manager = dio.interceptors
        .firstWhere((interceptor) => interceptor is CookieManager);
    return Future.sync(
        () => (manager.cookieJar as PersistCookieJar).deleteAll());
  }

  /// Formats [dateTime] as 'DD/MM/YYYY HH:mm'
  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}/'
      '${dateTime.month.toString().padLeft(2, '0')}/'
      '${dateTime.year.toString()} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}

class ScrapingException implements Exception {}

class NoNextPageException implements Exception {}
