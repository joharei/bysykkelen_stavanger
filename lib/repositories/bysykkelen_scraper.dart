import 'package:bysykkelen_stavanger/features/bookings_list/booking.dart';
import 'package:bysykkelen_stavanger/models/models.dart';
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

    try {
      final bookingsResponse =
          await dio.get('/reservations/indextable', queryParameters: {
        'NoHeader': 'False',
        'Page': 0,
      });
      final bookingsDocument = parser.parse(bookingsResponse.data.toString());
      final bookingElements =
          bookingsDocument.querySelectorAll('table tr[data-reservation-id]');
      final bookings = bookingElements.map((element) {
        return Booking(
            stationName: element.children[2].text,
            time: element.children[1].text,
            id: element.attributes['data-reservation-id'],
            requestVerificationToken: element
                .querySelector('input[name=__RequestVerificationToken]')
                .attributes['value'],
          );
      });
      return bookings.toList();
    } catch (e) {
      return null;
    }
  }

  /// Formats [dateTime] as 'DD/MM/YYYY HH:mm'
  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}/'
      '${dateTime.month.toString().padLeft(2, '0')}/'
      '${dateTime.year.toString()} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}
