import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/features/auth_screen/data/login_data.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/helpers/post_login.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';

final class LoginRx extends RxResponseInt<Map> {
  final api = LoginApi.instance;

  String message = "Something went wrong";

  LoginRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postLogin({
    required String identifier,
    required String password,
  }) async {
    try {
      Map<String, dynamic> data = {
        "identifier": identifier,
        "password": password,
      };

      Map resdata = await api.postLogin(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    final Map? dataMap = data["data"] is Map ? data["data"] as Map : null;

    final token =
        dataMap?["access_token"] ?? data["access_token"] ?? data["token"];
    if (token != null) {
      await appData.write(kKeyAccessToken, token.toString());
    }

    final role =
        dataMap?["role_type"] ??
        dataMap?["role"] ??
        data["role_type"] ??
        data["role"] ??
        "employee";
    await appData.write(kKeyUserRole, role.toString());

    if (dataMap?["id"] != null) {
      await appData.write(kKeyUserID, dataMap!["id"].toString());
    }
    if (dataMap?["name"] != null) {
      await appData.write(kKeyUserName, dataMap!["name"].toString());
    }
    if (dataMap?["email"] != null) {
      await appData.write(kKeyUserEmail, dataMap!["email"].toString());
    }
    if (dataMap?["mobile"] != null) {
      await appData.write(kPhone, dataMap!["mobile"].toString());
    }
    if (dataMap?["designation"] != null) {
      await appData.write(
        kKeyUserDesignation,
        dataMap!["designation"].toString(),
      );
    }

    await appData.write(kKeyIsLoggedIn, true);
    await performPostLoginActions();

    dataFetcher.sink.add(data);
    message = data["message"]?.toString() ?? "Login successful";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Something went wrong';
    log(error.toString());

    if (error is DioException) {
      final res = error.response?.data;
      if (res is Map && res["message"] != null) {
        message = res["message"].toString();
      } else if (res is String && res.isNotEmpty) {
        message = res;
      } else {
        message =
            error.response?.statusMessage ??
            "Invalid credentials. Please try again.";
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

typedef PostLoginRx = LoginRx;
