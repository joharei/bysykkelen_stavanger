import 'dart:io';

import 'package:bysykkelen_stavanger/repositories/bike_repository.dart';
import 'package:bysykkelen_stavanger/repositories/bysykkelen_scraper.dart';
import 'package:bysykkelen_stavanger/repositories/citibikes_api_client.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:kiwi/kiwi.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initDI() async {
  final tempDir = await getTemporaryDirectory();
  Container().registerInstance(tempDir, name: 'tempDir');
  Container().registerFactory(
    (c) {
      var dio = Dio()
      ..interceptors.add(CookieManager(
          PersistCookieJar(dir: c.resolve<Directory>('tempDir').path)));
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) =>
      // Accept bad certificates :(
          client..badCertificateCallback = (cert, host, port) => true;
      return dio;
    },
  );
  Container().registerFactory((c) => CitibikesApiClient(dio: c.resolve()));
  Container().registerFactory((c) => BysykkelenScraper(dio: c.resolve()));
  Container().registerFactory((c) => BikeRepository(c.resolve(), c.resolve()));
}
