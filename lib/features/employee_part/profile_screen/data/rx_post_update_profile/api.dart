import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/dio/dio.dart';
import 'package:location_tracker/networks/endpoints.dart';
import 'package:location_tracker/networks/exception_handler/data_source.dart';

final class PostUpdateProfileApi {
  static final PostUpdateProfileApi _singleton =
      PostUpdateProfileApi._internal();
  PostUpdateProfileApi._internal();
  static PostUpdateProfileApi get instance => _singleton;

  Future<Map> postUpdateProfile({
    required dynamic userId,
    required String name,
    File? profileImage,
  }) async {
    try {
      final token = appData.read(kKeyAccessToken)?.toString();
      final endpoint = (token != null && token.isNotEmpty)
          ? "${Endpoints.updateEmployeeInfo()}?access_token=$token"
          : Endpoints.updateEmployeeInfo();

      final Map<String, dynamic> map = {
        'user_id': userId.toString(),
        'name': name,
      };

      if (profileImage != null && await profileImage.exists()) {
        final fileName = profileImage.path.split(RegExp(r'[\\/]')).last;
        map['profile_image'] = await MultipartFile.fromFile(
          profileImage.path,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap(map);

      Response response = await postHttp(endpoint, formData);
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
