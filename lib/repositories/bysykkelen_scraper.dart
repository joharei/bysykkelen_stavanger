import 'package:bysykkelen_stavanger/models/models.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:meta/meta.dart';

class BysykkelenScraper {
  static const String _baseUrl = 'https://my.bysykkelen.no/nb';
  final Dio dio;

  BysykkelenScraper({@required this.dio}) : assert(dio != null);

  Future<bool> loggedIn() async {
    dio.options.responseType = ResponseType.plain;
    dio.options.validateStatus = (status) => status == 200;
    dio.options.followRedirects = false;

    try {
      await dio.get('$_baseUrl/dashboard');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String userName, String password) async {
    dio.options.responseType = ResponseType.plain;
    dio.options.validateStatus = (status) => status == 200 || status == 302;

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
    dio.options.responseType = ResponseType.plain;
    dio.options.validateStatus = (status) => status == 200 || status == 302;

    try {
      final isNotEmpty = station.freeBikes > 0 ? 'True' : 'False';

      var bookingFormResponse = await dio.get(
        '$_baseUrl/reservations/add?dsId=${station.uid}&isNotEmpty=$isNotEmpty',
      );
      var bookingFormDocument =
          parser.parse(bookingFormResponse.data.toString());
      var bookingFormToken = bookingFormDocument
          .querySelector('input[name=__RequestVerificationToken]')
          .attributes['value'];
      var maxDays = bookingFormDocument
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

  /// Formats [dateTime] as 'DD/MM/YYYY HH:mm'
  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString()} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
