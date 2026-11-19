import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/dio/dio.dart';
import 'package:location_tracker/networks/endpoints.dart';
import 'package:location_tracker/networks/exception_handler/data_source.dart';

final class GetAttendanceApi {
  static final GetAttendanceApi _singleton = GetAttendanceApi._internal();
  GetAttendanceApi._internal();
  static GetAttendanceApi get instance => _singleton;

  Future<Map> getAttendance({String? month}) async {
    try {
      final token = appData.read(kKeyAccessToken)?.toString();
      final List<String> queryParams = [];

      if (token != null && token.isNotEmpty) {
        queryParams.add("access_token=$token");
      }
      if (month != null && month.isNotEmpty) {
        queryParams.add("month=$month");
      }

      String endpoint = Endpoints.getAttendence();
      if (queryParams.isNotEmpty) {
        endpoint = "$endpoint?${queryParams.join('&')}";
      }

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
