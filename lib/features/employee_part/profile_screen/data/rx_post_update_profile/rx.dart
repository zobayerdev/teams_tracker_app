import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class PostUpdateProfileRx extends RxResponseInt<Map> {
  final api = PostUpdateProfileApi.instance;

  String message = "Something went wrong";

  PostUpdateProfileRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> updateProfile({
    required dynamic userId,
    required String name,
    File? profileImage,
  }) async {
    try {
      Map resdata = await api.postUpdateProfile(
        userId: userId,
        name: name,
        profileImage: profileImage,
      );
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message = data["message"]?.toString() ?? "Profile updated successfully!";

    if (data["data"] is Map) {
      final resMap = data["data"] as Map;
      if (resMap["name"] != null) {
        await appData.write(kKeyUserName, resMap["name"].toString());
      }
      if (resMap["profile_image_url"] != null) {
        await appData.write(
          kKeyUserAvatar,
          resMap["profile_image_url"].toString(),
        );
      }
    }

    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to update profile';
    log(error.toString());

    if (error is DioException) {
      final res = error.response?.data;
      if (res is Map && res["message"] != null) {
        message = res["message"].toString();
      } else if (res is String && res.isNotEmpty) {
        message = res;
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        message = "Check Your Network Connection";
      }
    }

    customToastMessage('Error', message);
    return false;
  }
}
