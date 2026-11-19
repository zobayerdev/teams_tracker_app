import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/dio/dio.dart';
import 'package:location_tracker/networks/endpoints.dart';
import 'package:location_tracker/networks/exception_handler/data_source.dart';

final class GetMyToursApi {
  static final GetMyToursApi _singleton = GetMyToursApi._internal();
  GetMyToursApi._internal();
  static GetMyToursApi get instance => _singleton;

  Future<Map> getMyTours() async {
    try {
      final token = appData.read(kKeyAccessToken)?.toString();
      final endpoint = (token != null && token.isNotEmpty)
          ? "${Endpoints.myTour()}?access_token=$token"
          : Endpoints.myTour();

      Response response = await getHttp(endpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map resData = json.decode(json.encode(response.data));
        return resData;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      rethrow;
    }
  }
}
