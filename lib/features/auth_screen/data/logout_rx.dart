import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/constants/app_constants.dart';
import 'package:location_tracker/features/auth_screen/data/logout_data.dart';
import 'package:location_tracker/helpers/all_routes.dart';
import 'package:location_tracker/helpers/di.dart';
import 'package:location_tracker/helpers/navigation_service.dart';
import 'package:location_tracker/networks/dio/dio.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';

final class LogoutRx extends RxResponseInt<Map> {
  final api = LogoutApi.instance;

  String message = "Something went wrong";

  LogoutRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postLogout() async {
    try {
      final token = appData.read(kKeyAccessToken)?.toString() ?? '';
      Map<String, dynamic> data = {"access_token": token};

      Map resdata = await api.postLogout(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    // 1. Wipe credentials & local session
    await appData.write(kKeyIsLoggedIn, false);
    await appData.remove(kKeyAccessToken);
    await appData.remove(kKeyRefreshToken);
    await appData.remove(kKeyUserRole);
    await appData.remove(kKeyUserEmail);
    await appData.remove(kKeyUserName);
    await appData.remove(kKeyUserID);

    // 2. Reset Dio client to unauthenticated state
    DioSingleton.instance.create();

    dataFetcher.sink.add(data);
    message = data["message"]?.toString() ?? "Logged out successfully";
    customToastMessage('Success', message);

    // 3. Clear navigation backstack and return to login
    NavigationService.navigateToUntilReplacement(Routes.logInScreen);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Logout failed';
    log(error.toString());

    // Gracefully wipe local session so user is not locked in
    appData.write(kKeyIsLoggedIn, false);
    appData.remove(kKeyAccessToken);
    appData.remove(kKeyUserRole);
    DioSingleton.instance.create();
    NavigationService.navigateToUntilReplacement(Routes.logInScreen);

    if (error is DioException) {
      final res = error.response?.data;
      if (res is Map && res["message"] != null) {
        message = res["message"].toString();
      }
    }
    customToastMessage('Info', message);
    return false;
  }
}
