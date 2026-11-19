import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/dio/dio.dart';
import 'package:location_tracker/networks/endpoints.dart';
import 'package:location_tracker/networks/exception_handler/data_source.dart';

final class PostCreateCustomerApi {
  static final PostCreateCustomerApi _singleton =
      PostCreateCustomerApi._internal();
  PostCreateCustomerApi._internal();
  static PostCreateCustomerApi get instance => _singleton;

  Future<Map> postCreateCustomer(Map<String, dynamic> data) async {
    try {
      final token = appData.read(kKeyAccessToken)?.toString();
      final endpoint = (token != null && token.isNotEmpty)
          ? "${Endpoints.createCustomerInfo()}?access_token=$token"
          : Endpoints.createCustomerInfo();

      Response response = await postHttp(endpoint, data);
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
