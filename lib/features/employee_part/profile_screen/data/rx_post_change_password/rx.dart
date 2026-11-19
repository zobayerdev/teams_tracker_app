import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class PostChangePasswordRx extends RxResponseInt<Map> {
  final api = PostChangePasswordApi.instance;

  String message = "Something went wrong";

  PostChangePasswordRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> changePassword({
    required dynamic userId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      Map<String, dynamic> data = {
        "user_id": userId,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      };

      Map resdata = await api.postChangePassword(data);
      final bool status = resdata["status"] is bool
          ? resdata["status"]
          : (resdata["status"] == 1 || resdata["status"] == "true");

      if (!status) {
        message =
            resdata["message"]?.toString() ?? "Failed to change password";
        customToastMessage('Warning', message);
        return false;
      }

      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message =
        data["message"]?.toString() ?? "Password changed successfully!";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to change password';
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
