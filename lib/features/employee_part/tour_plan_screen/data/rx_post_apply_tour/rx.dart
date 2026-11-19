import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:location_tracker/common_widgets/custom_toast.dart';
import 'package:location_tracker/networks/rx_base.dart';
import 'package:rxdart/streams.dart';
import 'api.dart';

final class PostApplyTourRx extends RxResponseInt<Map> {
  final api = PostApplyTourApi.instance;

  String message = "Something went wrong";

  PostApplyTourRx({required super.empty, required super.dataFetcher});

  ValueStream get fillData => dataFetcher.stream;

  Future<bool> postApplyTour({
    required String title,
    required String destination,
    required String startDate,
    required String endDate,
    required String purpose,
    num estTransport = 0.0,
    num estDa = 0.0,
    num estHotel = 0.0,
    num estOther = 0.0,
  }) async {
    try {
      Map<String, dynamic> data = {
        "title": title,
        "destination": destination,
        "start_date": startDate,
        "end_date": endDate,
        "purpose": purpose,
        "est_transport": estTransport,
        "est_da": estDa,
        "est_hotel": estHotel,
        "est_other": estOther,
      };

      Map resdata = await api.postApplyTour(data);
      return await handleSuccessWithReturn(resdata);
    } catch (error) {
      return await handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(data) async {
    dataFetcher.sink.add(data);
    message = data["message"]?.toString() ?? "Tour plan submitted successfully.";
    customToastMessage('Success', message);
    return true;
  }

  @override
  handleErrorWithReturn(error) {
    message = 'Failed to submit tour plan';
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
